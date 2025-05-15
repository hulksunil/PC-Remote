import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pc_remote_client/app_state.dart';
import 'package:pc_remote_client/command.dart';

class VolumeControlPage extends StatelessWidget {
  const VolumeControlPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => appState.sendCommand(Command.volumeMute.value),
      //   tooltip: 'Mute',
      //   child: const Icon(Icons.volume_off),
      // ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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

                // Play/Pause in the center
                ElevatedButton(
                  onPressed: () =>
                      appState.sendCommand(Command.playPause.value),
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(24),
                  ),
                  child: const Icon(Icons.play_arrow, size: 36),
                ),

                // Volume Up (Top)
                Positioned(
                  top: 20,
                  child: IconButton(
                    icon: const Icon(Icons.volume_up, size: 30),
                    onPressed: () =>
                        appState.sendCommand(Command.volumeUp.value),
                  ),
                ),

                // Volume Down (Bottom)
                Positioned(
                  bottom: 20,
                  child: IconButton(
                    icon: const Icon(Icons.volume_down, size: 30),
                    onPressed: () =>
                        appState.sendCommand(Command.volumeDown.value),
                  ),
                ),

                // Previous Track (Left)
                Positioned(
                  left: 20,
                  child: IconButton(
                    icon: const Icon(Icons.skip_previous, size: 30),
                    onPressed: () =>
                        appState.sendCommand(Command.previousTrack.value),
                  ),
                ),

                // Next Track (Right)
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

          const SizedBox(height: 20),

          // Volume Slider

          // mute Button
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
