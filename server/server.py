import signal
import sys
from tray_icon import start_tray
import socket
import pyautogui
from enum import Enum
from media_controls import MediaControls
from power_controls import PowerControls
from black_screen import close_black_screen, open_black_screen

import threading
from logger import logger


pyautogui.FAILSAFE = False  # Disable fail-safe to prevent mouse movement issues
current_client_socket = None
server_socket = None
shutdown_event = threading.Event()


def get_local_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        # Doesn't actually connect, just triggers routing to get local IP
        s.connect(('8.8.8.8', 80))
        ip = s.getsockname()[0]
    except Exception:
        ip = '127.0.0.1'  # Fallback to localhost
    finally:
        s.close()
    return ip


def start_tcp_server():
    global server_socket
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server_socket.settimeout(1.0)  # timeout every 1 second
    server_socket.bind((HOST, PORT))
    server_socket.listen()
    logger.info(f"TCP Server listening on {get_local_ip()}:{PORT}")

    waiting_printed = False

    # Accept a connection from a client (this will wait until a client connects)
    while not shutdown_event.is_set():
        try:
            if not waiting_printed:
                logger.info("Waiting for a new client...")
                waiting_printed = True
            client_socket, addr = server_socket.accept()
            waiting_printed = False  # Reset waiting printed flag for next client connection
            logger.info(f"TCP Connection from {addr}")
            handle_client(client_socket)
        except socket.timeout:
            continue
        except OSError:
            break  # Server socket was closed


# Listen on all interfaces (lets us use either 192.168.1.x or localhost for client)
HOST = '0.0.0.0'
PORT = 5555


class Command(Enum):
    """Enum for defining commands."""
    VOLUME_UP = 'VOLUME_UP'
    VOLUME_DOWN = 'VOLUME_DOWN'
    VOLUME_MUTE = 'VOLUME_MUTE'
    PLAY_PAUSE = 'PLAY_PAUSE'
    NEXT_TRACK = 'NEXT_TRACK'
    PREVIOUS_TRACK = 'PREVIOUS_TRACK'
    CURRENT_VOLUME = 'CURRENT_VOLUME'
    MOVE_MOUSE = 'MOVE_MOUSE'
    MOUSE_DOWN = 'MOUSE_DOWN'
    MOUSE_UP = 'MOUSE_UP'
    CLICK_LEFT = 'CLICK_LEFT'
    CLICK_RIGHT = 'CLICK_RIGHT'
    SCROLL = 'SCROLL'
    SLEEP = 'SLEEP'
    LOCK = 'LOCK'
    SHUTDOWN = 'SHUTDOWN'
    SHOW_BLACK_SCREEN = 'SHOW_BLACK_SCREEN'
    CLOSE_BLACK_SCREEN = 'CLOSE_BLACK_SCREEN'
    TYPE = 'TYPE'
    SPECIAL_KEY = 'SPECIAL_KEY'

    def __str__(self):
        return self.value


def start_udp_mouse_server():
    udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    # Set a timeout for the UDP socket to avoid blocking
    udp_socket.settimeout(1.0)
    try:
        udp_socket.bind((HOST, 5556))
    except OSError as e:
        logger.error(f"Error binding UDP socket: {e}")
        shutdown_event.set()
    logger.info("UDP Mouse server listening on port 5556")

    while not shutdown_event.is_set():
        try:
            data, addr = udp_socket.recvfrom(1024)
        except socket.timeout:
            continue
        except OSError:
            logger.error("UDP server socket closed")
            break
        command = data.decode().strip()
        if command.startswith("MOVE_MOUSE"):
            try:
                individual_commands = command.split(';')
                for individual_command in individual_commands:
                    if individual_command.strip():
                        # Move mouse to a specific position
                        x, y = map(int, individual_command.split(
                            ':')[1].split(','))
                        pyautogui.moveRel(x, y)
            except Exception as e:
                logger.error(f"Error handling UDP mouse move: {e}")

        elif command.startswith(str(Command.SCROLL)):
            individual_commands = command.split(';')
            for individual_command in individual_commands:
                _, dy = command.split(":")
                dy = int(dy.strip(";"))
                if abs(dy) > 1:
                    pyautogui.scroll(dy)
                    logger.info(f"Scrolling: dy={dy}")


def handle_client(client_socket):
    """Handles the client connection and receives data."""
    # volume = setup_volume()  # Initialize volume control
    global current_client_socket
    current_client_socket = client_socket
    # Set a timeout for the socket so we can periodically check for shutdown
    client_socket.settimeout(1.0)

    waiting_printed = False

    try:
        while not shutdown_event.is_set():
            try:
                if not waiting_printed:
                    logger.info("Waiting to receive commands...")
                    waiting_printed = True
                # Receive the command from the client
                response = client_socket.recv(1024)
                waiting_printed = False  # Reset waiting printed flag after receiving data

                if not response:
                    logger.info("Client disconnected")
                    break

                command = response.decode('utf-8')
                if command:
                    logger.info(f"Received command: {command}")
                    if command == str(Command.VOLUME_UP):
                        MediaControls.volume_up()
                    elif command == str(Command.VOLUME_DOWN):
                        MediaControls.volume_down()
                    elif command == str(Command.VOLUME_MUTE):
                        MediaControls.volume_mute()
                    elif command == str(Command.PLAY_PAUSE):
                        MediaControls.send_media_play_pause()
                    elif command == str(Command.NEXT_TRACK):
                        MediaControls.send_media_next_track()
                    elif command == str(Command.PREVIOUS_TRACK):
                        MediaControls.send_media_previous_track()
                    elif command == str(Command.CURRENT_VOLUME):
                        volume_level = MediaControls.get_volume()  # Get current volume level
                        client_socket.send(f"{volume_level}".encode())

                    elif command.startswith(str(Command.TYPE)):
                        key = command.split(':')[1]
                        pyautogui.typewrite(key)
                    elif command.startswith(str(Command.SPECIAL_KEY)):
                        special_key = command.split(':')[1]
                        if special_key == "BACKSPACE":
                            numPresses = command.split(':')[2]
                            pyautogui.press(
                                'backspace', presses=int(numPresses))
                        elif special_key == "ENTER":
                            pyautogui.press('enter')
                        elif special_key == "ESCAPE":
                            pyautogui.press('escape')
                        elif special_key == "TAB":
                            pyautogui.press('tab')
                        elif special_key == "CTRL":
                            pyautogui.keyDown('ctrl')
                        elif special_key == "CTRL_RELEASE":
                            pyautogui.keyUp('ctrl')
                    elif command == str(Command.CLICK_LEFT):
                        pyautogui.click()
                    elif command == str(Command.CLICK_RIGHT):
                        pyautogui.click(button='right')
                    elif command == str(Command.SLEEP):
                        PowerControls.sleep()
                    elif command == str(Command.LOCK):
                        PowerControls.lock()
                    elif command == str(Command.SHUTDOWN):
                        PowerControls.shutdown()
                    elif command == str(Command.SHOW_BLACK_SCREEN):
                        logger.info("Opening black screen")
                        threading.Thread(target=open_black_screen,
                                         daemon=True).start()
                    elif command == str(Command.CLOSE_BLACK_SCREEN):

                        close_black_screen()
                    elif command == str(Command.MOUSE_DOWN):
                        pyautogui.mouseDown()
                    elif command == str(Command.MOUSE_UP):
                        pyautogui.mouseUp()
                    else:
                        logger.info(f"Unknown command: {command}")
                        break
            except socket.timeout:
                continue
            except Exception as e:
                logger.error(f"Error: {e}")
    finally:
        logger.info("Closing client socket")
        try:
            client_socket.shutdown(socket.SHUT_RDWR)
        except:
            pass
        client_socket.close()
        current_client_socket = None


def start_server():
    """Starts the server and listens for incoming connections."""

    # Start the UDP mouse movement server in a background thread
    udp_thread = threading.Thread(target=start_udp_mouse_server, daemon=True)
    udp_thread.start()

    start_tcp_server()


def graceful_exit(*args):
    global current_client_socket, server_socket
    logger.info("Exiting...")

    shutdown_event.set()  # Signal threads to stop

    if current_client_socket:
        try:
            current_client_socket.shutdown(socket.SHUT_RDWR)
            current_client_socket.close()
            logger.info("Client socket closed.")
        except Exception as e:
            logger.error(f"Error closing client socket: {e}")

    if server_socket:
        try:
            server_socket.close()
            logger.info("Server socket closed.")
        except Exception as e:
            logger.error(f"Error closing server socket: {e}")

    close_black_screen()
    sys.exit(0)


if __name__ == "__main__":
    signal.signal(signal.SIGINT, graceful_exit)
    signal.signal(signal.SIGTERM, graceful_exit)
    ip = get_local_ip()
    start_tray(graceful_exit, ip)
    start_server()
