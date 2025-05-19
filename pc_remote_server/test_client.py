import socket
import time

HOST = '192.168.2.12'  # Change if needed
PORT = 5555


def get_command(choice):
    if choice == '1':
        return "VOLUME_UP"
    elif choice == '2':
        return "VOLUME_DOWN"
    elif choice == '3':
        return "VOLUME_MUTE"
    elif choice == '4':
        x = input("Enter X coordinate: ")
        y = input("Enter Y coordinate: ")
        return f"MOVE_MOUSE:{x},{y}"
    elif choice == '5':
        key = input("Enter key to press (e.g. a, enter, space): ").lower()
        return f"PRESS_KEY:{key}"
    elif choice == '6':
        combo = input("Enter key combo (e.g. ctrl+c): ").lower()
        return f"KEY_COMBO:{combo}"
    elif choice == '7':
        dy = input("Enter int scroll dy: ")
        return f"SCROLL:{dy}"
    elif choice == '8':
        return "SLEEP"
    elif choice == '9':
        return "LOCK"
    elif choice == '10':
        return "SHUTDOWN"
    elif choice == '11':
        return "CLICK_RIGHT"
    elif choice == '12':
        return "CLICK_LEFT"
    return None


def print_menu():
    print("\nSelect a command to send:")
    print("1. Volume Up")
    print("2. Volume Down")
    print("3. Toggle Mute")
    print("4. Move Mouse")
    print("5. Press Single Key")
    print("6. Key Combo")
    print("7. scroll:dy")
    print("8. Sleep")
    print("9. Lock")
    print("10. Shutdown")
    print("11. right click")
    print("12. left click")
    print("0. Exit")


def start_client():
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client_socket.connect((HOST, PORT))
    print(f"Connected to {HOST}:{PORT}")

    try:
        while True:
            print_menu()
            choice = input("Enter number: ").strip()

            if choice == '0':
                print("Closing connection.")
                break

            command = get_command(choice)
            if not command:
                print("Invalid choice. Try again.")
                continue

            print(f"Sending command in 1 second: {command}")
            time.sleep(2)
            client_socket.send(command.encode())
            time.sleep(1)
            # response = client_socket.recv(1024).decode()
            # print(f"Server response: {response}")

    except KeyboardInterrupt:
        print("\nInterrupted by user.")
    finally:
        client_socket.close()


if __name__ == "__main__":
    start_client()
