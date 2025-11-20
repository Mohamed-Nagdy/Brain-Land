// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shape_level.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShapeLevelAdapter extends TypeAdapter<ShapeLevel> {
  @override
  final int typeId = 20;

  @override
  ShapeLevel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShapeLevel(
      id: fields[0] as String,
      levelNumber: fields[1] as int,
      difficulty: fields[2] as int,
      shapes: (fields[3] as List).cast<Shape>(),
      targets: (fields[4] as List).cast<ShapeTarget>(),
      sortingRule: fields[5] as SortingRule,
      timeLimit: fields[6] as int,
      targetScore: fields[7] as int,
      isCompleted: fields[8] as bool,
      starsEarned: fields[9] as int,
      bestScore: fields[10] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ShapeLevel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.levelNumber)
      ..writeByte(2)
      ..write(obj.difficulty)
      ..writeByte(3)
      ..write(obj.shapes)
      ..writeByte(4)
      ..write(obj.targets)
      ..writeByte(5)
      ..write(obj.sortingRule)
      ..writeByte(6)
      ..write(obj.timeLimit)
      ..writeByte(7)
      ..write(obj.targetScore)
      ..writeByte(8)
      ..write(obj.isCompleted)
      ..writeByte(9)
      ..write(obj.starsEarned)
      ..writeByte(10)
      ..write(obj.bestScore);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShapeLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
