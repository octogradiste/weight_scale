// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseHiveAdapter extends TypeAdapter<ExerciseHive> {
  @override
  final int typeId = 1;

  @override
  ExerciseHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseHive(
      fields[0] as String,
      fields[1] as int,
      fields[2] as int,
      fields[3] as int,
      fields[4] as int,
      fields[5] as int,
      fields[6] as int,
      fields[7] as HandsHive,
      fields[8] as int,
      fields[9] as double,
      fields[10] as double,
      fields[11] as GripHive,
      fields[12] as HoldHive,
      fields[13] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseHive obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.countdownMillis)
      ..writeByte(2)
      ..write(obj.reps)
      ..writeByte(3)
      ..write(obj.hangTimeMillis)
      ..writeByte(4)
      ..write(obj.restBetweenRepsMillis)
      ..writeByte(5)
      ..write(obj.sets)
      ..writeByte(6)
      ..write(obj.restBetweenSetsMillis)
      ..writeByte(7)
      ..write(obj.hands)
      ..writeByte(8)
      ..write(obj.restBetweenHandsMillis)
      ..writeByte(9)
      ..write(obj.target)
      ..writeByte(10)
      ..write(obj.deviation)
      ..writeByte(11)
      ..write(obj.grip)
      ..writeByte(12)
      ..write(obj.hold)
      ..writeByte(13)
      ..write(obj.isAssessment);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HandsHiveAdapter extends TypeAdapter<HandsHive> {
  @override
  final int typeId = 0;

  @override
  HandsHive read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HandsHive.both;
      case 1:
        return HandsHive.block_wise;
      default:
        return HandsHive.both;
    }
  }

  @override
  void write(BinaryWriter writer, HandsHive obj) {
    switch (obj) {
      case HandsHive.both:
        writer.writeByte(0);
        break;
      case HandsHive.block_wise:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HandsHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
