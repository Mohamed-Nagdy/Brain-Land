// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'avatar.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AvatarAdapter extends TypeAdapter<Avatar> {
  @override
  final int typeId = 6;

  @override
  Avatar read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Avatar(
      id: fields[0] as String,
      baseType: fields[1] as AvatarType,
      equippedHat: fields[2] as String?,
      equippedClothing: fields[3] as String?,
      equippedEyes: fields[4] as String?,
      background: fields[5] as String?,
      companionPet: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Avatar obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.baseType)
      ..writeByte(2)
      ..write(obj.equippedHat)
      ..writeByte(3)
      ..write(obj.equippedClothing)
      ..writeByte(4)
      ..write(obj.equippedEyes)
      ..writeByte(5)
      ..write(obj.background)
      ..writeByte(6)
      ..write(obj.companionPet);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvatarAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CustomizationItemAdapter extends TypeAdapter<CustomizationItem> {
  @override
  final int typeId = 8;

  @override
  CustomizationItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomizationItem(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      category: fields[3] as ItemCategory,
      iconPath: fields[4] as String,
      isUnlocked: fields[5] as bool,
      unlockCost: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CustomizationItem obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.iconPath)
      ..writeByte(5)
      ..write(obj.isUnlocked)
      ..writeByte(6)
      ..write(obj.unlockCost);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomizationItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AvatarTypeAdapter extends TypeAdapter<AvatarType> {
  @override
  final int typeId = 5;

  @override
  AvatarType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AvatarType.panda;
      case 1:
        return AvatarType.robot;
      case 2:
        return AvatarType.cat;
      default:
        return AvatarType.panda;
    }
  }

  @override
  void write(BinaryWriter writer, AvatarType obj) {
    switch (obj) {
      case AvatarType.panda:
        writer.writeByte(0);
        break;
      case AvatarType.robot:
        writer.writeByte(1);
        break;
      case AvatarType.cat:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvatarTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ItemCategoryAdapter extends TypeAdapter<ItemCategory> {
  @override
  final int typeId = 7;

  @override
  ItemCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ItemCategory.hat;
      case 1:
        return ItemCategory.clothing;
      case 2:
        return ItemCategory.eyes;
      case 3:
        return ItemCategory.background;
      default:
        return ItemCategory.hat;
    }
  }

  @override
  void write(BinaryWriter writer, ItemCategory obj) {
    switch (obj) {
      case ItemCategory.hat:
        writer.writeByte(0);
        break;
      case ItemCategory.clothing:
        writer.writeByte(1);
        break;
      case ItemCategory.eyes:
        writer.writeByte(2);
        break;
      case ItemCategory.background:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
