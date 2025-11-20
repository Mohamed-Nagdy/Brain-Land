// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zone.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ZoneAdapter extends TypeAdapter<Zone> {
  @override
  final int typeId = 1;

  @override
  Zone read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Zone(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      iconPath: fields[3] as String,
      type: fields[4] as ZoneType,
      isUnlocked: fields[5] as bool,
      totalLevels: fields[6] as int,
      completedLevels: fields[7] as int,
      availableGames: (fields[8] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Zone obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.iconPath)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.isUnlocked)
      ..writeByte(6)
      ..write(obj.totalLevels)
      ..writeByte(7)
      ..write(obj.completedLevels)
      ..writeByte(8)
      ..write(obj.availableGames);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZoneAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ZoneTypeAdapter extends TypeAdapter<ZoneType> {
  @override
  final int typeId = 0;

  @override
  ZoneType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ZoneType.mathForest;
      case 1:
        return ZoneType.logicMountain;
      case 2:
        return ZoneType.memoryRiver;
      case 3:
        return ZoneType.shapeValley;
      default:
        return ZoneType.mathForest;
    }
  }

  @override
  void write(BinaryWriter writer, ZoneType obj) {
    switch (obj) {
      case ZoneType.mathForest:
        writer.writeByte(0);
        break;
      case ZoneType.logicMountain:
        writer.writeByte(1);
        break;
      case ZoneType.memoryRiver:
        writer.writeByte(2);
        break;
      case ZoneType.shapeValley:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZoneTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
