import 'package:client/app/app_state.dart';
import 'package:client/models/command.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MouseControlPage extends StatefulWidget {
  const MouseControlPage({super.key});

  @override
  State<MouseControlPage> createState() => _MouseControlPageState();
}

class _MouseControlPageState extends State<MouseControlPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
      child: Row(
        children: const [
          Expanded(flex: 9, child: Touchpad()),
          SizedBox(width: 8),
          ScrollbarControl(),
        ],
      ),
    );
  }
}

class Touchpad extends StatefulWidget {
  const Touchpad({super.key});

  @override
  State<Touchpad> createState() => _TouchpadState();
}

class _TouchpadState extends State<Touchpad> {
  Offset? _lastFocalPoint;
  Offset _pendingMouseDelta = Offset.zero;
  double _pendingScrollRemainder = 0;
  DateTime _lastSentTime = DateTime.now();

  final int _throttleDelayMs = 16;
  final double sensitivity = 3;
  final double scrollMultiplier = 2;

  int _activePointers = 0;
  int _lastPointerCount = 0;
  bool _isTwoFingerGesture = false;

  DateTime? _twoFingerTapStart;
  Offset? _twoFingerTapStartPos;
  bool _potentialTwoFingerTap = false;

  bool _suppressNextTap = false;
  DateTime? _lastTapTime;
  Offset? _lastTapPosition;
  bool _isDraggingFromDoubleTap = false;
  bool _showHint = true;

  void _markInteracted() {
    if (_showHint) {
      setState(() {
        _showHint = false;
      });
    }
  }

  void _handlePointerDown(AppState appState, PointerDownEvent event) {
    if (!appState.isConnected) {
      appState.navigateToSettingsOnce();
      return;
    }

    _markInteracted();
    _activePointers++;

    if (_activePointers == 2) {
      _isTwoFingerGesture = true;
      _lastFocalPoint = null;
      _pendingMouseDelta = Offset.zero;
      _pendingScrollRemainder = 0;
      _lastPointerCount = 2;

      _twoFingerTapStart = DateTime.now();
      _twoFingerTapStartPos = event.position;
      _potentialTwoFingerTap = true;
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    _activePointers = (_activePointers - 1).clamp(0, 10).toInt();

    if (_activePointers < 2) {
      _isTwoFingerGesture = false;
      _lastFocalPoint = null;
      _pendingMouseDelta = Offset.zero;
      _pendingScrollRemainder = 0;
      _lastPointerCount = _activePointers;

      if (_potentialTwoFingerTap && _twoFingerTapStart != null) {
        final duration =
            DateTime.now().difference(_twoFingerTapStart!).inMilliseconds;
        final distance = (event.position - _twoFingerTapStartPos!).distance;

        if (duration < 200 && distance < 20) {
          final appState = context.read<AppState>();
          appState.sendCommand(Command.clickRight.value);
          _suppressNextTap = true;
        }

        _potentialTwoFingerTap = false;
      }
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _lastFocalPoint = details.localFocalPoint;
    _pendingMouseDelta = Offset.zero;
    _pendingScrollRemainder = 0;
    _lastPointerCount = _activePointers;
    _lastSentTime = DateTime.fromMillisecondsSinceEpoch(0);
  }

  void _handleScaleUpdate(AppState appState, ScaleUpdateDetails details) {
    final now = DateTime.now();
    final pointerCount = details.pointerCount;

    if (_lastFocalPoint == null) {
      _lastFocalPoint = details.localFocalPoint;
      _lastPointerCount = pointerCount;
      return;
    }

    if (pointerCount != _lastPointerCount) {
      _lastFocalPoint = details.localFocalPoint;
      _pendingMouseDelta = Offset.zero;
      _pendingScrollRemainder = 0;
      _lastPointerCount = pointerCount;
      _lastSentTime = now;
      return;
    }

    final delta = details.localFocalPoint - _lastFocalPoint!;
    _lastFocalPoint = details.localFocalPoint;

    const double minMovementThreshold = 0.4;
    final elapsed = now.difference(_lastSentTime).inMilliseconds;

    if (pointerCount >= 2 || _isTwoFingerGesture) {
      _pendingScrollRemainder += delta.dy * scrollMultiplier;
      if (elapsed >= _throttleDelayMs) {
        final scrollAmount = _pendingScrollRemainder.truncate();
        if (scrollAmount != 0) {
          appState.sendScroll(scrollAmount);
          _pendingScrollRemainder -= scrollAmount;
        }
        _lastSentTime = now;
      }
      return;
    }

    _pendingMouseDelta += delta;

    if (_pendingMouseDelta.distance >= minMovementThreshold &&
        elapsed >= _throttleDelayMs) {
      final speed = _pendingMouseDelta.distance / elapsed.clamp(1, 1000);
      final velocityBoost =
          _isDraggingFromDoubleTap ? 1.0 : (speed * 3).clamp(1.0, 3.0);

      final dx = (_pendingMouseDelta.dx * sensitivity * velocityBoost).round();
      final dy = (_pendingMouseDelta.dy * sensitivity * velocityBoost).round();

      if (dx != 0 || dy != 0) {
        appState.sendMouseMove(dx, dy);
      }

      _lastSentTime = now;
      _pendingMouseDelta = Offset.zero;
    }
  }

  void _handleScaleEnd(AppState appState, ScaleEndDetails details) {
    if (_isDraggingFromDoubleTap) {
      appState.sendCommand(Command.mouseUp.value);
      _isDraggingFromDoubleTap = false;
    }

    _lastFocalPoint = null;
    _pendingMouseDelta = Offset.zero;
    _pendingScrollRemainder = 0;
    _lastPointerCount = 0;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: Listener(
              onPointerDown: (event) => _handlePointerDown(appState, event),
              onPointerUp: _handlePointerUp,
              child: GestureDetector(
                onScaleStart: _handleScaleStart,
                onScaleUpdate: (details) =>
                    _handleScaleUpdate(appState, details),
                onScaleEnd: (details) => _handleScaleEnd(appState, details),
                onTapDown: (details) {
                  _markInteracted();
                  final now = DateTime.now();
                  final pos = details.localPosition;

                  if (_lastTapTime != null &&
                      now.difference(_lastTapTime!).inMilliseconds < 300 &&
                      (pos - _lastTapPosition!).distance < 20) {
                    _isDraggingFromDoubleTap = true;
                    appState.sendCommand(Command.mouseDown.value);
                  }

                  _lastTapTime = now;
                  _lastTapPosition = pos;
                },
                onTapUp: (details) {
                  if (_isDraggingFromDoubleTap) {
                    // Mouse up sent at scale end
                  } else if (!_isTwoFingerGesture && !_suppressNextTap) {
                    appState.sendCommand(Command.clickLeft.value);
                  }

                  _suppressNextTap = false;
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primaryContainer,
                        colorScheme.secondaryContainer,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      if (_showHint)
                        Positioned(
                          top: 12,
                          left: 12,
                          right: 12,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _showHint ? 1 : 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    colorScheme.surface.withValues(alpha: 0.82),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Drag to move • Two-finger drag to scroll • Two-finger tap for right-click',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.labelLarge,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 84,
          child: Row(
            children: [
              Expanded(
                child: _ClickButton(
                  icon: Icons.mouse,
                  label: 'Left Click',
                  onTapDown: () =>
                      appState.sendCommand(Command.mouseDown.value),
                  onTapUp: () => appState.sendCommand(Command.mouseUp.value),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ClickButton(
                  icon: Icons.ads_click,
                  label: 'Right Click',
                  onTap: () => appState.sendCommand(Command.clickRight.value),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ClickButton extends StatelessWidget {
  const _ClickButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.onTapDown,
    this.onTapUp,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onTapDown;
  final VoidCallback? onTapUp;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        onTapDown: onTapDown == null ? null : (_) => onTapDown!(),
        onTapUp: onTapUp == null ? null : (_) => onTapUp!(),
        onTapCancel: onTapUp,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
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
  double _lastY = 0;
  DateTime _lastSentTime = DateTime.now();
  final int _throttleMs = 16;

  void _handleDragStart(DragStartDetails details) {
    _lastY = details.localPosition.dy;
  }

  void _handleDragUpdate(AppState appState, DragUpdateDetails details) {
    final currentY = details.localPosition.dy;
    final dy = currentY - _lastY;
    _lastY = currentY;

    final now = DateTime.now();
    if (now.difference(_lastSentTime).inMilliseconds >= _throttleMs) {
      final scrollAmount = -(dy * 2).round();
      if (scrollAmount != 0) {
        appState.sendScroll(scrollAmount);
        _lastSentTime = now;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      elevation: 1,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragStart: _handleDragStart,
          onVerticalDragUpdate: (details) =>
              _handleDragUpdate(appState, details),
          child: Column(
            children: [
              IconButton(
                icon: Icon(Icons.keyboard_arrow_up,
                    color: theme.colorScheme.primary),
                onPressed: () => appState.sendScroll(5),
              ),
              Expanded(
                child: Center(
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: Icon(
                      Icons.drag_indicator,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.keyboard_arrow_down,
                    color: theme.colorScheme.primary),
                onPressed: () => appState.sendScroll(-5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
