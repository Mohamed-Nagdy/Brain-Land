import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'zone_progress.g.dart';

@HiveType(typeId: 3)
class ZoneProgress extends Equatable {
  @HiveField(0)
  final String zoneId;

  @HiveField(1)
  final int levelsCompleted;

  @HiveField(2)
  final int totalStars;

  @HiveField(3)
  final int bestAccuracy;

  @HiveField(4)
  final DateTime lastPlayedAt;

  const ZoneProgress({
    required this.zoneId,
    required this.levelsCompleted,
    required this.totalStars,
    required this.bestAccuracy,
    required this.lastPlayedAt,
  });

  ZoneProgress copyWith({
    String? zoneId,
    int? levelsCompleted,
    int? totalStars,
    int? bestAccuracy,
    DateTime? lastPlayedAt,
  }) {
    return ZoneProgress(
      zoneId: zoneId ?? this.zoneId,
      levelsCompleted: levelsCompleted ?? this.levelsCompleted,
      totalStars: totalStars ?? this.totalStars,
      bestAccuracy: bestAccuracy ?? this.bestAccuracy,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }

  @override
  List<Object?> get props => [
    zoneId,
    levelsCompleted,
    totalStars,
    bestAccuracy,
    lastPlayedAt,
  ];
}
