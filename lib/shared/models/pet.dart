import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'pet.g.dart';

@HiveType(typeId: 13)
enum PetType {
  @HiveField(0)
  dragon,
  @HiveField(1)
  unicorn,
  @HiveField(2)
  phoenix,
  @HiveField(3)
  owl,
  @HiveField(4)
  fox,
  @HiveField(5)
  bunny,
  @HiveField(6)
  panda,
  @HiveField(7)
  robot,
}

@HiveType(typeId: 14)
enum PetAnimation {
  @HiveField(0)
  idle,
  @HiveField(1)
  happy,
  @HiveField(2)
  celebrate,
  @HiveField(3)
  sleep,
  @HiveField(4)
  play,
}

@HiveType(typeId: 15)
class Pet extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final PetType type;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final String iconPath;

  @HiveField(5)
  final bool isUnlocked;

  @HiveField(6)
  final DateTime? unlockedAt;

  @HiveField(7)
  final PetAnimation currentAnimation;

  @HiveField(8)
  final int rarity; // 1-5

  const Pet({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.iconPath,
    this.isUnlocked = false,
    this.unlockedAt,
    this.currentAnimation = PetAnimation.idle,
    this.rarity = 1,
  });

  Pet copyWith({
    String? id,
    PetType? type,
    String? name,
    String? description,
    String? iconPath,
    bool? isUnlocked,
    DateTime? unlockedAt,
    PetAnimation? currentAnimation,
    int? rarity,
  }) {
    return Pet(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      iconPath: iconPath ?? this.iconPath,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      currentAnimation: currentAnimation ?? this.currentAnimation,
      rarity: rarity ?? this.rarity,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    name,
    description,
    iconPath,
    isUnlocked,
    unlockedAt,
    currentAnimation,
    rarity,
  ];
}
