// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reward.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RewardAdapter extends TypeAdapter<Reward> {
  @override
  final int typeId = 10;

  @override
  Reward read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Reward(
      id: fields[0] as String,
      type: fields[1] as RewardType,
      name: fields[2] as String,
      description: fields[3] as String,
      iconPath: fields[4] as String,
      rarity: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Reward obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.iconPath)
      ..writeByte(5)
      ..write(obj.rarity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RewardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RewardChestAdapter extends TypeAdapter<RewardChest> {
  @override
  final int typeId = 12;

  @override
  RewardChest read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RewardChest(
      id: fields[0] as String,
      type: fields[1] as ChestType,
      rewards: (fields[2] as List).cast<Reward>(),
      earnedAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, RewardChest obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.rewards)
      ..writeByte(3)
      ..write(obj.earnedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RewardChestAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RewardTypeAdapter extends TypeAdapter<RewardType> {
  @override
  final int typeId = 9;

  @override
  RewardType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RewardType.coin;
      case 1:
        return RewardType.sticker;
      case 2:
        return RewardType.avatarItem;
      case 3:
        return RewardType.pet;
      case 4:
        return RewardType.background;
      default:
        return RewardType.coin;
    }
  }

  @override
  void write(BinaryWriter writer, RewardType obj) {
    switch (obj) {
      case RewardType.coin:
        writer.writeByte(0);
        break;
      case RewardType.sticker:
        writer.writeByte(1);
        break;
      case RewardType.avatarItem:
        writer.writeByte(2);
        break;
      case RewardType.pet:
        writer.writeByte(3);
        break;
      case RewardType.background:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RewardTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChestTypeAdapter extends TypeAdapter<ChestType> {
  @override
  final int typeId = 11;

  @override
  ChestType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ChestType.bronze;
      case 1:
        return ChestType.silver;
      case 2:
        return ChestType.gold;
      case 3:
        return ChestType.special;
      default:
        return ChestType.bronze;
    }
  }

  @override
  void write(BinaryWriter writer, ChestType obj) {
    switch (obj) {
      case ChestType.bronze:
        writer.writeByte(0);
        break;
      case ChestType.silver:
        writer.writeByte(1);
        break;
      case ChestType.gold:
        writer.writeByte(2);
        break;
      case ChestType.special:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChestTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
