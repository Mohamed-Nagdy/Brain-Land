// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zone_progress.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ZoneProgressAdapter extends TypeAdapter<ZoneProgress> {
  @override
  final int typeId = 3;

  @override
  ZoneProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ZoneProgress(
      zoneId: fields[0] as String,
      levelsCompleted: fields[1] as int,
      totalStars: fields[2] as int,
      bestAccuracy: fields[3] as int,
      lastPlayedAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ZoneProgress obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.zoneId)
      ..writeByte(1)
      ..write(obj.levelsCompleted)
      ..writeByte(2)
      ..write(obj.totalStars)
      ..writeByte(3)
      ..write(obj.bestAccuracy)
      ..writeByte(4)
      ..write(obj.lastPlayedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZoneProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
