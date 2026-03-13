enum Command {
  volumeUp,
  volumeDown,
  volumeMute,
  currentVolume,
  playPause,
  nextTrack,
  previousTrack,
  streamPlayPause,
  seekBack10,
  seekForward10,
  skipIntro,
  nextEpisode,
  toggleFullscreen,
  streamMute,
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
      case Command.streamPlayPause:
        return "STREAM_PLAY_PAUSE";
      case Command.seekBack10:
        return "SEEK_BACK_10";
      case Command.seekForward10:
        return "SEEK_FORWARD_10";
      case Command.skipIntro:
        return "SKIP_INTRO";
      case Command.nextEpisode:
        return "NEXT_EPISODE";
      case Command.toggleFullscreen:
        return "TOGGLE_FULLSCREEN";
      case Command.streamMute:
        return "STREAM_MUTE";
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
