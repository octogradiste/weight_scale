// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grip_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GripHiveAdapter extends TypeAdapter<GripHive> {
  @override
  final int typeId = 3;

  @override
  GripHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GripHive(
      position: fields[0] as GripPositionHive,
      thumb: fields[1] as bool,
      index: fields[2] as bool,
      middle: fields[3] as bool,
      ring: fields[4] as bool,
      pinky: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, GripHive obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.position)
      ..writeByte(1)
      ..write(obj.thumb)
      ..writeByte(2)
      ..write(obj.index)
      ..writeByte(3)
      ..write(obj.middle)
      ..writeByte(4)
      ..write(obj.ring)
      ..writeByte(5)
      ..write(obj.pinky);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GripHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GripPositionHiveAdapter extends TypeAdapter<GripPositionHive> {
  @override
  final int typeId = 2;

  @override
  GripPositionHive read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GripPositionHive.openHand;
      case 1:
        return GripPositionHive.halfCrimp;
      case 2:
        return GripPositionHive.fullCrimp;
      default:
        return GripPositionHive.openHand;
    }
  }

  @override
  void write(BinaryWriter writer, GripPositionHive obj) {
    switch (obj) {
      case GripPositionHive.openHand:
        writer.writeByte(0);
        break;
      case GripPositionHive.halfCrimp:
        writer.writeByte(1);
        break;
      case GripPositionHive.fullCrimp:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GripPositionHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
