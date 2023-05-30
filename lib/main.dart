import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chat/model/message_history.dart';
import 'package:chat/model/socket_info.dart';
import 'package:chat/widget/chat_widget.dart';
import 'package:chat/widget/devices_widget.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'model/companion.dart';
import 'model/local_subnet.dart';
import 'model/message_event.dart';

final log = Logger();
final myIps = <String>{};

Future<Set<LocalSubnet>> getLocalSubnets() async {
  final subnets = <LocalSubnet>{};
  await NetworkInterface.list().then((interfaces) async {
    for (var interface in interfaces) {
      for (var address in interface.addresses) {
        if (address.type != InternetAddressType.IPv4) continue;
        final subnet = LocalSubnet.fromAddress(address);
        if (subnet != null && subnets.add(subnet)) {
          log.i('Found local subnet: $subnet (${subnet.type.name}-class)');
          myIps.add(address.address);
        }
      }
    }
  });
  return subnets;
}

final sockets = <String, SocketInfo>{};
const port = 6666;

final messageHistory = MessageHistory();
ChatWidget? chatWidget;

Future<bool> tryConnect(String ip) async {
  await Socket.connect(ip, port, timeout: const Duration(seconds: 5)).then((socket) async {
    sockets[ip] = SocketInfo(socket);
    socket.listen((response) async {
      final responseMsg = MessageEvent.fromRaw(response, socket.encoding);
      final deviceName = responseMsg.deviceName;
      final companion = Companion(deviceName, ip);
      if (responseMsg.content.isEmpty) {
        log.i('Found device: $deviceName (${socket.address.address})');
        sockets[ip]!.deviceName = deviceName;
      } else {
        messageHistory.registerMessage(companion, responseMsg);
      }
    });
    return true;
  }).catchError((error) => false);
  return false;
}

Future<void> scanNetwork(LocalSubnet subnet) async {
  for (var i = 0; i < 256; i++) {
    final ip = '$subnet.$i';
    switch (subnet.type) {
      case LocalSubnetType.A:
        final newSubnet = LocalSubnet(ip, LocalSubnetType.C);
        await scanNetwork(newSubnet);
        break;
      case LocalSubnetType.B:
        final newSubnet = LocalSubnet(ip, LocalSubnetType.C);
        await scanNetwork(newSubnet);
        break;
      case LocalSubnetType.C:
        if (!myIps.contains(ip) && !sockets.containsKey(ip)) tryConnect(ip);
        break;
    }
  }
}

Future<void> scanForServers() async {
  final subnets = await getLocalSubnets();
  for (var subnet in subnets) {
    await scanNetwork(subnet);
  }
}

Future<void> startServer() async {
  final server = ServerSocket.bind('0.0.0.0', port);
  server.then((srv) => srv.listen((socket) async {
    final address = socket.remoteAddress.address;
    log.i('$address opened connection');
    socket.write(jsonEncode(await MessageEvent.empty()));
    sockets[address] = SocketInfo(socket);
    socket.listen((response) async {
      final responseMsg = MessageEvent.fromRaw(response, socket.encoding);
      final companion = Companion(responseMsg.deviceName, address);
      messageHistory.registerMessage(companion, responseMsg);
    });
  }));
}

void main() {
  runApp(const MyApp());

  startServer();
  scanForServers();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const DevicesWidget(),
    );
  }
}