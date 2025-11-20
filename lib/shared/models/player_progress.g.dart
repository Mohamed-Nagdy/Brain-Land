// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_progress.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlayerProgressAdapter extends TypeAdapter<PlayerProgress> {
  @override
  final int typeId = 4;

  @override
  PlayerProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlayerProgress(
      playerId: fields[0] as String,
      totalStars: fields[1] as int,
      totalCoins: fields[2] as int,
      zoneProgress: (fields[3] as Map).cast<String, ZoneProgress>(),
      unlockedPets: (fields[4] as List).cast<String>(),
      unlockedStickers: (fields[5] as List).cast<String>(),
      unlockedAvatarItems: (fields[6] as List).cast<String>(),
      currentStreak: fields[7] as int,
      lastLoginDate: fields[8] as DateTime,
      totalPlayTime: fields[9] as int,
      createdAt: fields[10] as DateTime,
      updatedAt: fields[11] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PlayerProgress obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.playerId)
      ..writeByte(1)
      ..write(obj.totalStars)
      ..writeByte(2)
      ..write(obj.totalCoins)
      ..writeByte(3)
      ..write(obj.zoneProgress)
      ..writeByte(4)
      ..write(obj.unlockedPets)
      ..writeByte(5)
      ..write(obj.unlockedStickers)
      ..writeByte(6)
      ..write(obj.unlockedAvatarItems)
      ..writeByte(7)
      ..write(obj.currentStreak)
      ..writeByte(8)
      ..write(obj.lastLoginDate)
      ..writeByte(9)
      ..write(obj.totalPlayTime)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
