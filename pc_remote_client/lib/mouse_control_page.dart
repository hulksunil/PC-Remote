import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pc_remote_client/app_state.dart';

class MouseControlPage extends StatefulWidget {
  const MouseControlPage({super.key});
  @override
  State<MouseControlPage> createState() => _MouseControlPageState();
}

class _MouseControlPageState extends State<MouseControlPage> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 9,
          child: Touchpad(),
        ),
        const SizedBox(width: 2),
        // Right-side scrollbar or simulated vertical strip
        Container(
          width: 40,
          color: Colors.grey[300],
          child: Column(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_upward),
                onPressed: () {
                  context.read<AppState>().sendCommand("SCROLL_UP");
                },
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.arrow_downward),
                onPressed: () {
                  context.read<AppState>().sendCommand("SCROLL_DOWN");
                },
              ),
            ],
          ),
        )
      ],
    );
  }
}

class Touchpad extends StatefulWidget {
  const Touchpad({super.key});

  @override
  State<Touchpad> createState() => _TouchpadState();
}

class _TouchpadState extends State<Touchpad> {
  Offset? _lastPosition;
  Offset _accumulatedDelta = Offset.zero;
  DateTime _lastSentTime = DateTime.now();
  final int _throttleDelayMs = 60;

  void _handlePanStart(DragStartDetails details) {
    _lastPosition = details.localPosition;
    _accumulatedDelta = Offset.zero;
  }

  final double sensitivity = 3; // Sensitivity multiplier

  void _handlePanUpdate(AppState appState, DragUpdateDetails details) {
    final now = DateTime.now();

    final delta =
        details.localPosition - (_lastPosition ?? details.localPosition);
    _accumulatedDelta += delta;
    _lastPosition = details.localPosition;

    if (now.difference(_lastSentTime).inMilliseconds >= _throttleDelayMs) {
      _lastSentTime = now;

      appState.sendMouseMove(
        (_accumulatedDelta.dx * sensitivity).round(),
        (_accumulatedDelta.dy * sensitivity).round(),
      );

      _accumulatedDelta = Offset.zero;
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    _lastPosition = null;
    _accumulatedDelta = Offset.zero;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();

    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: (details) => _handlePanUpdate(appState, details),
      onPanEnd: _handlePanEnd,
      onTap: () {
        appState.sendCommand("CLICK_LEFT");
      },
      child: Container(
        color: Colors.black12,
        alignment: Alignment.center,
        child: const Text(
          'Touch and drag to move the mouse',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
