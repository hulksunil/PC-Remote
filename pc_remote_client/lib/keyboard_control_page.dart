import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pc_remote_client/app_state.dart';
import 'package:pc_remote_client/command.dart';

class KeyboardControlPage extends StatefulWidget {
  const KeyboardControlPage({super.key});
  @override
  State<KeyboardControlPage> createState() => _KeyboardControlPageState();
}

class _KeyboardControlPageState extends State<KeyboardControlPage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    return Scaffold(
      body: Center(
        child: Column(children: [
          const Text(
            'Keyboard Control',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: () => appState.sendCommand(Command.pressKeyA.value),
              child: const Text("Press 'a'")),
        ]),
      ),
    );
  }
}
