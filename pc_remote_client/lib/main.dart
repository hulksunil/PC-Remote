import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pc_remote_client/app_state.dart';
import 'package:pc_remote_client/mouse_control_page.dart';
import 'package:pc_remote_client/keyboard_control_page.dart';
import 'package:pc_remote_client/volume_control_page.dart';
import 'package:pc_remote_client/settings_page.dart';
import 'package:pc_remote_client/navigation_service.dart';

// NOTE: dart.io is used for socket communication only for mobile
// NOTE: For web, you would typically use WebSockets or HTTP requests since web apps are not allowed to use sockets directly due to security restrictions.
void main() => runApp(const MyApp());

// NOTE: The main function is the entry point of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'PC Remote Client',
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: appState.themeColor),
            ),
            home: const HomePage(),
          );
        },
      ),
    );
  }
}

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('PC Remote Control'),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          },
        ),
      ],
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
        pageToDisplay = MouseControlPage();
      case 1:
        pageToDisplay = VolumeControlPage();
      case 2:
        pageToDisplay = Placeholder();
      case 3:
        pageToDisplay = KeyboardControlPage();
      default:
        throw UnimplementedError('No widget for $selectedIndex');
    }

    return Scaffold(
      appBar: const MainAppBar(),
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
