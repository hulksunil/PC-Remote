import subprocess
from logger import logger


class MediaControls:
    # TODO(sunil): Fix Play/Pause key macOS
    @staticmethod
    def send_media_play_pause():
        subprocess.run(
            ["osascript", "-e", 'tell application "System Events" to key code 16 using {command down}'])
        logger.debug("Play/Pause key sent (macOS).")

    # TODO(sunil): Fix Next Track key macOS
    @staticmethod
    def send_media_next_track():
        subprocess.run(
            ["osascript", "-e", 'tell application "System Events" to key code 124 using {command down}'])
        logger.debug("Next Track key sent (macOS).")

    # TODO(sunil): Fix Previous Track key macOS
    @staticmethod
    def send_media_previous_track():
        subprocess.run(
            ["osascript", "-e", 'tell application "System Events" to key code 123 using {command down}'])
        logger.debug("Previous Track key sent (macOS).")

    @staticmethod
    def volume_up():
        subprocess.run(
            ["osascript", "-e", 'set volume output volume ((output volume of (get volume settings)) + 6) --100%'])
        logger.debug("Volume up (macOS).")

    @staticmethod
    def volume_down():
        subprocess.run(
            ["osascript", "-e", 'set volume output volume ((output volume of (get volume settings)) - 6) --100%'])
        logger.debug("Volume down (macOS).")

    # TODO(sunil): Fix Mute to make it unmute as well
    @staticmethod
    def volume_mute():
        subprocess.run(["osascript", "-e", 'set volume with output muted'])
        logger.debug("Volume muted (macOS).")

    @staticmethod
    def get_volume():
        result = subprocess.run(
            ["osascript", "-e", 'output volume of (get volume settings)'],
            capture_output=True, text=True
        )
        try:
            vol = int(result.stdout.strip())
        except ValueError:
            vol = 0
        logger.info(f"Current volume level: {vol}")
        return vol
