enum Command {
  volumeUp,
  volumeDown,
  volumeMute,
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
      case Command.pressKeyA:
        return "PRESS_KEY:a";
    }
  }
}
