import 'package:pc_remote_client/app/app_state.dart';
import 'package:pc_remote_client/models/command.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    if (currentText.length < previousText.length) {
      // User deleted something
      appState.sendCommand("${Command.specialKey.value}:BACKSPACE");
      print("Backspace sent");
    } else if (currentText.length > previousText.length) {
      final text = _controller.text;
      if (text.isNotEmpty) {
        final lastChar = text.characters.last;
        appState.sendCommand("${Command.type.value}:$lastChar");
        print('Send to server: $lastChar');
      }
    }
    previousText = currentText;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keyboard Input')),
      body: Center(
        child: Opacity(
          opacity: 0,
          child: TextField(
            focusNode: _focusNode,
            controller: _controller,
            autofocus: true,
            showCursor: false,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),
      ),
    );
  }
}
