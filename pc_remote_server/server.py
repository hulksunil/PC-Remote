import socket
import pyautogui
from enum import Enum
import ctypes
# from pycaw.pycaw import AudioUtilities, IAudioEndpointVolume


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


# Constants for key events
KEYEVENTF_KEYUP = 0x0002
MEDIA_PLAY_PAUSE = 0xB3  # Play/Pause media key
MEDIA_NEXT_TRACK = 0xB0  # Next Track media key
MEDIA_PREVIOUS_TRACK = 0xB1  # Previous Track media key
user32 = ctypes.WinDLL('user32', use_last_error=True)


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


# Simulate system volume keys (shows Windows volume overlay)

def send_media_play_pause():
    """Simulate Play/Pause media key press."""
    user32.keybd_event(MEDIA_PLAY_PAUSE, 0, 0, 0)  # Key down
    ctypes.windll.user32.keybd_event(
        MEDIA_PLAY_PAUSE, 0, KEYEVENTF_KEYUP, 0)  # Key up
    print("Play/Pause key sent.")


def send_media_next_track():
    """Simulate Next Track media key press."""
    user32.keybd_event(MEDIA_NEXT_TRACK, 0, 0, 0)  # Key down
    ctypes.windll.user32.keybd_event(
        MEDIA_NEXT_TRACK, 0, KEYEVENTF_KEYUP, 0)  # Key up
    print("Next Track key sent.")


def send_media_previous_track():
    """Simulate Previous Track media key press."""
    user32.keybd_event(MEDIA_PREVIOUS_TRACK, 0, 0, 0)  # Key down
    ctypes.windll.user32.keybd_event(
        MEDIA_PREVIOUS_TRACK, 0, KEYEVENTF_KEYUP, 0)  # Key up
    print("Previous Track key sent.")


def volume_up():
    """Simulate volume up key press."""
    ctypes.windll.user32.keybd_event(0xAF, 0, 0, 0)  # VK_VOLUME_UP key down
    ctypes.windll.user32.keybd_event(
        0xAF, 0, KEYEVENTF_KEYUP, 0)  # VK_VOLUME_UP key up


def volume_down():
    """Simulate volume down key press."""
    ctypes.windll.user32.keybd_event(0xAE, 0, 0, 0)  # VK_VOLUME_DOWN key down
    ctypes.windll.user32.keybd_event(
        0xAE, 0, KEYEVENTF_KEYUP, 0)  # VK_VOLUME_DOWN key up


def volume_mute():
    """Simulate volume mute key press."""
    ctypes.windll.user32.keybd_event(0xAD, 0, 0, 0)  # VK_VOLUME_MUTE down
    ctypes.windll.user32.keybd_event(
        0xAD, 0, KEYEVENTF_KEYUP, 0)  # VK_VOLUME_MUTE up

# Master control of volume with no interface
# def setup_volume():
#     """Set up and return volume control interface."""
#     devices = AudioUtilities.GetSpeakers()
#     interface = devices.Activate(IAudioEndpointVolume._iid_, 1, None)
#     return interface.QueryInterface(IAudioEndpointVolume)


# def adjust_volume(volume, increment):
#     """Adjust the volume by a specific increment (e.g., 2%)."""
#     current_volume = volume.GetMasterVolumeLevelScalar(
#     )  # Get the current volume as a scalar (0.0 to 1.0)
#     new_volume = current_volume + increment
#     # Ensure the volume stays between 0 and 1
#     new_volume = max(0.0, min(new_volume, 1.0))
#     volume.SetMasterVolumeLevelScalar(
#         new_volume, None)  # Set the new volume level


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
                    volume_up()
                    client_socket.send("Volume increased by 2%".encode())
                elif command == str(Command.VOLUME_DOWN):
                    # adjust_volume(volume, -0.25)  # Decrease volume by 2%
                    volume_down()
                    client_socket.send("Volume decreased by 2%".encode())
                elif command == str(Command.VOLUME_MUTE):
                    volume_mute()
                    client_socket.send("Toggled mute".encode())
                elif command == str(Command.PLAY_PAUSE):
                    send_media_play_pause()
                    client_socket.send("Toggled play/pause".encode())
                elif command == str(Command.NEXT_TRACK):
                    send_media_next_track()
                    client_socket.send("Next track".encode())
                elif command == str(Command.PREVIOUS_TRACK):
                    send_media_previous_track()
                    client_socket.send("Previous track".encode())
                elif command.startswith(str(Command.MOVE_MOUSE)):
                    x, y = map(int, command.split(':')[1].split(','))
                    pyautogui.moveRel(x, y)
                    client_socket.send(f"Moved mouse to ({x}, {y})".encode())
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
