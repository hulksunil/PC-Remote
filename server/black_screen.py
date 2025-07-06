import tkinter as tk
from screeninfo import get_monitors
from logger import logger

_root = None
_black_window = None


def open_black_screen():
    """Open a black screen on the second monitor."""
    global _black_window, _root
    if _black_window:
        return  # Already open

    monitors = get_monitors()
    if len(monitors) < 2:
        logger.error("Second monitor not found.")
        return

    second = monitors[1]

    # Create root but keep it hidden
    _root = tk.Tk()
    _root.withdraw()

    _black_window = tk.Toplevel(_root)
    _black_window.configure(bg="black")
    _black_window.overrideredirect(True)  # Removes title bar
    _black_window.geometry(
        f"{second.width}x{second.height}+{second.x}+{second.y}")
    _black_window.lift()
    _black_window.focus_force()

    # Close on ESC or click
    _black_window.bind("<Escape>", lambda e: close_black_screen())
    _black_window.bind("<Button-1>", lambda e: close_black_screen())

    _black_window.mainloop()


def close_black_screen():
    """Close the black screen."""
    global _black_window, _root
    if _black_window:
        _black_window.destroy()
        _black_window = None
    if _root:
        _root.destroy()
        _root = None
