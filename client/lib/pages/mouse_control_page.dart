import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:client/app/app_state.dart';
import 'package:client/models/command.dart';

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

// TODO(sunil): fix the issue of when you have 2 fingers on the screen and you lift one finger, the mouse moves to where the other finger was
class _TouchpadState extends State<Touchpad> {
  Offset? _lastPosition;
  Offset _accumulatedDelta = Offset.zero;
  DateTime _lastSentTime = DateTime.now();
  final int _throttleDelayMs = 90;
  final double sensitivity = 3;
  final double scrollMultiplier = 5;

  int _activePointers = 0;
  bool _isTwoFingerGesture = false;
  bool _readyForScroll = false;

  DateTime? _twoFingerTapStart;
  Offset? _twoFingerTapStartPos;
  bool _potentialTwoFingerTap = false;

  bool _suppressNextTap = false;

  DateTime? _lastTapTime;
  Offset? _lastTapPosition;
  bool _isDraggingFromDoubleTap = false;

  void _handlePointerDown(AppState appState, PointerDownEvent event) {
    if (!appState.isConnected) {
      appState.navigateToSettingsOnce();
      return;
    }

    _activePointers++;
    if (_activePointers == 2) {
      _isTwoFingerGesture = true;
      _readyForScroll = false;

      // Start tracking for potential two-finger tap
      _twoFingerTapStart = DateTime.now();
      _twoFingerTapStartPos = event.position;
      _potentialTwoFingerTap = true;
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    _activePointers = (_activePointers - 1).clamp(0, 10);

    if (_activePointers < 2) {
      _isTwoFingerGesture = false;

      if (_potentialTwoFingerTap && _twoFingerTapStart != null) {
        final duration =
            DateTime.now().difference(_twoFingerTapStart!).inMilliseconds;
        final distance = (event.position - _twoFingerTapStartPos!).distance;

        if (duration < 200 && distance < 20) {
          final appState = context.read<AppState>();
          appState.sendCommand(Command.clickRight.value);

          _suppressNextTap = true; // Suppress left click
        }

        _potentialTwoFingerTap = false;
      }
    }
  }

  void _handlePanStart(DragStartDetails details) {
    // When a two-finger gesture starts, reset position to avoid jump
    _lastPosition = details.localPosition;
    _accumulatedDelta = Offset.zero;
    _lastSentTime = DateTime.fromMillisecondsSinceEpoch(0);
  }

  void _handlePanUpdate(AppState appState, DragUpdateDetails details) {
    final now = DateTime.now();

    if (_lastPosition == null || (_isTwoFingerGesture && !_readyForScroll)) {
      _lastPosition = details.localPosition;
      _accumulatedDelta = Offset.zero;
      _readyForScroll = true; // Now we’re ready
      return;
    }

    final delta = details.localPosition - _lastPosition!;
    _accumulatedDelta += delta;
    _lastPosition = details.localPosition;

    const double minMovementThreshold = 1.5;
    final elapsed = now.difference(_lastSentTime).inMilliseconds;

    if (_accumulatedDelta.distance >= minMovementThreshold &&
        elapsed >= _throttleDelayMs) {
      if (_isDraggingFromDoubleTap) {
        appState.sendMouseMove(
          (_accumulatedDelta.dx * sensitivity).round(),
          (_accumulatedDelta.dy * sensitivity).round(),
        );
      }

      _lastSentTime = now;

      if (_isTwoFingerGesture) {
        final scrollAmount = (_accumulatedDelta.dy * scrollMultiplier).round();
        if (scrollAmount.abs() > 10) {
          appState.sendScroll(scrollAmount);
        }
      } else {
        final speed = _accumulatedDelta.distance / elapsed.clamp(1, 1000);
        final velocityBoost = (speed * 3).clamp(1.0, 3.0);
        appState.sendMouseMove(
          (_accumulatedDelta.dx * sensitivity * velocityBoost).round(),
          (_accumulatedDelta.dy * sensitivity * velocityBoost).round(),
        );
      }

      _accumulatedDelta = Offset.zero;
    }
  }

  void _handlePanEnd(AppState appState, DragEndDetails details) {
    if (_isDraggingFromDoubleTap) {
      appState.sendCommand(Command.mouseUp.value);
      _isDraggingFromDoubleTap = false;
    }

    if (_isTwoFingerGesture && _accumulatedDelta.distance < 10) {
      appState
          .sendCommand(Command.clickRight.value); // Treat it as a right-click
    }

    _lastPosition = null;
    _accumulatedDelta = Offset.zero;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();

    return Column(
      children: [
        Expanded(
          child: Listener(
            onPointerDown: (event) => _handlePointerDown(appState, event),
            onPointerUp: _handlePointerUp,
            child: GestureDetector(
              onPanStart: _handlePanStart,
              onPanUpdate: (details) => _handlePanUpdate(appState, details),
              onPanEnd: (details) => _handlePanEnd(appState, details),
              onTapDown: (details) {
                final now = DateTime.now();
                final pos = details.localPosition;

                if (_lastTapTime != null &&
                    now.difference(_lastTapTime!).inMilliseconds < 300 &&
                    (pos - _lastTapPosition!).distance < 20) {
                  // Detected double tap
                  _isDraggingFromDoubleTap = true;
                  appState.sendCommand(Command.mouseDown.value);
                }

                _lastTapTime = now;
                _lastTapPosition = pos;
              },
              onTapUp: (details) {
                if (_isDraggingFromDoubleTap) {
                  // Do nothing yet; wait for pan end to send mouse up
                } else if (!_isTwoFingerGesture && !_suppressNextTap) {
                  appState.sendCommand(Command.clickLeft.value);
                }

                _suppressNextTap = false;
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Touch and drag to move the mouse\nTwo-finger drag to scroll\nTwo-finger tap to right-click',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => appState.sendCommand(Command.clickLeft.value),
                style: ElevatedButton.styleFrom(
                    // backgroundColor: Colors.grey[400],
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryFixedDim),
                child: const Text(""),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: () => appState.sendCommand(Command.clickRight.value),
                style: ElevatedButton.styleFrom(
                    // backgroundColor: Colors.grey[400],
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryFixedDim),
                child: const Text(""),
              ),
            ),
          ],
        ),
      ],
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
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragStart: _handleDragStart,
          onVerticalDragUpdate: (details) =>
              _handleDragUpdate(appState, details),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Column(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_upward,
                      color: theme.colorScheme.primary),
                  onPressed: () => appState.sendScroll(300),
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
                  icon: Icon(Icons.arrow_downward,
                      color: theme.colorScheme.primary),
                  onPressed: () => appState.sendScroll(-300),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
