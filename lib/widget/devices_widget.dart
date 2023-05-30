import 'package:flutter/material.dart';

import '../main.dart';
import 'device_entry.dart';

class DevicesWidget extends StatefulWidget {
  const DevicesWidget({super.key});

  @override
  State<StatefulWidget> createState() => DevicesWidgetState();
}

class DevicesWidgetState extends State<DevicesWidget> {
  Future<void> refresh() async {
    await scanForServers();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final entries = <DeviceEntry>[];
    for (var address in sockets.keys) {
      entries.add(DeviceEntry(address));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: entries,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'button_refresh',
        onPressed: refresh,
        tooltip: 'Refresh devices',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}