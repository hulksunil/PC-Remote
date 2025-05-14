import socket
import pyautogui
from enum import Enum
from media_controls import MediaControls


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
    PRESS_KEY = 'PRESS_KEY'
    MOVE_MOUSE = 'MOVE_MOUSE'
    CLICK_LEFT = 'CLICK_LEFT'
    CLICK_RIGHT = 'CLICK_RIGHT'

    def __str__(self):
        return self.value


def handle_client(client_socket):
    """Handles the client connection and receives data."""
    # volume = setup_volume()  # Initialize volume control

    while True:
        try:
            print("Waiting to receive commands...")
            # Receive the command from the client
            response = client_socket.recv(1024)

            if not response:
                print("Client disconnected")
                break

            command = response.decode('utf-8').upper()
            if command:
                print(f"Received command: {command}")
                if command == str(Command.VOLUME_UP):
                    # adjust_volume(volume, 0.25)  # Increase volume by 2%
                    MediaControls.volume_up()
                    client_socket.send("Volume increased by 2%".encode())
                elif command == str(Command.VOLUME_DOWN):
                    # adjust_volume(volume, -0.25)  # Decrease volume by 2%
                    MediaControls.volume_down()
                    client_socket.send("Volume decreased by 2%".encode())
                elif command == str(Command.VOLUME_MUTE):
                    MediaControls.volume_mute()
                    client_socket.send("Toggled mute".encode())
                elif command == str(Command.PLAY_PAUSE):
                    MediaControls.send_media_play_pause()
                    client_socket.send("Toggled play/pause".encode())
                elif command == str(Command.NEXT_TRACK):
                    MediaControls.send_media_next_track()
                    client_socket.send("Next track".encode())
                elif command == str(Command.PREVIOUS_TRACK):
                    MediaControls.send_media_previous_track()
                    client_socket.send("Previous track".encode())
                elif command.startswith(str(Command.MOVE_MOUSE)):
                    # we need to separate the individual commands by the ; first

                    individual_commands = command.split(';')
                    for individual_command in individual_commands:
                        if individual_command.strip():
                            # Move mouse to a specific position
                            x, y = map(int, individual_command.split(
                                ':')[1].split(','))
                            pyautogui.moveRel(x, y)

                elif command.startswith(str(Command.PRESS_KEY)):
                    key = command.split(':')[1]
                    pyautogui.press(key)
                    client_socket.send(f"Pressed {key}".encode())
                elif command == str(Command.CLICK_LEFT):
                    pyautogui.click()
                    client_socket.send("Left mouse button clicked".encode())
                elif command == str(Command.CLICK_RIGHT):
                    pyautogui.click(button='right')
                    client_socket.send("Right mouse button clicked".encode())
            else:
                break
        except Exception as e:
            print(f"Error: {e}")
            break

    client_socket.close()


def start_server():
    """Starts the server and listens for incoming connections."""
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.bind((HOST, PORT))
    server.listen()  # Only accept 1 client
    print(f"Server listening on {get_local_ip()}:{PORT}")

    # Accept a connection from a client (this will wait until a client connects)
    while True:
        print("Waiting for a new client...")
        client_socket, addr = server.accept()
        print(f"Connection from {addr}")
        handle_client(client_socket)


if __name__ == "__main__":
    start_server()
