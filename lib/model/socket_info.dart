import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:chat/model/companion.dart';
import 'package:flutter/cupertino.dart';


class SocketInfo {
  String deviceName = Companion.nameUnknown;
  Socket socket;

  SocketInfo(this.socket);

  String get address => socket.address.address;
  bool get nameIsUnknown => (deviceName == Companion.nameUnknown);

  StreamSubscription<Uint8List> listen(Function(Uint8List event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return socket.listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError
    );
  }

  Companion get companion => Companion(deviceName, address);


  ValueNotifier<int> newMessages = ValueNotifier(0);

  void newMessage() {
    newMessages.value += 1;
  }

  void resetCounter() {
    newMessages.value = 0;
  }
}