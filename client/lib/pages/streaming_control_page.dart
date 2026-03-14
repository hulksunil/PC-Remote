import 'package:client/app/app_state.dart';
import 'package:client/models/command.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StreamingControlPage extends StatefulWidget {
  const StreamingControlPage({super.key});

  @override
  State<StreamingControlPage> createState() => _StreamingControlPageState();
}

class _StreamingControlPageState extends State<StreamingControlPage> {
  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.live_tv),
                SizedBox(width: 8),
                Text('Streaming Controls'),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const spacing = 10.0;
                    final buttonSize =
                        ((constraints.maxWidth - (spacing * 3)) / 4)
                            .clamp(64.0, 150.0);

                    return Align(
                      alignment: Alignment.topCenter,
                      child: Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: [
                          _BigControlButton(
                            size: buttonSize,
                            icon: Icons.play_arrow,
                            onTap: () => appState
                                .sendCommand(Command.streamPlayPause.value),
                          ),
                          _BigControlButton(
                            size: buttonSize,
                            icon: Icons.replay_10,
                            onTap: () =>
                                appState.sendCommand(Command.seekBack10.value),
                          ),
                          _BigControlButton(
                            size: buttonSize,
                            icon: Icons.forward_10,
                            onTap: () => appState
                                .sendCommand(Command.seekForward10.value),
                          ),
                          _BigControlButton(
                            size: buttonSize,
                            icon: Icons.volume_up,
                            onTap: () =>
                                appState.sendCommand(Command.streamMute.value),
                          ),
                          _BigControlButton(
                            size: buttonSize,
                            icon: Icons.skip_next,
                            onTap: () =>
                                appState.sendCommand(Command.nextEpisode.value),
                          ),
                          _BigControlButton(
                            size: buttonSize,
                            icon: Icons.subdirectory_arrow_right,
                            label: 'Skip Intro',
                            onTap: () =>
                                appState.sendCommand(Command.skipIntro.value),
                          ),
                          _BigControlButton(
                            size: buttonSize,
                            icon: Icons.fullscreen,
                            onTap: () => appState
                                .sendCommand(Command.toggleFullscreen.value),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BigControlButton extends StatelessWidget {
  const _BigControlButton({
    required this.size,
    required this.icon,
    required this.onTap,
    this.label,
  });

  final double size;
  final IconData icon;
  final VoidCallback onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.zero,
        ),
        child: label == null
            ? Icon(icon, size: size * 0.45)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: size * 0.32),
                  const SizedBox(height: 4),
                  Text(
                    label!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: (size * 0.12).clamp(10.0, 14.0),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
