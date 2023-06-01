class Companion {
  final String name;
  final String address;

  Companion(this.name, this.address);

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Companion &&
          runtimeType == other.runtimeType &&
          address == other.address;

  @override
  int get hashCode => address.hashCode;

  const Companion.me() :
      name = 'Me',
      address = '0.0.0.0';

  static const nameUnknown = 'Unknown';
}