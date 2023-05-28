import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:chat/model/chat_event.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'companion.dart';

class MessageEvent implements ChatEvent {
  final bool isMyMessage;
  final String deviceName;
  final String content;
  final DateTime time = DateTime.now();

  MessageEvent._construct(this.isMyMessage , this.deviceName, this.content);

  static final _deviceInfo = DeviceInfoPlugin();

  static Future<String> _getDeviceName() async {
    if (Platform.isAndroid) {
      return (await _deviceInfo.androidInfo).device;
    } else if (Platform.isIOS) {
      return (await _deviceInfo.iosInfo).name;
    } else if (Platform.isWindows) {
      return (await _deviceInfo.windowsInfo).computerName;
    } else if (Platform.isLinux) {
      return (await _deviceInfo.linuxInfo).name;
    } else if (Platform.isMacOS) {
      return (await _deviceInfo.macOsInfo).computerName;
    }
    return Companion.nameUnknown;
  }

  Map<String, dynamic> toJson() => {
    'deviceName': deviceName,
    'content': content
  };

  String toJsonString() => jsonEncode(toJson());

  @override
  String toString() => content;

  MessageEvent.fromJson(Map<String, dynamic> json) :
        deviceName = json['deviceName'],
        content = json['content'],
        isMyMessage = false;

  MessageEvent.fromRaw(Uint8List raw, Encoding encoding) :
        this.fromJson(jsonDecode(encoding.decode(raw)));

  static Future<MessageEvent> empty() async {
    final deviceName = await _getDeviceName();
    return MessageEvent._construct(true, deviceName, '');
  }

  static Future<MessageEvent> make(String content) async {
    final deviceName = await _getDeviceName();
    return MessageEvent._construct(true, deviceName, content);
  }
}