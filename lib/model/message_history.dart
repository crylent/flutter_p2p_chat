import 'dart:collection';

import 'package:chat/main.dart';
import 'package:chat/model/message_event.dart';

import 'companion.dart';

class MessageHistory extends MapBase<Companion, List<MessageEvent>> {
  final Map<Companion, List<MessageEvent>> _map = HashMap();

  @override List<MessageEvent>? operator [](Object? key) {
    _createKeyIfNeed(key as Companion);
    return _map[key];
  }
  @override void operator []=(Companion key, List<MessageEvent> value) => _map[key] = value;
  @override void clear() => _map.clear();
  @override Iterable<Companion> get keys => _map.keys;
  @override List<MessageEvent>? remove(Object? key) => _map.remove(key);

  void _createKeyIfNeed(Companion key) {
    if (!_map.containsKey(key)) {
      _map[key] = <MessageEvent>[];
    }
  }

  void registerMessage(Companion companion, MessageEvent msg) {
    if (msg.content.isEmpty) return;
    _createKeyIfNeed(companion);
    _map[companion]!.add(msg);
    final chatIsOpened = companion == chatWidget?.companion;
    if (!msg.isMyMessage) {
      log.i("Got message from $companion: $msg");
      if (!chatIsOpened) {
        sockets[companion.address]?.newMessage();
      }
    }
    if (chatIsOpened) {
      chatWidget!.streamMessage(msg);
    }
  }
}