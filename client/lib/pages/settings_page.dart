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

    // _ipController.text = '192.168.2.40';

    return Scaffold(
      appBar: AppBar(title: const Text('SETTINGS')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- IP INPUT FIELD ---
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Server IP Address',
                hintText: 'e.g. 192.168.2.12',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 5),

            // --- CONNECT BUTTON ---
            ElevatedButton(
              onPressed: () {
                setState(() {
                  host = _ipController.text.trim();
                });
                if (host.isNotEmpty) {
                  appState.connectToServer(host);
                }
              },
              child: const Text("Connect to PC"),
            ),

            // --- SAVE IP BUTTON ---
            TextButton.icon(
              onPressed: () {
                final ip = _ipController.text.trim();
                if (ip.isNotEmpty && !appState.savedIps.contains(ip)) {
                  appState.addSavedIp(ip);
                }
              },
              icon: const Icon(Icons.save),
              label: const Text("Save this IP"),
            ),

            const SizedBox(height: 16),

            // --- CONNECTION STATUS ---
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

            const SizedBox(height: 30),

            // --- SAVED IPS LIST ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Saved IP Addresses:",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: appState.savedIps.length,
                      itemBuilder: (context, index) {
                        final ip = appState.savedIps[index];
                        return ListTile(
                          title: Text(ip),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              appState.removeSavedIp(ip);
                            },
                          ),
                          onTap: () {
                            _ipController.text = ip;
                            setState(() {
                              host = ip;
                            });
                            appState.connectToServer(ip);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- THEME PICKER BUTTON ---
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
