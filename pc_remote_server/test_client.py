import socket
import time

# Server connection details
HOST = '127.0.0.1'  # Localhost
PORT = 5555


def connect_to_server(host, port):
    """Connect to the server."""
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client_socket.connect((host, port))
    print(f"Connected to server {host}:{port}")
    return client_socket


def send_command(client_socket, command):
    """Send a command to the server."""
    client_socket.send(command.encode())
    response = client_socket.recv(1024).decode('utf-8')
    print(f"Server response: {response}")


def main():
    client_socket = connect_to_server(HOST, PORT)

    # Test sending commands
    send_command(client_socket, 'VOLUME_UP')  # Increase volume
    send_command(client_socket, 'VOLUME_UP')  # Increase volume
    send_command(client_socket, 'VOLUME_UP')  # Increase volume
    send_command(client_socket, 'VOLUME_UP')  # Increase volume
    time.sleep(1)
    send_command(client_socket, 'VOLUME_DOWN')  # Decrease volume
    send_command(client_socket, 'VOLUME_DOWN')  # Decrease volume
    send_command(client_socket, 'VOLUME_DOWN')  # Decrease volume
    send_command(client_socket, 'VOLUME_DOWN')  # Decrease volume
    time.sleep(1)
    # mute volume
    send_command(client_socket, 'VOLUME_MUTE')  # Mute volume
    time.sleep(2)
    # unmute volume
    send_command(client_socket, 'VOLUME_MUTE')  # Unmute volume

    # Move mouse to (500, 500)
    send_command(client_socket, 'MOVE_MOUSE:500,500')
    time.sleep(1)
    send_command(client_socket, 'PRESS_KEY:a')  # Press the 'a' key

    # Close the connection after testing
    client_socket.close()


if __name__ == "__main__":
    main()
