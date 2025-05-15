import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pc_remote_client/app_state.dart';

class KeyboardControlPage extends StatefulWidget {
  const KeyboardControlPage({super.key});
  @override
  State<KeyboardControlPage> createState() => _KeyboardControlPageState();
}

class _KeyboardControlPageState extends State<KeyboardControlPage> {
  final TextEditingController _controller = TextEditingController();
  String _lastText = '';

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      final appState = context.read<AppState>();
      final currentText = _controller.text;

      // Compare new and old text to get the typed character(s)
      if (currentText.length > _lastText.length) {
        final newChar = currentText.substring(_lastText.length);
        appState.sendCommand("TYPE:$newChar");
      } else if (currentText.length < _lastText.length) {
        // User pressed backspace
        appState.sendCommand("BACKSPACE");
      }

      _lastText = currentText;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Keyboard Control',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Type here',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 20),
              const Text(
                'Input is sent to the PC as you type.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
