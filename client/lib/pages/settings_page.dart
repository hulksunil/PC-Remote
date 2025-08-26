import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:client/app/app_state.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _ipController = TextEditingController();

  String host = '';

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    _ipController.text =
        "192.168.2.40"; // Default IP for testing (REMOTE LATER) ------------------------

    return Scaffold(
      appBar: AppBar(title: const Text('SETTINGS')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Server IP Address',
                hintText: 'e.g. 192.168.2.12',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 5),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    host = _ipController.text;
                  });
                  appState.connectToServer(host);
                },
                child: const Text("Connect to PC ")),
            const SizedBox(height: 16),
            if (appState.socket != null)
              Text(
                'Connected to: ${appState.socket?.remoteAddress.address}:${appState.socket?.remotePort}',
                style: const TextStyle(fontSize: 18),
              )
            else if (host.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text('Trying to connect to: $host'),
              ),
            const SizedBox(height: 50),
            OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    Color pickerColor = context.read<AppState>().themeColor;

                    return AlertDialog(
                      title: const Text('Pick a Theme Color'),
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: pickerColor,
                          onColorChanged: (color) {
                            pickerColor = color;
                          },
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        TextButton(
                          child: const Text('Select'),
                          onPressed: () {
                            context.read<AppState>().setThemeColor(pickerColor);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              icon: Icon(Icons.palette,
                  color: Theme.of(context).colorScheme.primary),
              label: Text(
                "Change Theme Color",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Theme.of(context).colorScheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            )
          ],
        ),
      ),
    );
  }
}
