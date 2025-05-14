import 'dart:io';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:provider/provider.dart';

const PORT = 5555;

// NOTE: dart.io is used for socket communication only for mobile
// NOTE: For web, you would typically use WebSockets or HTTP requests since web apps are not allowed to use sockets directly due to security restrictions.
void main() => runApp(
      const MyApp(),
    );

// NOTE: The main function is the entry point of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'PC Remote Client',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        ),
        home: const HomePage(),
      ),
    );
  }
}

class AppState extends ChangeNotifier {
  String _ip = '';
  String get ip => _ip;

  Socket? _socket;
  Socket? get socket => _socket;
  set socket(Socket? socket) {
    _socket = socket;
    notifyListeners();
  }

  void setIp(String ip) {
    _ip = ip;
    notifyListeners();
  }

  void _sendCommand(String command) {
    print('Sending command: $command');
    if (_socket != null) {
      _socket!.write(command);
    } else {
      print('Socket is not connected');
    }
  }

  Future<void> _connect(host, port) async {
    print('Connecting to $host:$port...');
    try {
      _socket = await Socket.connect(host, port);
      print('Connected to $host:$port');
    } catch (e) {
      print('Connection failed: $e');
    }
  }

  // NOTE: This will disconnect the socket when this page is disposed
  @override
  void dispose() {
    _socket?.close();
    super.dispose();
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget pageToDisplay;
    switch (selectedIndex) {
      case 0:
        pageToDisplay = MouseControlPage();
      case 1:
        pageToDisplay = VolumeControlPage();
      case 2:
        pageToDisplay = Placeholder();
      case 3:
        pageToDisplay = Placeholder();
      default:
        throw UnimplementedError('No widget for $selectedIndex');
    }

    return Scaffold(
      body: pageToDisplay,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        currentIndex: selectedIndex,
        onTap: (int index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.mouse),
            label: 'Mouse',
            backgroundColor: Colors.teal,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.multitrack_audio),
            label: 'Volume/Music',
            backgroundColor: Colors.deepPurple,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.power_settings_new),
            label: 'Power',
            backgroundColor: Colors.redAccent,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.keyboard),
            label: 'Keyboard',
            backgroundColor: Colors.indigo,
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String ip = '';

  final TextEditingController _ipController = TextEditingController();

  // final String _host = '192.168.2.12'; // Replace with actual server IP
  // final int _port = 5555;
  String HOST = '';

  void _submitIp() {
    setState(() {
      HOST = _ipController.text;
    });
    print('User entered IP: $HOST');
    // Here you can attempt a connection using this IP
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    _ipController.text =
        "192.168.2.12"; // Default IP for testing (REMOTE LATER)

    return Scaffold(
      appBar: AppBar(title: const Text('Enter Server IP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'SETTINGS',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Text('Your IP: $ip', style: const TextStyle(fontSize: 18)),
            ElevatedButton(
                onPressed: () {
                  NetworkInfo().getWifiIP().then((value) {
                    setState(() {
                      ip = value ?? 'Unable to get IP';
                    });
                  });
                },
                child: const Text("Get IP")),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    HOST = _ipController.text;
                  });
                  appState._connect(HOST, PORT);
                },
                child: const Text("Connect to PC real ")),
            ElevatedButton(
                onPressed: () => appState._sendCommand(Command.volumeUp.value),
                child: const Text("Volume Up")),
            ElevatedButton(
                onPressed: () =>
                    appState._sendCommand(Command.volumeDown.value),
                child: const Text("Volume Down")),
            ElevatedButton(
                onPressed: () => appState._sendCommand(Command.pressKeyA.value),
                child: const Text("Press 'a'")),
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
            if (HOST.isNotEmpty)
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

class MouseControlPage extends StatefulWidget {
  const MouseControlPage({super.key});
  @override
  State<MouseControlPage> createState() => _MouseControlPageState();
}

class _MouseControlPageState extends State<MouseControlPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            AppBar(
              title: const Text('PC Remote Control'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class VolumeControlPage extends StatefulWidget {
  const VolumeControlPage({super.key});
  @override
  State<VolumeControlPage> createState() => _VolumeControlPageState();
}

class _VolumeControlPageState extends State<VolumeControlPage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Volume Control'),
      ),
      body: Center(
        child: Column(children: [
          const Text(
            'Volume Control',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => appState._sendCommand(Command.volumeUp.value),
            child: const Text("Volume Up"),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => appState._sendCommand(Command.volumeDown.value),
            child: const Text("Volume Down"),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => appState._sendCommand(Command.volumeMute.value),
            child: const Text("Mute"),
          ),
          ElevatedButton(
            onPressed: () => appState._sendCommand(Command.pressKeyA.value),
            child: const Text("Press 'a'"),
          ),
        ]),
      ),
    );
  }
}

enum Command {
  volumeUp,
  volumeDown,
  volumeMute,
  pressKeyA,
}

extension CommandExtension on Command {
  String get value {
    switch (this) {
      case Command.volumeUp:
        return "VOLUME_UP";
      case Command.volumeDown:
        return "VOLUME_DOWN";
      case Command.volumeMute:
        return "VOLUME_MUTE";
      case Command.pressKeyA:
        return "PRESS_KEY:a";
    }
  }
}
