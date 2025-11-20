// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'level.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LevelAdapter extends TypeAdapter<Level> {
  @override
  final int typeId = 2;

  @override
  Level read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Level(
      id: fields[0] as String,
      zoneId: fields[1] as String,
      levelNumber: fields[2] as int,
      difficulty: fields[3] as int,
      targetScore: fields[4] as int,
      timeLimit: fields[5] as int,
      isCompleted: fields[6] as bool,
      starsEarned: fields[7] as int,
      bestScore: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Level obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.zoneId)
      ..writeByte(2)
      ..write(obj.levelNumber)
      ..writeByte(3)
      ..write(obj.difficulty)
      ..writeByte(4)
      ..write(obj.targetScore)
      ..writeByte(5)
      ..write(obj.timeLimit)
      ..writeByte(6)
      ..write(obj.isCompleted)
      ..writeByte(7)
      ..write(obj.starsEarned)
      ..writeByte(8)
      ..write(obj.bestScore);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
