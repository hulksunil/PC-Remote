import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pc_remote_client/app_state.dart';
import 'package:pc_remote_client/command.dart';

class MediaControlPage extends StatefulWidget {
  const MediaControlPage({super.key});

  @override
  State<MediaControlPage> createState() => _MediaControlPageState();
}

class _MediaControlPageState extends State<MediaControlPage> {
  Timer? _holdTimer;
  String currentVolume = "";

  @override
  void initState() {
    super.initState();
    _fetchCurrentVolume(); // Fetch volume when page opens
  }

  void _fetchCurrentVolume() async {
    var appState = context.read<AppState>();
    String response =
        await appState.sendCommandAndGetResponse(Command.currentVolume.value);
    setState(() {
      currentVolume = response;
    });
  }

  void _startSending(AppState appState, String command) {
    appState.sendCommand(command);
    _fetchCurrentVolume();
    _holdTimer = Timer.periodic(const Duration(milliseconds: 150), (_) {
      appState.sendCommand(command);
      _fetchCurrentVolume();
    });
  }

  void _stopSending() {
    _holdTimer?.cancel();
    _holdTimer = null;
    // Optionally, you can fetch the current volume again after stopping
  }

  double _parseVolumeLevel(String volumeString) {
    final volume = int.tryParse(volumeString) ?? 0;
    return (volume.clamp(0, 100)) / 100.0;
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              const Text("Volume", style: TextStyle(fontSize: 20)),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 350),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: _parseVolumeLevel(currentVolume),
                    minHeight: 20,
                    backgroundColor: Colors.grey[300],
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text("$currentVolume%", style: const TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer Circle
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade200,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                ),

                // Play/Pause in center
                ElevatedButton(
                  onPressed: () =>
                      appState.sendCommand(Command.playPause.value),
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(24),
                  ),
                  child: const Icon(Icons.play_arrow, size: 36),
                ),

                // Volume Up
                Positioned(
                  top: 20,
                  child: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTapDown: (_) =>
                          _startSending(appState, Command.volumeUp.value),
                      onTapUp: (_) => _stopSending(),
                      onTapCancel: _stopSending,
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Icon(Icons.volume_up, size: 30),
                      ),
                    ),
                  ),
                ),

                // Volume Down
                Positioned(
                  bottom: 20,
                  child: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTapDown: (_) =>
                          _startSending(appState, Command.volumeDown.value),
                      onTapUp: (_) => _stopSending(),
                      onTapCancel: _stopSending,
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Icon(Icons.volume_down, size: 30),
                      ),
                    ),
                  ),
                ),

                // Previous
                Positioned(
                  left: 20,
                  child: IconButton(
                    icon: const Icon(Icons.skip_previous, size: 30),
                    onPressed: () =>
                        appState.sendCommand(Command.previousTrack.value),
                  ),
                ),

                // Next
                Positioned(
                  right: 20,
                  child: IconButton(
                    icon: const Icon(Icons.skip_next, size: 30),
                    onPressed: () =>
                        appState.sendCommand(Command.nextTrack.value),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          IconButton(
            icon: const Icon(Icons.volume_off, size: 32),
            onPressed: () => appState.sendCommand(Command.volumeMute.value),
          ),
          const Text("Mute", style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
