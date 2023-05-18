// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_log_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MeasurementHiveAdapter extends TypeAdapter<MeasurementHive> {
  @override
  final int typeId = 7;

  @override
  MeasurementHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MeasurementHive(
      weight: fields[0] as double,
      elapsed: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, MeasurementHive obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.weight)
      ..writeByte(1)
      ..write(obj.elapsed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeasurementHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExerciseLogHiveAdapter extends TypeAdapter<ExerciseLogHive> {
  @override
  final int typeId = 8;

  @override
  ExerciseLogHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseLogHive(
      date: fields[0] as DateTime,
      exercise: fields[1] as ExerciseHive,
      weight: fields[2] as double,
      mark: fields[3] as int,
      note: fields[4] as String,
      stats: fields[5] as ExerciseStatsHive,
      measurements: (fields[6] as List).cast<MeasurementHive>(),
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseLogHive obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.exercise)
      ..writeByte(2)
      ..write(obj.weight)
      ..writeByte(3)
      ..write(obj.mark)
      ..writeByte(4)
      ..write(obj.note)
      ..writeByte(5)
      ..write(obj.stats)
      ..writeByte(6)
      ..write(obj.measurements);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseLogHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
