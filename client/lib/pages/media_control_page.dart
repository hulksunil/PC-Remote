import 'dart:async';

import 'package:client/app/app_state.dart';
import 'package:client/models/command.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MediaControlPage extends StatefulWidget {
  const MediaControlPage({super.key});

  @override
  State<MediaControlPage> createState() => _MediaControlPageState();
}

class _MediaControlPageState extends State<MediaControlPage> {
  Timer? _holdTimer;
  String currentVolume = '';
  int _lastSentTimestamp = 0;

  @override
  void initState() {
    super.initState();
    _fetchCurrentVolume();
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchCurrentVolume() async {
    final appState = context.read<AppState>();
    final response =
        await appState.sendCommandAndGetResponse(Command.currentVolume.value);
    if (!mounted) return;

    setState(() {
      currentVolume = response;
    });
  }

  void _startSending(AppState appState, String command) {
    final now = DateTime.now().millisecondsSinceEpoch;

    if (now - _lastSentTimestamp > 250) {
      appState.sendCommand(command);
      _fetchCurrentVolume();
      _lastSentTimestamp = now;
    }

    _holdTimer?.cancel();
    _holdTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      appState.sendCommand(command);
      _fetchCurrentVolume();
      _lastSentTimestamp = DateTime.now().millisecondsSinceEpoch;
    });
  }

  void _stopSending() {
    _holdTimer?.cancel();
    _holdTimer = null;
  }

  double _parseVolumeLevel(String volumeString) {
    final volume = int.tryParse(volumeString) ?? 0;
    return (volume.clamp(0, 100)) / 100.0;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final volumeLabel = currentVolume.isEmpty ? '--' : currentVolume;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wheelSize = (constraints.maxWidth * 0.68).clamp(230.0, 320.0);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              children: [
                Card(
                  elevation: 0,
                  color: colorScheme.surfaceContainerLow,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.volume_up,
                                color: colorScheme.onSurfaceVariant),
                            const SizedBox(width: 8),
                            Text(
                              'Volume',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: _parseVolumeLevel(currentVolume),
                            minHeight: 16,
                            backgroundColor:
                                colorScheme.surfaceContainerHighest,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '$volumeLabel%',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: wheelSize,
                  height: wheelSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.secondaryContainer,
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.shadow.withValues(alpha: 0.12),
                              blurRadius: 14,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                      ),
                      FilledButton(
                        onPressed: () =>
                            appState.sendCommand(Command.playPause.value),
                        style: FilledButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(24),
                          backgroundColor: colorScheme.primary,
                        ),
                        child: const Icon(Icons.play_arrow, size: 38),
                      ),
                      Positioned(
                        top: 16,
                        child: _RoundControl(
                          icon: Icons.volume_up,
                          label: 'Vol +',
                          onTapDown: (_) =>
                              _startSending(appState, Command.volumeUp.value),
                          onTapUp: (_) => _stopSending(),
                          onTapCancel: _stopSending,
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        child: _RoundControl(
                          icon: Icons.volume_down,
                          label: 'Vol -',
                          onTapDown: (_) =>
                              _startSending(appState, Command.volumeDown.value),
                          onTapUp: (_) => _stopSending(),
                          onTapCancel: _stopSending,
                        ),
                      ),
                      Positioned(
                        left: 16,
                        child: _RoundControl(
                          icon: Icons.skip_previous,
                          label: 'Prev',
                          onTap: () =>
                              appState.sendCommand(Command.previousTrack.value),
                        ),
                      ),
                      Positioned(
                        right: 16,
                        child: _RoundControl(
                          icon: Icons.skip_next,
                          label: 'Next',
                          onTap: () =>
                              appState.sendCommand(Command.nextTrack.value),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.tonalIcon(
                  onPressed: () =>
                      appState.sendCommand(Command.volumeMute.value),
                  icon: const Icon(Icons.volume_off),
                  label: const Text('Mute'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RoundControl extends StatelessWidget {
  const _RoundControl({
    required this.icon,
    required this.label,
    this.onTap,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final GestureTapDownCallback? onTapDown;
  final GestureTapUpCallback? onTapUp;
  final VoidCallback? onTapCancel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      shape: const CircleBorder(),
      color: colorScheme.surface.withValues(alpha: 0.9),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        onTapDown: onTapDown,
        onTapUp: onTapUp,
        onTapCancel: onTapCancel,
        child: SizedBox(
          width: 68,
          height: 68,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24),
              Text(label, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}
