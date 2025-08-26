import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:client/services/navigation_service.dart';
import 'package:client/pages/settings_page.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppState extends ChangeNotifier {
  String _ip = '';
  String get ip => _ip;

  InternetAddress? serverAddress;
  RawDatagramSocket? udpSocket; // UDP
  final int udpPort = 5556; // UDP port
  Socket? socket; // TCP
  final int port = 5555; // TCP port

  Color _themeColor =
      Colors.red; // Default Theme Color (gets changed in settings)
  Color get themeColor => _themeColor;

  void setThemeColor(Color color) {
    _themeColor = color;
    notifyListeners();
  }

  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  DateTime _lastMouseSend = DateTime.now();

  bool _navigatingToSettings = false;

  void navigateToSettingsOnce() {
    if (_navigatingToSettings) return;

    _navigatingToSettings = true;
    Fluttertoast.showToast(
      msg: "Device not connected to server, please reconnect",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    navigatorKey.currentState
        ?.push(
      MaterialPageRoute(builder: (_) => SettingsPage()),
    )
        .then((_) {
      _navigatingToSettings = false; // Reset after navigation finishes
    });
  }

  bool get isConnected => udpSocket != null && serverAddress != null;

  void sendMouseMove(int dx, int dy) {
    if (!isConnected) {
      navigateToSettingsOnce();
      return;
    }

    final now = DateTime.now();
    if (now.difference(_lastMouseSend).inMilliseconds < 25) return;
    _lastMouseSend = now;

    final command = "MOVE_MOUSE:$dx,$dy;";
    final data = utf8.encode(command);
    udpSocket!.send(data, serverAddress!, udpPort);
  }

  void sendScroll(int dy) {
    if (!isConnected) {
      navigateToSettingsOnce();
      return;
    }

    final command = "SCROLL:$dy;";
    final data = utf8.encode(command);
    udpSocket!.send(data, serverAddress!, udpPort);
  }

  void setIp(String ip) {
    _ip = ip;
    notifyListeners();
  }

  void sendCommand(String command) {
    print('Sending command: $command');
    try {
      if (socket != null) {
        socket!.write(command);
      } else {
        navigateToSettingsOnce();
      }
    } catch (e) {
      // TODO(sunil): Check if this works properly
      print('Error sending command: $e');
      Fluttertoast.showToast(
        msg: "Socket was closed, please reconnect",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      socket?.destroy();
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => SettingsPage()),
      );
    }
  }

  Completer<String>? _responseCompleter;

  void _setupSocketListener() {
    socket!.listen((List<int> data) {
      final response = utf8.decode(data).trim();
      print('Received response: $response');

      if (response == "WELCOME") {
        // ✅ Only now do we consider ourselves connected
        print("Server accepted connection!");
        notifyListeners();
      } else if (response == "REJECT") {
        print("Server rejected connection");
        Fluttertoast.showToast(
          msg: "Server rejected connection (another client already connected)",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        disconnect();
      }

      // Complete the waiting future if one exists
      if (_responseCompleter != null && !_responseCompleter!.isCompleted) {
        _responseCompleter!.complete(response);
      }
    }, onError: (error) {
      print('Socket error: $error');
      disconnect();
    }, onDone: () {
      print('Socket closed');
      disconnect();
    });
  }

  Future<String> sendCommandAndGetResponse(String command) async {
    print('Sending command: $command');
    if (socket != null) {
      try {
        _responseCompleter = Completer<String>();
        socket!.write(command);
        socket!.flush();
        return await _responseCompleter!.future
            .timeout(const Duration(seconds: 2)); // Optional timeout
      } catch (e) {
        print('Error sending or receiving: $e');
        return '';
      }
    } else {
      print('Socket is not connected');
      return '';
    }
  }

  Future<void> connectToServer(String ip) async {
    try {
      serverAddress = InternetAddress(ip);
      print("Attempting connection to server at $ip with port $port...");

      // TCP
      socket = await Socket.connect(serverAddress!, port);

      // UDP
      udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);

      print("TCP connected (waiting for server WELCOME)...");
      print("UDP socket bound to ${udpSocket!.port}");

      _setupSocketListener();
      // notifyListeners();
    } catch (e) {
      print("Connection error: $e");
      disconnect();
    }
  }

  void disconnect() {
    socket?.destroy();
    socket = null;
    udpSocket?.close();
    udpSocket = null;
    serverAddress = null;
    notifyListeners();
  }

  // NOTE: This will disconnect the socket when this page is disposed
  @override
  void dispose() {
    socket?.destroy();
    udpSocket?.close();
    super.dispose();
  }
}
