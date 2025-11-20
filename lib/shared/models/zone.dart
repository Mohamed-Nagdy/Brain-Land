import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'zone.g.dart';

@HiveType(typeId: 0)
enum ZoneType {
  @HiveField(0)
  mathForest,
  @HiveField(1)
  logicMountain,
  @HiveField(2)
  memoryRiver,
  @HiveField(3)
  shapeValley,
}

@HiveType(typeId: 1)
class Zone extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String iconPath;

  @HiveField(4)
  final ZoneType type;

  @HiveField(5)
  final bool isUnlocked;

  @HiveField(6)
  final int totalLevels;

  @HiveField(7)
  final int completedLevels;

  @HiveField(8)
  final List<String> availableGames;

  const Zone({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.type,
    required this.isUnlocked,
    required this.totalLevels,
    required this.completedLevels,
    required this.availableGames,
  });

  Zone copyWith({
    String? id,
    String? name,
    String? description,
    String? iconPath,
    ZoneType? type,
    bool? isUnlocked,
    int? totalLevels,
    int? completedLevels,
    List<String>? availableGames,
  }) {
    return Zone(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconPath: iconPath ?? this.iconPath,
      type: type ?? this.type,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      totalLevels: totalLevels ?? this.totalLevels,
      completedLevels: completedLevels ?? this.completedLevels,
      availableGames: availableGames ?? this.availableGames,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    iconPath,
    type,
    isUnlocked,
    totalLevels,
    completedLevels,
    availableGames,
  ];
}
