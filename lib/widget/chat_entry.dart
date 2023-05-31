import 'package:chat/model/message_event.dart';
import 'package:flutter/material.dart';

class ChatEntry extends StatelessWidget {
  const ChatEntry(this._socketMsg, {super.key});

  final MessageEvent _socketMsg;

  @override
  Widget build(BuildContext context) {
    String author;
    Icon? leadingIcon;
    Icon? trailingIcon;
    Color color;
    TextAlign align;
    if (_socketMsg.isMyMessage) {
      author = 'Me';
      trailingIcon = const Icon(Icons.face);
      color = Colors.pink.shade100;
      align = TextAlign.end;
    } else {
      author = _socketMsg.deviceName;
      leadingIcon = const Icon(Icons.face_5);
      color = Colors.amber.shade100;
      align = TextAlign.start;
    }
    return Card(
      child: ListTile(
        tileColor: color,
        leading: leadingIcon,
        trailing: trailingIcon,
        title: Text(author, textAlign: align),
        subtitle: Text(_socketMsg.content, textAlign: align),
      ),
    );
  }
}