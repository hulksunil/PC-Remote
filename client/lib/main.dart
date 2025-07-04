import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pc_remote_client/app/app_state.dart';
import 'package:pc_remote_client/pages/mouse_control_page.dart';
import 'package:pc_remote_client/pages/keyboard_control_page.dart';
import 'package:pc_remote_client/pages/media_control_page.dart';
import 'package:pc_remote_client/pages/settings_page.dart';
import 'package:pc_remote_client/services/navigation_service.dart';
import 'package:pc_remote_client/pages/power_control_page.dart';

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
            title: 'PC Remote',
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
      title: const Text('PC Remote'),
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
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    int selectedIndex = appState.selectedIndex;

    Widget pageToDisplay;
    switch (selectedIndex) {
      case 0:
        pageToDisplay = MouseControlPage();
      case 1:
        pageToDisplay = MediaControlPage();
      case 2:
        pageToDisplay = PowerSettingsPage();
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
          context.read<AppState>().setSelectedIndex(index);
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
