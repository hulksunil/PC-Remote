import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pc_remote_client/app_state.dart';
import 'package:pc_remote_client/command.dart';

class VolumeControlPage extends StatefulWidget {
  const VolumeControlPage({super.key});

  @override
  State<VolumeControlPage> createState() => _VolumeControlPageState();
}

class _VolumeControlPageState extends State<VolumeControlPage> {
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
    _holdTimer = Timer.periodic(const Duration(milliseconds: 150), (_) {
      appState.sendCommand(command);
      _fetchCurrentVolume();
    });
  }

  void _stopSending() {
    _holdTimer?.cancel();
    _holdTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Volume Level: $currentVolume",
            style: const TextStyle(fontSize: 24),
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
