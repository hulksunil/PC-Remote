enum Command {
  volumeUp,
  volumeDown,
  volumeMute,
  currentVolume,
  playPause,
  nextTrack,
  previousTrack,
  clickLeft,
  clickRight,
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
      case Command.clickLeft:
        return "CLICK_LEFT";
      case Command.clickRight:
        return "CLICK_RIGHT";
    }
  }
}
