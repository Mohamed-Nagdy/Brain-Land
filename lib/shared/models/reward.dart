import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'reward.g.dart';

@HiveType(typeId: 9)
enum RewardType {
  @HiveField(0)
  coin,
  @HiveField(1)
  sticker,
  @HiveField(2)
  avatarItem,
  @HiveField(3)
  pet,
  @HiveField(4)
  background,
}

@HiveType(typeId: 10)
class Reward extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final RewardType type;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final String iconPath;

  @HiveField(5)
  final int rarity; // 1-5

  const Reward({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.rarity,
  });

  Reward copyWith({
    String? id,
    RewardType? type,
    String? name,
    String? description,
    String? iconPath,
    int? rarity,
  }) {
    return Reward(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      iconPath: iconPath ?? this.iconPath,
      rarity: rarity ?? this.rarity,
    );
  }

  @override
  List<Object?> get props => [id, type, name, description, iconPath, rarity];
}

@HiveType(typeId: 11)
enum ChestType {
  @HiveField(0)
  bronze,
  @HiveField(1)
  silver,
  @HiveField(2)
  gold,
  @HiveField(3)
  special,
}

@HiveType(typeId: 12)
class RewardChest extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final ChestType type;

  @HiveField(2)
  final List<Reward> rewards;

  @HiveField(3)
  final DateTime earnedAt;

  const RewardChest({
    required this.id,
    required this.type,
    required this.rewards,
    required this.earnedAt,
  });

  RewardChest copyWith({
    String? id,
    ChestType? type,
    List<Reward>? rewards,
    DateTime? earnedAt,
  }) {
    return RewardChest(
      id: id ?? this.id,
      type: type ?? this.type,
      rewards: rewards ?? this.rewards,
      earnedAt: earnedAt ?? this.earnedAt,
    );
  }

  @override
  List<Object?> get props => [id, type, rewards, earnedAt];
}
