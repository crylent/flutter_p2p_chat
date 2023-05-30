import 'dart:math';

import 'package:badges/badges.dart' as badges;
import 'package:chat/main.dart';
import 'package:chat/model/socket_info.dart';
import 'package:chat/widget/chat_widget.dart';
import 'package:flutter/material.dart';

class DeviceEntry extends StatelessWidget {
  final SocketInfo _socket;

  DeviceEntry(this._socket, {super.key});

  final heroId = Random().nextInt(0x7fffffff);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(_socket.deviceName),
      subtitle: Text(_socket.address),
      trailing: ValueListenableBuilder<int>(
        builder: (BuildContext context, int value, Widget? child) {
          Widget trailing;
          if (value > 0) {
            trailing = badges.Badge(
              badgeContent: SizedBox(
                width: 24,
                height: 24,
                child: Center(
                  child: Text(
                      value.toString(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16
                      )
                  ),
                ),
              ),
              position: badges.BadgePosition.bottomStart(bottom: -12, start: -20),
              child: child!,
            );
          } else {
            trailing = child!;
          }
          return trailing;
        },
        valueListenable: _socket.newMessages,
        child: FloatingActionButton.extended(
          heroTag: 'chat_button_$heroId',
          onPressed: () {
            companion = _socket.companion;
            chatWidget = ChatWidget();
            Navigator.push(context, MaterialPageRoute(builder: (context) => chatWidget!));
            messageHistory[companion]?.forEach((msg) {
              chatWidget!.streamMessage(msg);
            });
            _socket.resetCounter();
          },
          icon: const Icon(Icons.speaker_notes),
          label: const Text('Chat'),
        ),
      ),
    );
  }
}