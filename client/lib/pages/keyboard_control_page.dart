import 'package:client/app/app_state.dart';
import 'package:client/models/command.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class KeyboardControlPage extends StatefulWidget {
  const KeyboardControlPage({super.key});

  @override
  State<KeyboardControlPage> createState() => _KeyboardControlPageState();
}

class _KeyboardControlPageState extends State<KeyboardControlPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late AppState appState;

  String previousText = "";

  @override
  void initState() {
    super.initState();

    // Automatically request focus when the page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });

    // Listen for changes and send to server
    _controller.addListener(() {
      sendLastKey();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appState = context.read<AppState>();
  }

  void sendLastKey() {
    String currentText = _controller.text;
    if (currentText.contains('\n')) {
      appState.sendCommand("${Command.specialKey.value}: ENTER");
      print("Enter pressed");
      _controller.clear();
      return;
    }

    if (currentText.length < previousText.length) {
      // User deleted something
      int deletedCount = previousText.length - currentText.length;
      appState
          .sendCommand("${Command.specialKey.value}:BACKSPACE:$deletedCount");
    } else if (currentText.length > previousText.length) {
      // New characters added
      String newChars = currentText.substring(previousText.length);
      appState.sendCommand("${Command.type.value}:$newChars");
      print('Send to server: $newChars');
    }
    previousText = currentText;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keyboard Input')),
      //  need to make it so that it shows when the ctrl is pressed down and when it is released
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                appState.sendCommand("${Command.specialKey.value}:CTRL");
              },
              child: const Text('CTRL'),
            ),
          ],
        ),
      ),
      body: Center(
        child: Opacity(
          opacity: 1,
          child: TextField(
            focusNode: _focusNode,
            controller: _controller,
            autofocus: true,
            showCursor: false,
            enableSuggestions: true,
            autocorrect: false,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),
      ),
    );
  }
}
