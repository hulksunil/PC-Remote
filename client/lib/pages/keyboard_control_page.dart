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
  static String _sessionComposer = '';
  static const int _minLocalBufferLength = 24;
  static const int _bufferTopUpLength = 48;
  static const String _bufferChar = '\u2060';

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _previousText = '';
  bool _isApplyingProgrammaticText = false;
  bool _ctrlHeld = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_processTextDiff);
    _restoreComposer();
    _topUpLocalBuffer();
  }

  @override
  void dispose() {
    _sessionComposer = _controller.text;

    if (_ctrlHeld) {
      context.read<AppState>().sendCommand(
            '${Command.specialKey.value}:CTRL_RELEASE',
          );
    }

    _controller.removeListener(_processTextDiff);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _restoreComposer() {
    if (_sessionComposer.isEmpty) {
      _previousText = '';
      return;
    }

    _isApplyingProgrammaticText = true;
    _controller.text = _sessionComposer;
    _controller.selection = TextSelection.collapsed(
      offset: _sessionComposer.length,
    );
    _isApplyingProgrammaticText = false;
    _previousText = _sessionComposer;
  }

  String _bufferChars(int count) => List.filled(count, _bufferChar).join();

  void _topUpLocalBuffer() {
    if (_controller.text.length >= _minLocalBufferLength) return;

    _isApplyingProgrammaticText = true;
    _controller.text = '${_controller.text}${_bufferChars(_bufferTopUpLength)}';
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
    _isApplyingProgrammaticText = false;

    _previousText = _controller.text;
    _sessionComposer = _controller.text;
  }

  void _sendSpecialKey(String key) {
    context.read<AppState>().sendCommand('${Command.specialKey.value}:$key');
  }

  void _sendBackspaces(int count) {
    for (var i = 0; i < count; i++) {
      _sendSpecialKey('BACKSPACE');
    }
  }

  void _sendTextWithNewlines(String text) {
    if (text.isEmpty) return;

    final appState = context.read<AppState>();
    final parts = text.split('\n');

    for (var i = 0; i < parts.length; i++) {
      final part = parts[i];
      if (part.isNotEmpty) {
        appState.sendCommand('${Command.type.value}:$part');
      }
      if (i < parts.length - 1) {
        _sendSpecialKey('ENTER');
      }
    }
  }

  void _processTextDiff() {
    if (_isApplyingProgrammaticText || !mounted) return;

    final currentText = _controller.text;
    final currentSelection = _controller.selection;

    // Keep the input append-only: if caret is moved (e.g. spacebar trackpad),
    // snap it back to the end before processing edits.
    if (currentSelection.isValid &&
        (currentSelection.baseOffset != currentText.length ||
            currentSelection.extentOffset != currentText.length)) {
      _lockCaretToEnd();
      return;
    }
    if (currentText == _previousText) return;

    // Accept only tail appends and tail deletions.
    // If an unexpected mid-text edit happens, revert to previous state.
    final isAppend = currentText.length >= _previousText.length &&
        currentText.startsWith(_previousText);
    final isTailDelete = currentText.length < _previousText.length &&
        _previousText.startsWith(currentText);

    if (!isAppend && !isTailDelete) {
      _isApplyingProgrammaticText = true;
      _controller.text = _previousText;
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
      _isApplyingProgrammaticText = false;
      return;
    }

    final removedCount =
        isTailDelete ? (_previousText.length - currentText.length) : 0;
    final insertedText =
        isAppend ? currentText.substring(_previousText.length) : '';

    if (removedCount > 0) {
      _sendBackspaces(removedCount);
    }

    if (insertedText.isNotEmpty) {
      _sendTextWithNewlines(insertedText);
    }

    _previousText = currentText;
    _sessionComposer = currentText;
    _topUpLocalBuffer();
    _lockCaretToEnd();
  }

  void _lockCaretToEnd() {
    _isApplyingProgrammaticText = true;
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
    _isApplyingProgrammaticText = false;
  }

  void _toggleCtrl() {
    if (_ctrlHeld) {
      _sendSpecialKey('CTRL_RELEASE');
    } else {
      _sendSpecialKey('CTRL');
    }

    setState(() {
      _ctrlHeld = !_ctrlHeld;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Keyboard Input')),
      floatingActionButton: FloatingActionButton(
        mini: true,
        onPressed: () {
          if (_focusNode.hasFocus) {
            _focusNode.unfocus();
          } else {
            FocusScope.of(context).requestFocus(_focusNode);
          }
          setState(() {});
        },
        child: Icon(_focusNode.hasFocus ? Icons.keyboard_hide : Icons.keyboard),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Voice input is not supported for remote typing. Please use regular keyboard typing.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Card(
                  elevation: 0,
                  color: colorScheme.surfaceContainerLow,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Use phone keyboard',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Type while watching your connected PC.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextButton.icon(
                          onPressed: () =>
                              FocusScope.of(context).requestFocus(_focusNode),
                          icon: const Icon(Icons.keyboard),
                          label: const Text('Show Keyboard'),
                        ),
                        TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          autofocus: false,
                          minLines: 1,
                          maxLines: null,
                          enableInteractiveSelection: false,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          onEditingComplete: () {},
                          enableSuggestions: true,
                          autocorrect: false,
                          showCursor: false,
                          cursorWidth: 0,
                          style: const TextStyle(
                            color: Colors.transparent,
                            fontSize: 1,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isCollapsed: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () => _sendSpecialKey('ENTER'),
                      icon: const Icon(Icons.keyboard_return),
                      label: const Text('Enter'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => _sendSpecialKey('TAB'),
                      icon: const Icon(Icons.keyboard_tab),
                      label: const Text('Tab'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => _sendSpecialKey('DELETE'),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Del'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => _sendSpecialKey('ESCAPE'),
                      icon: const Icon(Icons.close_fullscreen),
                      label: const Text('Esc'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: _ctrlHeld
                            ? colorScheme.primary
                            : colorScheme.secondaryContainer,
                        foregroundColor: _ctrlHeld
                            ? colorScheme.onPrimary
                            : colorScheme.onSecondaryContainer,
                      ),
                      onPressed: _toggleCtrl,
                      child: Text(_ctrlHeld ? 'Ctrl (Held)' : 'Ctrl'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
