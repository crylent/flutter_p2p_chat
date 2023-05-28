import 'package:chat/main.dart';
import 'package:chat/model/socket_info.dart';
import 'package:chat/widget/chat_widget.dart';
import 'package:flutter/material.dart';

class DeviceEntry extends StatelessWidget {
  final SocketInfo _socketInfo;

  const DeviceEntry(this._socketInfo, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(_socketInfo.deviceName),
      subtitle: Text(_socketInfo.address),
      trailing: FloatingActionButton.extended(
        onPressed: () {
          companion = _socketInfo.companion;
          chatWidget = ChatWidget();
          Navigator.push(context, MaterialPageRoute(builder: (context) => chatWidget!));
          messageHistory[companion]?.forEach((msg) {
            chatWidget!.streamMessage(msg);
          });
        },
        icon: const Icon(Icons.speaker_notes),
        label: const Text('Chat'),
      ),
    );
  }
}