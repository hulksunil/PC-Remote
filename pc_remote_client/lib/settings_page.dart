import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pc_remote_client/app_state.dart';
import 'package:network_info_plus/network_info_plus.dart';

const PORT = 5555;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String ip = '';

  final TextEditingController _ipController = TextEditingController();

  String HOST = '';

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    _ipController.text =
        "192.168.2.12"; // Default IP for testing (REMOTE LATER) ------------------------

    return Scaffold(
      appBar: AppBar(title: const Text('SETTINGS')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
                onPressed: () {
                  NetworkInfo().getWifiIP().then((value) {
                    setState(() {
                      ip = value ?? 'Unable to get IP';
                    });
                  });
                },
                child: const Text("Display Your IP")),
            Text('Your IP: $ip', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 5),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    HOST = _ipController.text;
                  });
                  appState.connectToServer(HOST, PORT);
                },
                child: const Text("Connect to PC real ")),
            const SizedBox(height: 5),
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Server IP Address',
                hintText: 'e.g. 192.168.2.12',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            if (appState.socket != null)
              Text(
                'Connected to: ${appState.socket?.remoteAddress.address}:${appState.socket?.remotePort}',
                style: const TextStyle(fontSize: 18),
              )
            else if (HOST.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text('Trying to connect to: $HOST'),
              ),
          ],
        ),
      ),
    );
  }
}
