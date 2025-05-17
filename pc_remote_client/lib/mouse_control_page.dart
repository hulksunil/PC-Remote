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
        ScrollbarControl(),
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
  final int _throttleDelayMs = 90;

  void _handlePanStart(DragStartDetails details) {
    _lastPosition = details.localPosition;
    _accumulatedDelta = Offset.zero;
    _lastSentTime = DateTime.fromMillisecondsSinceEpoch(0); // reset
  }

  final double sensitivity = 3; // Sensitivity multiplier

  void _handlePanUpdate(AppState appState, DragUpdateDetails details) {
    final now = DateTime.now();
    final delta =
        details.localPosition - (_lastPosition ?? details.localPosition);
    _accumulatedDelta += delta;
    _lastPosition = details.localPosition;

    const double minMovementThreshold = 1.5;
    final elapsed = now.difference(_lastSentTime).inMilliseconds;

    if (_accumulatedDelta.distance >= minMovementThreshold &&
        elapsed >= _throttleDelayMs) {
      _lastSentTime = now;

      final speed = _accumulatedDelta.distance / elapsed.clamp(1, 1000);
      final velocityBoost = (speed * 3).clamp(1.0, 3.0);

      appState.sendMouseMove(
        (_accumulatedDelta.dx * sensitivity * velocityBoost).round(),
        (_accumulatedDelta.dy * sensitivity * velocityBoost).round(),
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

class ScrollbarControl extends StatefulWidget {
  const ScrollbarControl({super.key});

  @override
  State<ScrollbarControl> createState() => _ScrollbarControlState();
}

class _ScrollbarControlState extends State<ScrollbarControl> {
  double _dragStartY = 0;
  double _accumulatedDelta = 0;
  DateTime _lastSentTime = DateTime.now();
  final int _throttleDelayMs = 90;
  final double _threshold = 8; // minimum vertical drag before sending scroll

  void _handleDragStart(DragStartDetails details) {
    _dragStartY = details.localPosition.dy;
    _accumulatedDelta = 0;
  }

  void _handleDragUpdate(AppState appState, DragUpdateDetails details) {
    final now = DateTime.now();
    final dy = details.localPosition.dy - _dragStartY;
    _dragStartY = details.localPosition.dy;

    _accumulatedDelta += dy;

    if (now.difference(_lastSentTime).inMilliseconds >= _throttleDelayMs &&
        _accumulatedDelta.abs() >= _threshold) {
      _lastSentTime = now;

      final scrollAmount = -(_accumulatedDelta * 5).round();
      appState.sendScroll(scrollAmount);
      _accumulatedDelta = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();

    return Container(
      width: 60, // increased width for easier touch
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: GestureDetector(
        behavior:
            HitTestBehavior.opaque, // ensures the whole container is touchable
        onVerticalDragStart: _handleDragStart,
        onVerticalDragUpdate: (details) => _handleDragUpdate(appState, details),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0), // extra spacing
          child: Column(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_upward),
                onPressed: () {
                  appState.sendScroll(300);
                },
              ),
              const Expanded(
                child: Center(
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: Icon(Icons.drag_handle, size: 20),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_downward),
                onPressed: () {
                  appState.sendScroll(-300);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
