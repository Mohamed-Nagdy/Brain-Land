import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'avatar.g.dart';

@HiveType(typeId: 5)
enum AvatarType {
  @HiveField(0)
  panda,
  @HiveField(1)
  robot,
  @HiveField(2)
  cat,
}

@HiveType(typeId: 6)
class Avatar extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final AvatarType baseType;

  @HiveField(2)
  final String? equippedHat;

  @HiveField(3)
  final String? equippedClothing;

  @HiveField(4)
  final String? equippedEyes;

  @HiveField(5)
  final String? background;

  @HiveField(6)
  final String? companionPet;

  const Avatar({
    required this.id,
    required this.baseType,
    this.equippedHat,
    this.equippedClothing,
    this.equippedEyes,
    this.background,
    this.companionPet,
  });

  Avatar copyWith({
    String? id,
    AvatarType? baseType,
    String? equippedHat,
    String? equippedClothing,
    String? equippedEyes,
    String? background,
    String? companionPet,
  }) {
    return Avatar(
      id: id ?? this.id,
      baseType: baseType ?? this.baseType,
      equippedHat: equippedHat ?? this.equippedHat,
      equippedClothing: equippedClothing ?? this.equippedClothing,
      equippedEyes: equippedEyes ?? this.equippedEyes,
      background: background ?? this.background,
      companionPet: companionPet ?? this.companionPet,
    );
  }

  @override
  List<Object?> get props => [
    id,
    baseType,
    equippedHat,
    equippedClothing,
    equippedEyes,
    background,
    companionPet,
  ];
}

@HiveType(typeId: 7)
enum ItemCategory {
  @HiveField(0)
  hat,
  @HiveField(1)
  clothing,
  @HiveField(2)
  eyes,
  @HiveField(3)
  background,
}

@HiveType(typeId: 8)
class CustomizationItem extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final ItemCategory category;

  @HiveField(4)
  final String iconPath;

  @HiveField(5)
  final bool isUnlocked;

  @HiveField(6)
  final int unlockCost;

  const CustomizationItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.iconPath,
    required this.isUnlocked,
    required this.unlockCost,
  });

  CustomizationItem copyWith({
    String? id,
    String? name,
    String? description,
    ItemCategory? category,
    String? iconPath,
    bool? isUnlocked,
    int? unlockCost,
  }) {
    return CustomizationItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      iconPath: iconPath ?? this.iconPath,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockCost: unlockCost ?? this.unlockCost,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    category,
    iconPath,
    isUnlocked,
    unlockCost,
  ];
}
