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
  mouseUp,
  mouseDown,
  sleep,
  shutdown,
  lock,
  showBlackScreen,
  type,
  specialKey
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
      case Command.mouseUp:
        return "MOUSE_UP";
      case Command.mouseDown:
        return "MOUSE_DOWN";

      case Command.sleep:
        return "SLEEP";
      case Command.shutdown:
        return "SHUTDOWN";
      case Command.lock:
        return "LOCK";
      case Command.showBlackScreen:
        return "SHOW_BLACK_SCREEN";

      case Command.type:
        return "TYPE";
      case Command.specialKey:
        return "SPECIAL_KEY";
    }
  }
}
