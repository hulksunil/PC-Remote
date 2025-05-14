import 'dart:io';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';

const HOST = '192.168.2.12';
const PORT = 5555;

// NOTE: dart.io is used for socket communication only for mobile
// NOTE: For web, you would typically use WebSockets or HTTP requests since web apps are not allowed to use sockets directly due to security restrictions.
void main() => runApp(const MyApp());

// NOTE: The main function is the entry point of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PC Remote Client',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
      ),
      home: const HomePage(),
    );
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
        pageToDisplay = RemoteControlPage();
      case 1:
        pageToDisplay = Placeholder();
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

class IpInputScreen extends StatefulWidget {
  const IpInputScreen({super.key});

  @override
  State<IpInputScreen> createState() => _IpInputScreenState();
}

class _IpInputScreenState extends State<IpInputScreen> {
  final TextEditingController _ipController = TextEditingController();
  String _enteredIp = '';

  void _submitIp() {
    setState(() {
      _enteredIp = _ipController.text;
    });
    print('User entered IP: $_enteredIp');
    // Here you can attempt a connection using this IP
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Server IP')),
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitIp,
              child: const Text('Connect'),
            ),
            if (_enteredIp.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Trying to connect to: $_enteredIp'),
              ),
          ],
        ),
      ),
    );
  }
}

class RemoteControlPage extends StatefulWidget {
  const RemoteControlPage({super.key});
  @override
  State<RemoteControlPage> createState() => _RemoteControlPageState();
}

class _RemoteControlPageState extends State<RemoteControlPage> {
  Socket? _socket;
  final String _host = '192.168.2.12'; // Replace with actual server IP
  final int _port = 5555;

  var ip = '';

  Future<void> _connect() async {
    print('Connecting to $_host:$_port...');
    try {
      _socket = await Socket.connect(_host, _port);
      print('Connected to $_host:$_port');
    } catch (e) {
      print('Connection failed: $e');
    }
  }

  void _sendCommand(String command) {
    print('Sending command: $command');
    if (_socket != null) {
      _socket!.write(command);
    } else {
      print('Socket is not connected');
    }
  }

  @override
  void dispose() {
    _socket?.close();
    super.dispose();
  }

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
                        builder: (context) => const IpInputScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const Text(
              'Control your PC remotely',
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
                onPressed: () => _connect(),
                child: const Text("Connect to PC ")),
            ElevatedButton(
                onPressed: () => _sendCommand(Command.volumeUp.value),
                child: const Text("Volume Up")),
            ElevatedButton(
                onPressed: () => _sendCommand(Command.volumeDown.value),
                child: const Text("Volume Down")),
            ElevatedButton(
                onPressed: () => _sendCommand(Command.pressKeyA.value),
                child: const Text("Press 'a'")),
          ],
        ),
      ),
    );
  }
}

enum Command {
  volumeUp,
  volumeDown,
  pressKeyA,
}

extension CommandExtension on Command {
  String get value {
    switch (this) {
      case Command.volumeUp:
        return "VOLUME_UP";
      case Command.volumeDown:
        return "VOLUME_DOWN";
      case Command.pressKeyA:
        return "PRESS_KEY:a";
    }
  }
}
