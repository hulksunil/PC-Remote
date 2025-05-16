enum Command {
  volumeUp,
  volumeDown,
  volumeMute,
  currentVolume,
  playPause,
  nextTrack,
  previousTrack,
  pressKeyA,
}

extension CommandExtension on Command {
  String get value {
    switch (this) {
      case Command.volumeUp:
        return "VOLUME_UP";
      case Command.volumeDown:
        return "VOLUME_DOWN";
      case Command.volumeMute:
        return "VOLUME_MUTE";

      case Command.currentVolume:
        return "CURRENT_VOLUME";

      case Command.playPause:
        return "PLAY_PAUSE";
      case Command.nextTrack:
        return "NEXT_TRACK";
      case Command.previousTrack:
        return "PREVIOUS_TRACK";
      case Command.pressKeyA:
        return "PRESS_KEY:a";
    }
  }
}
