// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PetAdapter extends TypeAdapter<Pet> {
  @override
  final int typeId = 15;

  @override
  Pet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Pet(
      id: fields[0] as String,
      type: fields[1] as PetType,
      name: fields[2] as String,
      description: fields[3] as String,
      iconPath: fields[4] as String,
      isUnlocked: fields[5] as bool,
      unlockedAt: fields[6] as DateTime?,
      currentAnimation: fields[7] as PetAnimation,
      rarity: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Pet obj) {
    writer
      ..writeByte(9)
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
      ..write(obj.isUnlocked)
      ..writeByte(6)
      ..write(obj.unlockedAt)
      ..writeByte(7)
      ..write(obj.currentAnimation)
      ..writeByte(8)
      ..write(obj.rarity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PetTypeAdapter extends TypeAdapter<PetType> {
  @override
  final int typeId = 13;

  @override
  PetType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PetType.dragon;
      case 1:
        return PetType.unicorn;
      case 2:
        return PetType.phoenix;
      case 3:
        return PetType.owl;
      case 4:
        return PetType.fox;
      case 5:
        return PetType.bunny;
      case 6:
        return PetType.panda;
      case 7:
        return PetType.robot;
      default:
        return PetType.dragon;
    }
  }

  @override
  void write(BinaryWriter writer, PetType obj) {
    switch (obj) {
      case PetType.dragon:
        writer.writeByte(0);
        break;
      case PetType.unicorn:
        writer.writeByte(1);
        break;
      case PetType.phoenix:
        writer.writeByte(2);
        break;
      case PetType.owl:
        writer.writeByte(3);
        break;
      case PetType.fox:
        writer.writeByte(4);
        break;
      case PetType.bunny:
        writer.writeByte(5);
        break;
      case PetType.panda:
        writer.writeByte(6);
        break;
      case PetType.robot:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PetAnimationAdapter extends TypeAdapter<PetAnimation> {
  @override
  final int typeId = 14;

  @override
  PetAnimation read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PetAnimation.idle;
      case 1:
        return PetAnimation.happy;
      case 2:
        return PetAnimation.celebrate;
      case 3:
        return PetAnimation.sleep;
      case 4:
        return PetAnimation.play;
      default:
        return PetAnimation.idle;
    }
  }

  @override
  void write(BinaryWriter writer, PetAnimation obj) {
    switch (obj) {
      case PetAnimation.idle:
        writer.writeByte(0);
        break;
      case PetAnimation.happy:
        writer.writeByte(1);
        break;
      case PetAnimation.celebrate:
        writer.writeByte(2);
        break;
      case PetAnimation.sleep:
        writer.writeByte(3);
        break;
      case PetAnimation.play:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetAnimationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
