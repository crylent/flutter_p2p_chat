import 'dart:collection';

import 'package:chat/main.dart';
import 'package:chat/model/message_event.dart';

import 'companion.dart';

class MessageHistory extends MapBase<Companion, List<MessageEvent>> {
  final Map<Companion, List<MessageEvent>> _map = HashMap();

  @override List<MessageEvent>? operator [](Object? key) => _map[key];
  @override void operator []=(Companion key, List<MessageEvent> value) => _map[key] = value;
  @override void clear() => _map.clear();
  @override Iterable<Companion> get keys => _map.keys;
  @override List<MessageEvent>? remove(Object? key) => _map.remove(key);

  void registerMessage(Companion device, MessageEvent msg) {
    if (!_map.containsKey(device)) {
      _map[device] = <MessageEvent>[];
    }
    _map[device]!.add(msg);
    if (device != const Companion.me()) {
      log.i("Got message from $device: $msg");
      sockets[device.address]?.newMessage();
    }
    if ((device == const Companion.me() || device == companion) && chatWidget != null) {
      chatWidget!.streamMessage(msg);
    }
  }
}