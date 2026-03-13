class SavedServer {
  final String name;
  final String ip;

  const SavedServer({required this.name, required this.ip});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ip': ip,
    };
  }

  factory SavedServer.fromJson(Map<String, dynamic> json) {
    final rawIp = (json['ip'] ?? '').toString().trim();
    final rawName = (json['name'] ?? '').toString().trim();

    return SavedServer(
      ip: rawIp,
      name: rawName.isEmpty ? rawIp : rawName,
    );
  }
}
