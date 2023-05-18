// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hold_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HoldHiveAdapter extends TypeAdapter<HoldHive> {
  @override
  final int typeId = 4;

  @override
  HoldHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HoldHive(
      name: fields[0] as String,
      depth: fields[1] as int,
      angle: fields[2] as int,
      radius: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, HoldHive obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.depth)
      ..writeByte(2)
      ..write(obj.angle)
      ..writeByte(3)
      ..write(obj.radius);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HoldHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
