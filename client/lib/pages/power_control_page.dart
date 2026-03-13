import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:client/app/app_state.dart';
import 'package:client/models/command.dart';

class PowerSettingsPage extends StatelessWidget {
  const PowerSettingsPage({super.key});

  void _sendPowerCommand(BuildContext context, String command) {
    final appState = context.read<AppState>();
    appState.sendCommand(command);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sent command: $command')),
    );
  }

  Future<void> _confirmShutdown(BuildContext context) async {
    final shouldShutdown = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.warning_amber_rounded),
          title: const Text('Shut down PC?'),
          content: const Text(
            'This will immediately power off your computer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Shut Down'),
            ),
          ],
        );
      },
    );

    if (shouldShutdown == true && context.mounted) {
      _sendPowerCommand(context, Command.shutdown.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                        Icon(
                          Icons.power_settings_new,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Power Controls',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Use these actions carefully. Shutdown requires confirmation.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Card(
                elevation: 0,
                color: colorScheme.surfaceContainerLow,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      _PowerActionTile(
                        icon: Icons.bedtime_outlined,
                        title: 'Put PC to Sleep',
                        subtitle: 'Suspend computer to low power state',
                        onTap: () =>
                            _sendPowerCommand(context, Command.sleep.value),
                      ),
                      const SizedBox(height: 10),
                      _PowerActionTile(
                        icon: Icons.lock_outline,
                        title: 'Lock PC',
                        subtitle: 'Lock session and keep apps running',
                        onTap: () =>
                            _sendPowerCommand(context, Command.lock.value),
                      ),
                      const SizedBox(height: 10),
                      _PowerActionTile(
                        icon: Icons.power_settings_new,
                        title: 'Shut Down PC',
                        subtitle: 'Power off the computer immediately',
                        danger: true,
                        onTap: () => _confirmShutdown(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PowerActionTile extends StatelessWidget {
  const _PowerActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final iconColor = danger ? colorScheme.error : colorScheme.primary;
    final tileColor = danger
        ? colorScheme.errorContainer.withValues(alpha: 0.35)
        : colorScheme.surface;

    return Material(
      color: tileColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: danger
                    ? colorScheme.errorContainer
                    : colorScheme.primaryContainer,
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: danger ? colorScheme.onErrorContainer : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color:
                    danger ? colorScheme.error : colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
