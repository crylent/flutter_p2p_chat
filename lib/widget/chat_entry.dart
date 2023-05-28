import 'package:chat/model/message_event.dart';
import 'package:flutter/material.dart';

class ChatEntry extends StatelessWidget {
  const ChatEntry(this._socketMsg, {super.key});

  final MessageEvent _socketMsg;

  @override
  Widget build(BuildContext context) {
    String author;
    if (_socketMsg.isMyMessage) {
      author = 'Me';
    } else {
      author = _socketMsg.deviceName;
    }
    return ListTile(
      title: Text(author),
      subtitle: Text(_socketMsg.content),
    );
  }
}