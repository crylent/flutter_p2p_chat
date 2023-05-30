import 'dart:math';

import 'package:badges/badges.dart' as badges;
import 'package:chat/main.dart';
import 'package:chat/widget/chat_widget.dart';
import 'package:flutter/material.dart';

class DeviceEntry extends StatefulWidget {
  final String _address;

  const DeviceEntry(this._address, {super.key});

  @override
  State<StatefulWidget> createState() => DeviceEntryState();
}

class DeviceEntryState extends State<DeviceEntry> {
  final heroId = Random().nextInt(0x7fffffff);

  @override
  Widget build(BuildContext context) {
    final socket = sockets[widget._address]!;
    final chatButton = FloatingActionButton.extended(
      heroTag: 'chat_button_$heroId',
      onPressed: () {
        companion = socket.companion;
        chatWidget = ChatWidget();
        Navigator.push(context, MaterialPageRoute(builder: (context) => chatWidget!));
        messageHistory[companion]?.forEach((msg) {
          chatWidget!.streamMessage(msg);
        });
      },
      icon: const Icon(Icons.speaker_notes),
      label: const Text('Chat'),
    );
    Widget trailing;
    if (socket.newMessages > 0) {
      trailing = badges.Badge(
        badgeContent: SizedBox(
          width: 24,
          height: 24,
          child: Center(
            child: Text(
                socket.newMessages.toString(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16
                )
            ),
          ),
        ),
        position: badges.BadgePosition.bottomStart(bottom: -12, start: -20),
        child: chatButton,
      );
    } else {
      trailing = chatButton;
    }
    return ListTile(
      title: Text(socket.deviceName),
      subtitle: Text(socket.address),
      trailing: trailing,
    );
  }
}