import 'dart:io';
import 'package:flutter/material.dart';

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

  void sendCommand(String command) {
    print('Sending command: $command');
    if (_socket != null) {
      _socket!.write(command);
    } else {
      print('Socket is not connected');
    }
  }

  Future<void> connect(host, port) async {
    print('Connecting to $host:$port...');
    try {
      _socket = await Socket.connect(host, port);
      print('Connected to $host:$port');
      // update the state
      notifyListeners();
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
