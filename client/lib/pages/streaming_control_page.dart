import 'package:client/app/app_state.dart';
import 'package:client/models/command.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum _StreamingPreset { netflix, generic }

class StreamingControlPage extends StatefulWidget {
  const StreamingControlPage({super.key});

  @override
  State<StreamingControlPage> createState() => _StreamingControlPageState();
}

class _StreamingControlPageState extends State<StreamingControlPage> {
  _StreamingPreset _preset = _StreamingPreset.netflix;

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Streaming Apps',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pick a preset and use app-specific controls. No auto-detection needed.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            SegmentedButton<_StreamingPreset>(
              segments: const [
                ButtonSegment(
                  value: _StreamingPreset.netflix,
                  icon: Icon(Icons.live_tv),
                  label: Text('Netflix'),
                ),
                ButtonSegment(
                  value: _StreamingPreset.generic,
                  icon: Icon(Icons.movie_filter),
                  label: Text('Generic'),
                ),
              ],
              selected: {_preset},
              onSelectionChanged: (selection) {
                setState(() {
                  _preset = selection.first;
                });
              },
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              color: colorScheme.surfaceContainerLow,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  _preset == _StreamingPreset.netflix
                      ? 'Netflix preset: seek (-10/+10), play/pause, skip intro, next episode, fullscreen.'
                      : 'Generic preset: browser/app-friendly controls using common keyboard shortcuts.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _ControlsGrid(
              onPressed: (command) => appState.sendCommand(command.value),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlsGrid extends StatelessWidget {
  const _ControlsGrid({required this.onPressed});

  final ValueChanged<Command> onPressed;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.55,
      children: [
        _ControlTile(
          icon: Icons.replay_10,
          label: 'Rewind 10s',
          onTap: () => onPressed(Command.seekBack10),
        ),
        _ControlTile(
          icon: Icons.forward_10,
          label: 'Forward 10s',
          onTap: () => onPressed(Command.seekForward10),
        ),
        _ControlTile(
          icon: Icons.play_arrow,
          label: 'Play / Pause',
          onTap: () => onPressed(Command.streamPlayPause),
        ),
        _ControlTile(
          icon: Icons.skip_next,
          label: 'Next Episode',
          onTap: () => onPressed(Command.nextEpisode),
        ),
        _ControlTile(
          icon: Icons.subdirectory_arrow_right,
          label: 'Skip Intro',
          onTap: () => onPressed(Command.skipIntro),
        ),
        _ControlTile(
          icon: Icons.fullscreen,
          label: 'Fullscreen',
          onTap: () => onPressed(Command.toggleFullscreen),
        ),
        _ControlTile(
          icon: Icons.volume_off,
          label: 'Mute',
          onTap: () => onPressed(Command.streamMute),
        ),
      ],
    );
  }
}

class _ControlTile extends StatelessWidget {
  const _ControlTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FilledButton.tonalIcon(
      onPressed: onTap,
      icon: Icon(icon),
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.secondaryContainer,
        foregroundColor: colorScheme.onSecondaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      label: Text(
        label,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
