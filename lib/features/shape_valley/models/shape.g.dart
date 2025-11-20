// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shape.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShapeAdapter extends TypeAdapter<Shape> {
  @override
  final int typeId = 24;

  @override
  Shape read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Shape(
      id: fields[0] as String,
      type: fields[1] as ShapeType,
      color: fields[2] as ShapeColor,
      size: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Shape obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.color)
      ..writeByte(3)
      ..write(obj.size);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShapeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ShapeTargetAdapter extends TypeAdapter<ShapeTarget> {
  @override
  final int typeId = 23;

  @override
  ShapeTarget read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShapeTarget(
      id: fields[0] as String,
      rule: fields[1] as SortingRule,
      requiredType: fields[2] as ShapeType?,
      requiredColor: fields[3] as ShapeColor?,
      requiredSize: fields[4] as int?,
      label: fields[5] as String,
      isFilled: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ShapeTarget obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.rule)
      ..writeByte(2)
      ..write(obj.requiredType)
      ..writeByte(3)
      ..write(obj.requiredColor)
      ..writeByte(4)
      ..write(obj.requiredSize)
      ..writeByte(5)
      ..write(obj.label)
      ..writeByte(6)
      ..write(obj.isFilled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShapeTargetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ShapeTypeAdapter extends TypeAdapter<ShapeType> {
  @override
  final int typeId = 19;

  @override
  ShapeType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ShapeType.circle;
      case 1:
        return ShapeType.square;
      case 2:
        return ShapeType.triangle;
      case 3:
        return ShapeType.rectangle;
      case 4:
        return ShapeType.star;
      case 5:
        return ShapeType.heart;
      case 6:
        return ShapeType.diamond;
      case 7:
        return ShapeType.hexagon;
      default:
        return ShapeType.circle;
    }
  }

  @override
  void write(BinaryWriter writer, ShapeType obj) {
    switch (obj) {
      case ShapeType.circle:
        writer.writeByte(0);
        break;
      case ShapeType.square:
        writer.writeByte(1);
        break;
      case ShapeType.triangle:
        writer.writeByte(2);
        break;
      case ShapeType.rectangle:
        writer.writeByte(3);
        break;
      case ShapeType.star:
        writer.writeByte(4);
        break;
      case ShapeType.heart:
        writer.writeByte(5);
        break;
      case ShapeType.diamond:
        writer.writeByte(6);
        break;
      case ShapeType.hexagon:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShapeTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ShapeColorAdapter extends TypeAdapter<ShapeColor> {
  @override
  final int typeId = 21;

  @override
  ShapeColor read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ShapeColor.red;
      case 1:
        return ShapeColor.blue;
      case 2:
        return ShapeColor.green;
      case 3:
        return ShapeColor.yellow;
      case 4:
        return ShapeColor.purple;
      case 5:
        return ShapeColor.orange;
      case 6:
        return ShapeColor.pink;
      case 7:
        return ShapeColor.cyan;
      default:
        return ShapeColor.red;
    }
  }

  @override
  void write(BinaryWriter writer, ShapeColor obj) {
    switch (obj) {
      case ShapeColor.red:
        writer.writeByte(0);
        break;
      case ShapeColor.blue:
        writer.writeByte(1);
        break;
      case ShapeColor.green:
        writer.writeByte(2);
        break;
      case ShapeColor.yellow:
        writer.writeByte(3);
        break;
      case ShapeColor.purple:
        writer.writeByte(4);
        break;
      case ShapeColor.orange:
        writer.writeByte(5);
        break;
      case ShapeColor.pink:
        writer.writeByte(6);
        break;
      case ShapeColor.cyan:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShapeColorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SortingRuleAdapter extends TypeAdapter<SortingRule> {
  @override
  final int typeId = 22;

  @override
  SortingRule read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SortingRule.byType;
      case 1:
        return SortingRule.byColor;
      case 2:
        return SortingRule.bySize;
      case 3:
        return SortingRule.byTypeAndColor;
      default:
        return SortingRule.byType;
    }
  }

  @override
  void write(BinaryWriter writer, SortingRule obj) {
    switch (obj) {
      case SortingRule.byType:
        writer.writeByte(0);
        break;
      case SortingRule.byColor:
        writer.writeByte(1);
        break;
      case SortingRule.bySize:
        writer.writeByte(2);
        break;
      case SortingRule.byTypeAndColor:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SortingRuleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
