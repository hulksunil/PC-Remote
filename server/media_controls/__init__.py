import platform

system = platform.system()

if system == "Windows":
    from .media_win import MediaControls
elif system == "Darwin":
    from .media_mac import MediaControls
else:
    raise NotImplementedError(f"Media controls not implemented for {system}")
