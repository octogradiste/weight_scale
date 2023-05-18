// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hang_board_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HangBoardHiveAdapter extends TypeAdapter<HangBoardHive> {
  @override
  final int typeId = 5;

  @override
  HangBoardHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HangBoardHive(
      name: fields[0] as String,
      holds: (fields[1] as List).cast<HoldHive>(),
    );
  }

  @override
  void write(BinaryWriter writer, HangBoardHive obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.holds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HangBoardHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
