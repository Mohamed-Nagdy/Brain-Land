// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logic_level.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LogicLevelAdapter extends TypeAdapter<LogicLevel> {
  @override
  final int typeId = 16;

  @override
  LogicLevel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LogicLevel(
      id: fields[0] as String,
      levelNumber: fields[1] as int,
      difficulty: fields[2] as int,
      timeLimit: fields[3] as int,
      targetScore: fields[4] as int,
      isCompleted: fields[5] as bool,
      starsEarned: fields[6] as int,
      bestScore: fields[7] as int,
      bestAccuracy: fields[8] as int,
      hintsUsed: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, LogicLevel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.levelNumber)
      ..writeByte(2)
      ..write(obj.difficulty)
      ..writeByte(3)
      ..write(obj.timeLimit)
      ..writeByte(4)
      ..write(obj.targetScore)
      ..writeByte(5)
      ..write(obj.isCompleted)
      ..writeByte(6)
      ..write(obj.starsEarned)
      ..writeByte(7)
      ..write(obj.bestScore)
      ..writeByte(8)
      ..write(obj.bestAccuracy)
      ..writeByte(9)
      ..write(obj.hintsUsed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LogicLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
