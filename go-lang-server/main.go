package main

import (
	"fmt"
	"log"
	"net"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"

	"github.com/go-vgo/robotgo"
)

// Globals
var (
	HOST           = "0.0.0.0"
	PORT           = 5555
	UDP_PORT       = 5556
	shutdownSignal = make(chan struct{})
	currentClient  net.Conn
)

// Command enum equivalent
const (
	VOLUME_UP        = "VOLUME_UP"
	VOLUME_DOWN      = "VOLUME_DOWN"
	VOLUME_MUTE      = "VOLUME_MUTE"
	PLAY_PAUSE       = "PLAY_PAUSE"
	NEXT_TRACK       = "NEXT_TRACK"
	PREVIOUS_TRACK   = "PREVIOUS_TRACK"
	CURRENT_VOLUME   = "CURRENT_VOLUME"
	MOVE_MOUSE       = "MOVE_MOUSE"
	MOUSE_DOWN       = "MOUSE_DOWN"
	MOUSE_UP         = "MOUSE_UP"
	CLICK_LEFT       = "CLICK_LEFT"
	CLICK_RIGHT      = "CLICK_RIGHT"
	SCROLL           = "SCROLL"
	SLEEP            = "SLEEP"
	LOCK             = "LOCK"
	SHUTDOWN         = "SHUTDOWN"
	SHOW_BLACK_SCREEN = "SHOW_BLACK_SCREEN"
	CLOSE_BLACK_SCREEN = "CLOSE_BLACK_SCREEN"
	TYPE             = "TYPE"
	SPECIAL_KEY      = "SPECIAL_KEY"
)

// ---- Stubbed platform functions ----
func VolumeUp()          { log.Println("Volume up (stub)") }
func VolumeDown()        { log.Println("Volume down (stub)") }
func VolumeMute()        { log.Println("Volume mute (stub)") }
func PlayPause()         { log.Println("Play/Pause (stub)") }
func NextTrack()         { log.Println("Next track (stub)") }
func PreviousTrack()     { log.Println("Previous track (stub)") }
func GetVolume() int     { return 50 } // stub
func SleepPC()           { log.Println("Sleep PC (stub)") }
func LockPC()            { log.Println("Lock PC (stub)") }
func ShutdownPC()        { log.Println("Shutdown PC (stub)") }
func ShowBlackScreen()   { log.Println("Show black screen (stub)") }
func CloseBlackScreen()  { log.Println("Close black screen (stub)") }



// Mouse
func MoveMouse(dx, dy int) {
	x, y := robotgo.Location()
	robotgo.Move(x+dx, y+dy)
}
func Scroll(dy int) {
	if dy < 0 {
		robotgo.ScrollDir(-dy, "down")
	} else {
		robotgo.ScrollDir(dy, "up")
	}
}
func MouseClick(left bool) {
    if left {
        robotgo.Click("left")
    } else {
        robotgo.Click("right")
    }
}
func MouseDown() {
    robotgo.Toggle("left", "down")
}
func MouseUp() {
    robotgo.Toggle("left", "up")
}

// Keyboard
func TypeText(text string) {
    robotgo.TypeStr(text)
}
func SpecialKey(key string) {
    switch key {
    case "BACKSPACE":
        robotgo.KeyTap("backspace")
    case "ENTER":
        robotgo.KeyTap("enter")
    case "ESCAPE":
        robotgo.KeyTap("escape")
    case "TAB":
        robotgo.KeyTap("tab")
    case "CTRL":
        robotgo.KeyToggle("ctrl", "down")
    case "CTRL_RELEASE":
        robotgo.KeyToggle("ctrl", "up")
    default:
        log.Printf("Unknown special key: %s", key)
    }
}

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
			conn, err := listener.Accept()
			if err != nil {
				if ne, ok := err.(net.Error); ok && ne.Timeout() {
					continue
				}
				log.Printf("Accept error: %v", err)
				continue
			}

			if currentClient != nil {
				log.Printf("Rejected client: %s (already connected)\n", conn.RemoteAddr())
				conn.Close()
				continue
			}

			currentClient = conn
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
			n, _, err := conn.ReadFromUDP(buf)
			if err != nil {
				if ne, ok := err.(net.Error); ok && ne.Timeout() {
					continue
				}
				log.Printf("UDP read error: %v", err)
				return
			}
			msg := strings.TrimSpace(string(buf[:n]))
			if strings.HasPrefix(msg, MOVE_MOUSE) {
				// Example format: MOVE_MOUSE:10,20
				parts := strings.Split(msg, ":")
				if len(parts) == 2 {
					var dx, dy int
					fmt.Sscanf(parts[1], "%d,%d", &dx, &dy)
					MoveMouse(dx, dy)
				}
			} else if strings.HasPrefix(msg, SCROLL) {
				var dy int
				fmt.Sscanf(msg, "SCROLL:%d", &dy)
				Scroll(dy)
			}
		}
	}
}

// ---- Command executor ----
func executeCommand(conn net.Conn, cmd string) {
	log.Printf("Executing command: %s", cmd)
	switch {
	case cmd == VOLUME_UP:
		VolumeUp()
	case cmd == VOLUME_DOWN:
		VolumeDown()
	case cmd == VOLUME_MUTE:
		VolumeMute()
	case cmd == PLAY_PAUSE:
		PlayPause()
	case cmd == NEXT_TRACK:
		NextTrack()
	case cmd == PREVIOUS_TRACK:
		PreviousTrack()
	case cmd == CURRENT_VOLUME:
		vol := GetVolume()
		conn.Write([]byte(fmt.Sprintf("%d\n", vol)))
	case strings.HasPrefix(cmd, TYPE+":"):
		text := strings.TrimPrefix(cmd, TYPE+":")
		TypeText(text)
	case strings.HasPrefix(cmd, SPECIAL_KEY+":"):
		key := strings.TrimPrefix(cmd, SPECIAL_KEY+":")
		SpecialKey(key)
	case cmd == CLICK_LEFT:
		log.Println("Left click")
		MouseClick(true)
	case cmd == CLICK_RIGHT:
		MouseClick(false)
	case cmd == SLEEP:
		SleepPC()
	case cmd == LOCK:
		LockPC()
	case cmd == SHUTDOWN:
		ShutdownPC()
	case cmd == SHOW_BLACK_SCREEN:
		ShowBlackScreen()
	case cmd == CLOSE_BLACK_SCREEN:
		CloseBlackScreen()
	case cmd == MOUSE_DOWN:
		MouseDown()
	case cmd == MOUSE_UP:
		MouseUp()
	default:
		log.Printf("Unknown command: %s", cmd)
	}
}

// ---- Main ----
func main() {
	// Handle signals for graceful shutdown
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)

	go startUDPServer()
	go startTCPServer()

	<-sigChan
	log.Println("Exiting...")

	close(shutdownSignal)
	if currentClient != nil {
		currentClient.Close()
	}
	CloseBlackScreen()
}
