// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_stats_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseStatsHiveAdapter extends TypeAdapter<ExerciseStatsHive> {
  @override
  final int typeId = 6;

  @override
  ExerciseStatsHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseStatsHive(
      percentInTargetLeft: fields[0] as int,
      percentInTargetRight: fields[1] as int,
      averagePullLeft: fields[2] as double,
      averagePullRight: fields[3] as double,
      maxPullLeft: fields[4] as double,
      maxPullRight: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseStatsHive obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.percentInTargetLeft)
      ..writeByte(1)
      ..write(obj.percentInTargetRight)
      ..writeByte(2)
      ..write(obj.averagePullLeft)
      ..writeByte(3)
      ..write(obj.averagePullRight)
      ..writeByte(4)
      ..write(obj.maxPullLeft)
      ..writeByte(5)
      ..write(obj.maxPullRight);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseStatsHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
