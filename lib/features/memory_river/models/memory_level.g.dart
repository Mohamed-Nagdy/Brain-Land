// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory_level.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MemoryLevelAdapter extends TypeAdapter<MemoryLevel> {
  @override
  final int typeId = 18;

  @override
  MemoryLevel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MemoryLevel(
      id: fields[0] as String,
      levelNumber: fields[1] as int,
      gridRows: fields[2] as int,
      gridColumns: fields[3] as int,
      difficulty: fields[4] as int,
      timeLimit: fields[5] as int,
      isCompleted: fields[6] as bool,
      starsEarned: fields[7] as int,
      bestMoves: fields[8] as int,
      bestTime: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, MemoryLevel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.levelNumber)
      ..writeByte(2)
      ..write(obj.gridRows)
      ..writeByte(3)
      ..write(obj.gridColumns)
      ..writeByte(4)
      ..write(obj.difficulty)
      ..writeByte(5)
      ..write(obj.timeLimit)
      ..writeByte(6)
      ..write(obj.isCompleted)
      ..writeByte(7)
      ..write(obj.starsEarned)
      ..writeByte(8)
      ..write(obj.bestMoves)
      ..writeByte(9)
      ..write(obj.bestTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemoryLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
