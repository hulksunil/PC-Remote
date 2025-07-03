import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pc_remote_client/app/app_state.dart';
import 'package:pc_remote_client/models/command.dart';

class PowerSettingsPage extends StatelessWidget {
  const PowerSettingsPage({super.key});

  void _sendPowerCommand(BuildContext context, String command) {
    final appState = context.read<AppState>();
    appState.sendCommand(command);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sent command: $command')),
    );
  }

  void _showBlackScreen(BuildContext context, String command) {
    final appState = context.read<AppState>();
    appState.sendCommand(command);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening black window on 2nd monitor')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, 50),
      textStyle: const TextStyle(fontSize: 18),
    );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: buttonStyle,
              onPressed: () => _sendPowerCommand(context, Command.sleep.value),
              child: const Text('Put PC to Sleep'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: buttonStyle.copyWith(
                backgroundColor: WidgetStateProperty.all(Colors.redAccent),
              ),
              onPressed: () =>
                  _sendPowerCommand(context, Command.shutdown.value),
              child: const Text('Shut Down PC'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: buttonStyle,
              onPressed: () => _sendPowerCommand(context, Command.lock.value),
              child: const Text('Lock PC'),
            ),
            const SizedBox(height: 40), // extra space to separate it visually

            ElevatedButton.icon(
              icon: const Icon(Icons.tv, size: 28),
              label: const Text(
                'Blackout Secondary Monitor',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () =>
                  _showBlackScreen(context, Command.showBlackScreen.value),
            ),
          ],
        ),
      ),
    );
  }
}
