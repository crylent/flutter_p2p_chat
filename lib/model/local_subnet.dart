import 'dart:io';

enum LocalSubnetType { A, B, C }

class LocalSubnet {
  final String subnet;
  final LocalSubnetType type;

  LocalSubnet(this.subnet, this.type);

  static final _typeA = RegExp(r'^([\d]{1,3}).[\d]{1,3}.[\d]{1,3}.[\d]{1,3}$');
  static final _typeB = RegExp(r'^([\d]{1,3}.[\d]{1,3}).[\d]{1,3}.[\d]{1,3}$');
  static final _typeC = RegExp(r'^([\d]{1,3}.[\d]{1,3}.[\d]{1,3}).[\d]{1,3}$');

  static LocalSubnet? fromAddress(InternetAddress address) {
    final raw = address.rawAddress;
    LocalSubnetType? type;
    if (raw[0] == 10) type = LocalSubnetType.A;
    if (raw[0] == 172 && (raw[1] >= 16 && raw[1] <= 31)) type = LocalSubnetType.B;
    if (raw[0] == 192 && raw[1] == 168) type = LocalSubnetType.C;
    if (type == null) return null;
    RegExp regExp;
    switch (type) {
      case LocalSubnetType.A: regExp = _typeA; break;
      case LocalSubnetType.B: regExp = _typeB; break;
      case LocalSubnetType.C: regExp = _typeC; break;
    }
    final subnet = regExp.firstMatch(address.address)!.group(1)!;
    return LocalSubnet(subnet, type);
  }

  @override
  String toString() => subnet;

  @override
  int get hashCode => subnet.hashCode;

  @override
  bool operator ==(Object other) =>
      other is LocalSubnet
      && other.subnet == subnet;
}