import 'dart:convert';

import 'package:client/models/saved_server.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IPStorage {
  static const _legacyIpsKey = 'saved_ips';
  static const _serversKey = 'saved_servers';

  static Future<void> saveServers(List<SavedServer> servers) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedServers = servers
        .map((server) => jsonEncode(server.toJson()))
        .toList(growable: false);

    await prefs.setStringList(_serversKey, encodedServers);
  }

  static Future<List<SavedServer>> loadServers() async {
    final prefs = await SharedPreferences.getInstance();
    final storedServers = prefs.getStringList(_serversKey) ?? [];

    if (storedServers.isNotEmpty) {
      final decodedServers = <SavedServer>[];

      for (final encoded in storedServers) {
        try {
          final parsed = jsonDecode(encoded);
          if (parsed is Map<String, dynamic>) {
            final server = SavedServer.fromJson(parsed);
            if (server.ip.isNotEmpty) {
              decodedServers.add(server);
            }
          }
        } catch (_) {
          // Ignore malformed entries and continue.
        }
      }

      return decodedServers;
    }

    // Backward compatibility for older app versions that stored only IP strings.
    final legacyIps = prefs.getStringList(_legacyIpsKey) ?? [];
    return legacyIps
        .map((ip) => ip.trim())
        .where((ip) => ip.isNotEmpty)
        .map((ip) => SavedServer(name: ip, ip: ip))
        .toList(growable: false);
  }
}
