import 'package:shared_preferences/shared_preferences.dart';

class IPStorage {
  static const _key = 'saved_ips';

  static Future<void> saveIPs(List<String> ips) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, ips);
  }

  static Future<List<String>> loadIPs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }
}
