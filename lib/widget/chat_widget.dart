import 'dart:async';

import 'package:chat/model/chat_event.dart';
import 'package:chat/model/clear_chat_event.dart';
import 'package:chat/model/message_event.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import 'chat_entry.dart';

class ChatWidget extends StatefulWidget {
  ChatWidget({super.key});

  final StreamController<ChatEvent> _streamController = StreamController<ChatEvent>();

  void streamMessage(MessageEvent msg) {
    _streamController.add(msg);
  }

  void clearChat() {
    _streamController.add(ClearChatEvent());
  }

  @override
  State<StatefulWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  late final _stream = widget._streamController.stream;
  late final StreamSubscription<ChatEvent> _streamSubscription;
  final List<MessageEvent> _messages = <MessageEvent>[];

  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.bounceIn
    );
  }

  void sendMessage() async {
    final msg = await MessageEvent.make(_textController.text);
    final address = companion?.address;
    if (address != null && sockets[address] != null) {
      sockets[address]!.socket.write(msg.toJsonString());
      messageHistory.registerMessage(companion!, msg);
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
  void initState() {
    _streamSubscription = _stream.listen((event) {
      if (event is MessageEvent) {
        _messages.add(event);
      }
      else if (event is ClearChatEvent) {
        _messages.clear();
      }
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String chatTitle = '';
    if (companion != null) {
      chatTitle = companion!.name;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(chatTitle),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (BuildContext context, int index) {
                return ChatEntry(_messages[index]);
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    onSubmitted: (text) {
                      sendMessage();
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  child: FloatingActionButton(
                    heroTag: "button_send_msg",
                    onPressed: () {
                      sendMessage();
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

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }
}