package main

import (
	"fmt"
	"log"
	"net"
	"strings"
	"time"

	"pc_remote_server/keyboard"
	"pc_remote_server/logger"
	"pc_remote_server/media"
	"pc_remote_server/mouse"
	"pc_remote_server/powercontrols"

	"os"

	"github.com/getlantern/systray"
)

// Globals
var (
	HOST           = "0.0.0.0"
	PORT           = 5555
	UDP_PORT       = 5556
	shutdownSignal = make(chan struct{})
	currentClient  net.Conn

	tcpClientIP   net.IP
	udpClientAddr *net.UDPAddr
)

// Command enum equivalent
const (
	VOLUME_UP          = "VOLUME_UP"
	VOLUME_DOWN        = "VOLUME_DOWN"
	VOLUME_MUTE        = "VOLUME_MUTE"
	PLAY_PAUSE         = "PLAY_PAUSE"
	NEXT_TRACK         = "NEXT_TRACK"
	PREVIOUS_TRACK     = "PREVIOUS_TRACK"
	CURRENT_VOLUME     = "CURRENT_VOLUME"
	MOVE_MOUSE         = "MOVE_MOUSE"
	MOUSE_DOWN         = "MOUSE_DOWN"
	MOUSE_UP           = "MOUSE_UP"
	CLICK_LEFT         = "CLICK_LEFT"
	CLICK_RIGHT        = "CLICK_RIGHT"
	SCROLL             = "SCROLL"
	SLEEP              = "SLEEP"
	LOCK               = "LOCK"
	SHUTDOWN           = "SHUTDOWN"
	SHOW_BLACK_SCREEN  = "SHOW_BLACK_SCREEN"
	CLOSE_BLACK_SCREEN = "CLOSE_BLACK_SCREEN"
	TYPE               = "TYPE"
	SPECIAL_KEY        = "SPECIAL_KEY"
)

// ---- Network utilities ----
func getLocalIP() string {
	conn, err := net.Dial("udp", "8.8.8.8:80")
	if err != nil {
		return "127.0.0.1"
	}
	defer conn.Close()

	localAddr := conn.LocalAddr().(*net.UDPAddr)
	return localAddr.IP.String()
}

// ---- TCP server ----
func startTCPServer() {
	addr := fmt.Sprintf("%s:%d", HOST, PORT)
	listener, err := net.Listen("tcp", addr)
	if err != nil {
		log.Fatalf("TCP listen error: %v", err)
	}
	defer listener.Close()
	log.Printf("TCP server listening on %s:%d\n", getLocalIP(), PORT)

	for {
		select {
		case <-shutdownSignal:
			log.Println("Shutting down TCP server...")
			return
		default:
			listener.(*net.TCPListener).SetDeadline(time.Now().Add(time.Second))
			conn, err := listener.Accept() // Get new client connection
			if err != nil {
				if ne, ok := err.(net.Error); ok && ne.Timeout() {
					continue
				}
				log.Printf("Accept error: %v", err)
				continue
			}

			// If a client was already connected, disconnect the newly connected one (cleanest approach since go doesn't support immediate kicking)
			if currentClient != nil {
				log.Printf("Rejected client: %s (already connected with another client)\n", conn.RemoteAddr())
				conn.Write([]byte("REJECT\n")) // ✅ tell Flutter it was rejected
				conn.Close()
				continue
			}

			currentClient = conn
			tcpClientIP = conn.RemoteAddr().(*net.TCPAddr).IP
			udpClientAddr = nil // reset UDP binding

			// Tell Flutter it was accepted
			conn.Write([]byte("WELCOME\n"))
			log.Printf("Client connected: %s\n", conn.RemoteAddr())
			go handleClient(conn)
		}
	}
}

func handleClient(conn net.Conn) {
	defer func() {
		log.Println("Closing client socket. Waiting for new connection...")
		conn.Close()
		currentClient = nil
		tcpClientIP = nil // clear TCP/UDP binding
		udpClientAddr = nil
	}()

	for {
		select {
		case <-shutdownSignal:
			return
		default:
			conn.SetReadDeadline(time.Now().Add(time.Second))
			buf := make([]byte, 1024)
			n, err := conn.Read(buf)
			if err != nil {
				if ne, ok := err.(net.Error); ok && ne.Timeout() {
					continue
				}
				log.Printf("Client disconnected: %v", err)
				return
			}
			cmd := strings.TrimSpace(string(buf[:n]))

			if cmd != "" {
				log.Printf("Received command: %s", cmd)
				executeCommand(conn, cmd)
			}
		}
	}
}

// ---- UDP server for mouse ----
func startUDPServer() {
	addr := fmt.Sprintf("%s:%d", HOST, UDP_PORT)
	udpAddr, _ := net.ResolveUDPAddr("udp", addr)
	conn, err := net.ListenUDP("udp", udpAddr)
	if err != nil {
		log.Fatalf("UDP listen error: %v", err)
	}
	defer conn.Close()
	log.Printf("UDP server listening on %s:%d\n", getLocalIP(), UDP_PORT)

	buf := make([]byte, 1024)
	for {
		select {
		case <-shutdownSignal:
			log.Println("Shutting down UDP server...")
			return
		default:
			conn.SetReadDeadline(time.Now().Add(time.Second))
			n, clientAddr, err := conn.ReadFromUDP(buf)
			if err != nil {
				if ne, ok := err.(net.Error); ok && ne.Timeout() {
					continue
				}
				log.Printf("UDP read error: %v", err)
				return
			}

			// Reject if no active TCP client
			if tcpClientIP == nil {
				log.Printf("Rejected UDP packet from %s (no active TCP client)\n", clientAddr)
				continue
			}

			// Reject if IP doesn't match active TCP client
			if !clientAddr.IP.Equal(tcpClientIP) {
				log.Printf("Rejected UDP packet from %s (active TCP client: %s)\n", clientAddr, tcpClientIP)
				continue
			}

			// Lock first UDP client (IP:port) once TCP client sends a packet
			if udpClientAddr == nil {
				udpClientAddr = clientAddr
				log.Printf("UDP client locked to: %s\n", udpClientAddr)
			}

			// Reject if wrong port after locking
			if clientAddr.String() != udpClientAddr.String() {
				log.Printf("Rejected UDP packet from %s (only accepting from %s)\n", clientAddr, udpClientAddr)
				continue
			}

			msg := strings.TrimSpace(string(buf[:n]))
			if strings.HasPrefix(msg, MOVE_MOUSE) {
				// Example format: MOVE_MOUSE:10,20
				parts := strings.Split(msg, ":")
				if len(parts) == 2 {
					var dx, dy int
					fmt.Sscanf(parts[1], "%d,%d", &dx, &dy)
					mouse.MoveMouse(dx, dy)
				}
			} else if strings.HasPrefix(msg, SCROLL) {
				var dy int
				fmt.Sscanf(msg, "SCROLL:%d", &dy)
				mouse.Scroll(dy)
			}
		}
	}
}

// ---- Command executor ----
func executeCommand(conn net.Conn, cmd string) {
	log.Printf("Executing command: %s", cmd)
	switch {
	case cmd == VOLUME_UP:
		media.VolumeUp()
	case cmd == VOLUME_DOWN:
		media.VolumeDown()
	case cmd == VOLUME_MUTE:
		media.Mute()
	case cmd == PLAY_PAUSE:
		media.PlayPause()
	case cmd == NEXT_TRACK:
		media.NextTrack()
	case cmd == PREVIOUS_TRACK:
		media.PreviousTrack()
	case cmd == CURRENT_VOLUME:
		vol := media.GetVolume()
		conn.Write([]byte(fmt.Sprintf("%d\n", vol)))
	case strings.HasPrefix(cmd, TYPE+":"):
		text := strings.TrimPrefix(cmd, TYPE+":")
		keyboard.TypeText(text)
	case strings.HasPrefix(cmd, SPECIAL_KEY+":"):
		key := strings.TrimPrefix(cmd, SPECIAL_KEY+":")
		keyboard.SpecialKey(key)
	case cmd == CLICK_LEFT:
		log.Println("Left click")
		mouse.MouseClick(true)
	case cmd == CLICK_RIGHT:
		mouse.MouseClick(false)
	case cmd == MOUSE_DOWN:
		mouse.MouseDown()
	case cmd == MOUSE_UP:
		mouse.MouseUp()
	case cmd == SLEEP:
		powercontrols.SleepPC()
	case cmd == LOCK:
		powercontrols.LockPC()
	case cmd == SHUTDOWN:
		powercontrols.ShutdownPC()
	case cmd == SHOW_BLACK_SCREEN:
		powercontrols.ShowBlackScreen()
	case cmd == CLOSE_BLACK_SCREEN:
		powercontrols.CloseBlackScreen()

	default:
		log.Printf("Unknown command: %s", cmd)
	}
}

func main() {
	// Initialize logger
	logger.Init("logs/app.log")

	go startTCPServer() // your server code
	go startUDPServer() // your server code

	systray.Run(onReady, onExit)
}

func onReady() {
	iconData, err := os.ReadFile("assets/icon64x64.png") // or .ico, .png works too
	if err != nil {
		log.Fatal(err)
	}
	systray.SetIcon(iconData)

	systray.SetTitle("PC Remote Server")
	systray.SetTooltip("Server running")

	localIP := getLocalIP()
	menuIP := systray.AddMenuItem(fmt.Sprintf("IP: %s", localIP), "Local IP")
	menuQuit := systray.AddMenuItem("Quit", "Quit the server")

	go func() {
		for {
			select {
			case <-menuQuit.ClickedCh:
				systray.Quit()
			case <-menuIP.ClickedCh:
				log.Println("IP menu clicked")
			}
		}
	}()
}

func onExit() {
	// clean up
}
