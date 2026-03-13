import 'package:client/app/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ipController = TextEditingController();
  String host = '';

  @override
  void dispose() {
    _nameController.dispose();
    _ipController.dispose();
    super.dispose();
  }

  void _connect(AppState appState) {
    final target = _ipController.text.trim();
    if (target.isEmpty) return;

    setState(() {
      host = target;
    });
    appState.connectToServer(target);
  }

  void _saveServer(AppState appState) {
    final ip = _ipController.text.trim();
    final name = _nameController.text.trim();
    if (ip.isNotEmpty) {
      appState.addOrUpdateSavedServer(ip, name: name);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Server saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final connectedAddress = appState.serverAddress?.address;

    final statusText = appState.socket != null
        ? 'Connected to: ${appState.socket?.remoteAddress.address}:${appState.socket?.remotePort}'
        : host.isNotEmpty
            ? 'Trying to connect to: $host'
            : 'Not connected';

    final statusColor = appState.socket != null
        ? colorScheme.primaryContainer
        : host.isNotEmpty
            ? colorScheme.secondaryContainer
            : colorScheme.surfaceContainerHighest;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
              Card(
                elevation: 0,
                color: colorScheme.surfaceContainerLow,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Connection',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Server Name (optional)',
                          hintText: 'e.g. Office Desktop',
                          prefixIcon: Icon(Icons.computer),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _ipController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onSubmitted: (_) => _connect(appState),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Server IP Address',
                          hintText: 'e.g. 192.168.2.12',
                          prefixIcon: Icon(Icons.lan),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _connect(appState),
                              icon: const Icon(Icons.link),
                              label: const Text('Connect to PC'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.tonalIcon(
                            onPressed: () => _saveServer(appState),
                            icon: const Icon(Icons.save_outlined),
                            label: const Text('Save'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              appState.socket != null
                                  ? Icons.check_circle
                                  : host.isNotEmpty
                                      ? Icons.timelapse
                                      : Icons.info_outline,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                statusText,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Card(
                  elevation: 0,
                  color: colorScheme.surfaceContainerLow,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saved Servers',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: appState.savedServers.isEmpty
                              ? Center(
                                  child: Text(
                                    'No saved servers yet',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: appState.savedServers.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 4),
                                  itemBuilder: (context, index) {
                                    final server = appState.savedServers[index];
                                    final hasCustomName =
                                        server.name.trim().isNotEmpty &&
                                            server.name != server.ip;
                                    final displayName =
                                        hasCustomName ? server.name : server.ip;
                                    final isConnected =
                                        connectedAddress == server.ip;

                                    return ListTile(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      tileColor: isConnected
                                          ? colorScheme.primaryContainer
                                          : colorScheme.surface,
                                      leading: CircleAvatar(
                                        backgroundColor: isConnected
                                            ? colorScheme.primary
                                            : colorScheme
                                                .surfaceContainerHighest,
                                        foregroundColor: isConnected
                                            ? colorScheme.onPrimary
                                            : colorScheme.onSurfaceVariant,
                                        child: Icon(
                                          isConnected
                                              ? Icons.laptop_mac
                                              : Icons.devices,
                                        ),
                                      ),
                                      title: Text(displayName),
                                      subtitle: hasCustomName
                                          ? Text(server.ip)
                                          : null,
                                      trailing: IconButton.filledTonal(
                                        onPressed: () {
                                          appState.removeSavedServer(server.ip);
                                        },
                                        icon: const Icon(Icons.delete_outline),
                                        color: colorScheme.error,
                                      ),
                                      onTap: () {
                                        _nameController.text =
                                            hasCustomName ? server.name : '';
                                        _ipController.text = server.ip;
                                        setState(() {
                                          host = server.ip;
                                        });
                                        appState.connectToServer(server.ip);
                                      },
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
