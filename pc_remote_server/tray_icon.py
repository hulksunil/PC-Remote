# tray_icon.py
import threading
import sys
from PIL import Image, ImageDraw
import pystray
from pystray import MenuItem as item
from black_screen import open_black_screen, close_black_screen
from threading import Thread

_exit_callback = None


def create_icon():
    img = Image.new("RGB", (64, 64), "black")
    draw = ImageDraw.Draw(img)
    draw.rectangle((16, 16, 48, 48), fill="white")
    return img


def start_tray(on_exit_callback, ip_address):
    """Starts the system tray icon with a menu for showing a black screen and exiting."""
    global _exit_callback

    def on_show_black():
        threading.Thread(target=open_black_screen, daemon=True).start()

    def on_exit(icon, item):
        icon.stop()
        if on_exit_callback:
            threading.Thread(target=on_exit_callback).start()

    tooltip = f"PC Remote Server\nIP: {ip_address}"
    menu = (item("Show Black Screen", on_show_black), item("Exit", on_exit))
    icon = pystray.Icon("PCRemote", create_icon(), tooltip, menu)
    threading.Thread(target=icon.run, daemon=True).start()
