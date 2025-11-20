import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

import 'zone_progress.dart';

part 'player_progress.g.dart';

@HiveType(typeId: 4)
class PlayerProgress extends Equatable {
  @HiveField(0)
  final String playerId;

  @HiveField(1)
  final int totalStars;

  @HiveField(2)
  final int totalCoins;

  @HiveField(3)
  final Map<String, ZoneProgress> zoneProgress;

  @HiveField(4)
  final List<String> unlockedPets;

  @HiveField(5)
  final List<String> unlockedStickers;

  @HiveField(6)
  final List<String> unlockedAvatarItems;

  @HiveField(7)
  final int currentStreak;

  @HiveField(8)
  final DateTime lastLoginDate;

  @HiveField(9)
  final int totalPlayTime; // in seconds

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final DateTime updatedAt;

  const PlayerProgress({
    required this.playerId,
    required this.totalStars,
    required this.totalCoins,
    required this.zoneProgress,
    required this.unlockedPets,
    required this.unlockedStickers,
    required this.unlockedAvatarItems,
    required this.currentStreak,
    required this.lastLoginDate,
    required this.totalPlayTime,
    required this.createdAt,
    required this.updatedAt,
  });

  PlayerProgress copyWith({
    String? playerId,
    int? totalStars,
    int? totalCoins,
    Map<String, ZoneProgress>? zoneProgress,
    List<String>? unlockedPets,
    List<String>? unlockedStickers,
    List<String>? unlockedAvatarItems,
    int? currentStreak,
    DateTime? lastLoginDate,
    int? totalPlayTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlayerProgress(
      playerId: playerId ?? this.playerId,
      totalStars: totalStars ?? this.totalStars,
      totalCoins: totalCoins ?? this.totalCoins,
      zoneProgress: zoneProgress ?? this.zoneProgress,
      unlockedPets: unlockedPets ?? this.unlockedPets,
      unlockedStickers: unlockedStickers ?? this.unlockedStickers,
      unlockedAvatarItems: unlockedAvatarItems ?? this.unlockedAvatarItems,
      currentStreak: currentStreak ?? this.currentStreak,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      totalPlayTime: totalPlayTime ?? this.totalPlayTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    playerId,
    totalStars,
    totalCoins,
    zoneProgress,
    unlockedPets,
    unlockedStickers,
    unlockedAvatarItems,
    currentStreak,
    lastLoginDate,
    totalPlayTime,
    createdAt,
    updatedAt,
  ];
}
