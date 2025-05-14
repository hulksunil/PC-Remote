import ctypes
# from pycaw.pycaw import AudioUtilities, IAudioEndpointVolume


# Define the constants for media keys
MEDIA_PLAY_PAUSE = 0xB3
MEDIA_NEXT_TRACK = 0xB0
MEDIA_PREVIOUS_TRACK = 0xB1
KEYEVENTF_KEYUP = 0x0002


class MediaControls:
    @staticmethod
    def send_media_play_pause():
        """Simulate Play/Pause media key press."""
        ctypes.windll.user32.keybd_event(MEDIA_PLAY_PAUSE, 0, 0, 0)  # Key down
        ctypes.windll.user32.keybd_event(
            MEDIA_PLAY_PAUSE, 0, KEYEVENTF_KEYUP, 0)  # Key up
        print("Play/Pause key sent.")

    @staticmethod
    def send_media_next_track():
        """Simulate Next Track media key press."""
        ctypes.windll.user32.keybd_event(MEDIA_NEXT_TRACK, 0, 0, 0)  # Key down
        ctypes.windll.user32.keybd_event(
            MEDIA_NEXT_TRACK, 0, KEYEVENTF_KEYUP, 0)  # Key up
        print("Next Track key sent.")

    @staticmethod
    def send_media_previous_track():
        """Simulate Previous Track media key press."""
        ctypes.windll.user32.keybd_event(
            MEDIA_PREVIOUS_TRACK, 0, 0, 0)  # Key down
        ctypes.windll.user32.keybd_event(
            MEDIA_PREVIOUS_TRACK, 0, KEYEVENTF_KEYUP, 0)  # Key up
        print("Previous Track key sent.")

    @staticmethod
    def volume_up():
        """Simulate volume up key press."""
        ctypes.windll.user32.keybd_event(
            0xAF, 0, 0, 0)  # VK_VOLUME_UP key down
        ctypes.windll.user32.keybd_event(
            0xAF, 0, KEYEVENTF_KEYUP, 0)  # VK_VOLUME_UP key up

    @staticmethod
    def volume_down():
        """Simulate volume down key press."""
        ctypes.windll.user32.keybd_event(
            0xAE, 0, 0, 0)  # VK_VOLUME_DOWN key down
        ctypes.windll.user32.keybd_event(
            0xAE, 0, KEYEVENTF_KEYUP, 0)  # VK_VOLUME_DOWN key up

    @staticmethod
    def volume_mute():
        """Simulate volume mute key press."""
        ctypes.windll.user32.keybd_event(0xAD, 0, 0, 0)  # VK_VOLUME_MUTE down
        ctypes.windll.user32.keybd_event(
            0xAD, 0, KEYEVENTF_KEYUP, 0)  # VK_VOLUME_MUTE up


# Simulate system volume keys (shows Windows volume overlay)


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
