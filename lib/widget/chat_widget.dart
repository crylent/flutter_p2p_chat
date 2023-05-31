import 'dart:async';

import 'package:chat/model/chat_event.dart';
import 'package:chat/model/clear_chat_event.dart';
import 'package:chat/model/message_event.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../model/companion.dart';
import 'chat_entry.dart';

class ChatWidget extends StatelessWidget {
  final Companion companion;
  ChatWidget(this.companion, {super.key});

  final _streamController = StreamController<ChatEvent>();
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  void _scrollDown() {
    _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.bounceIn
    );
  }

  void _sendMessage(BuildContext context) async {
    final msg = await MessageEvent.make(_textController.text);
    final address = companion.address;
    if (sockets[address] != null) {
      sockets[address]!.socket.write(msg.toJsonString());
      messageHistory.registerMessage(companion, msg);
      log.i("Sent message to $companion: $msg");
      _textController.clear();
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Error when sending message"),
            )
        );
      }
      log.e("Can't send message to $companion");
    }
    _scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    final List<MessageEvent> messages = messageHistory[companion]!;
    return Scaffold(
      appBar: AppBar(
        title: Text(companion.name),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: StreamBuilder<ChatEvent>(
              stream: _streamController.stream,
              builder: (BuildContext context, AsyncSnapshot<ChatEvent> snapshot) {
                final event = snapshot.data;
                if (event is ClearChatEvent) {
                  messages.clear();
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ChatEntry(messages[index]);
                  },
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(fontSize: 20),
                      onSubmitted: (text) {
                        _sendMessage(context);
                      },
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  child: FloatingActionButton(
                    heroTag: "button_send_msg",
                    onPressed: () {
                      _sendMessage(context);
                    },
                    tooltip: 'Send message',
                    child: const Icon(Icons.question_answer),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void streamMessage(MessageEvent msg) {
    _streamController.add(msg);
  }

  void clearChat() {
    _streamController.add(ClearChatEvent());
  }
}