class Uuid {
  final String uuid;

  const Uuid(this.uuid);

  @override
  bool operator ==(Object other) => other is Uuid && other.uuid == uuid;

  @override
  int get hashCode => uuid.hashCode;
}
