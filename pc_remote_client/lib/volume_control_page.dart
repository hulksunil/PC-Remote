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
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    return Scaffold(
      body: Center(
        child: Column(children: [
          const Text(
            'Volume Control',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => appState.sendCommand(Command.volumeUp.value),
            child: const Text("Volume Up"),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => appState.sendCommand(Command.volumeDown.value),
            child: const Text("Volume Down"),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => appState.sendCommand(Command.volumeMute.value),
            child: const Text("Mute"),
          ),
          ElevatedButton(
            onPressed: () => appState.sendCommand(Command.playPause.value),
            child: const Text("Play/Pause"),
          ),
          ElevatedButton(
            onPressed: () => appState.sendCommand(Command.previousTrack.value),
            child: const Text("<<"),
          ),
          ElevatedButton(
            onPressed: () => appState.sendCommand(Command.nextTrack.value),
            child: const Text(">>"),
          ),
        ]),
      ),
    );
  }
}
