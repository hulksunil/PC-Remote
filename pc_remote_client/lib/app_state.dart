import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';

class AppState extends ChangeNotifier {
  String _ip = '';
  String get ip => _ip;

  Socket? socket; // TCP
  RawDatagramSocket? udpSocket; // UDP
  InternetAddress? serverAddress;
  final int udpPort = 5556;

  DateTime _lastMouseSend = DateTime.now();

  void sendMouseMove(int dx, int dy) {
    if (udpSocket == null || serverAddress == null) return;

    final now = DateTime.now();
    if (now.difference(_lastMouseSend).inMilliseconds < 25) return;
    _lastMouseSend = now;

    final command = "MOVE_MOUSE:$dx,$dy;";
    final data = utf8.encode(command);
    udpSocket!.send(data, serverAddress!, udpPort);
  }

  void setIp(String ip) {
    _ip = ip;
    notifyListeners();
  }

  void sendCommand(String command) {
    print('Sending command: $command');
    if (socket != null) {
      socket!.write(command);
    } else {
      print('Socket is not connected');
    }
  }

  Future<void> connectToServer(String ip, int port) async {
    try {
      serverAddress = InternetAddress(ip);

      // TCP
      socket = await Socket.connect(serverAddress!, port);
      print("TCP connected to $ip:$port");

      // UDP
      udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      print("UDP socket bound to ${udpSocket!.port}");

      notifyListeners();
    } catch (e) {
      print("Connection error: $e");
    }
  }

  // NOTE: This will disconnect the socket when this page is disposed
  @override
  void dispose() {
    socket?.destroy();
    udpSocket?.close();
    super.dispose();
  }
}
