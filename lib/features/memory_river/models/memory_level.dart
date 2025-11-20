import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'memory_level.g.dart';

/// Model representing a Memory River level with grid configuration and scoring
@HiveType(typeId: 18)
class MemoryLevel extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final int levelNumber;
  @HiveField(2)
  final int gridRows; // Number of rows in the grid
  @HiveField(3)
  final int gridColumns; // Number of columns in the grid
  @HiveField(4)
  final int difficulty; // 1-5 difficulty rating
  @HiveField(5)
  final int timeLimit; // 0 for unlimited
  @HiveField(6)
  final bool isCompleted;
  @HiveField(7)
  final int starsEarned;
  @HiveField(8)
  final int bestMoves; // Fewest moves to complete
  @HiveField(9)
  final int bestTime; // Fastest completion time in seconds

  const MemoryLevel({
    required this.id,
    required this.levelNumber,
    required this.gridRows,
    required this.gridColumns,
    required this.difficulty,
    required this.timeLimit,
    this.isCompleted = false,
    this.starsEarned = 0,
    this.bestMoves = 0,
    this.bestTime = 0,
  });

  /// Get the total number of cards in the grid
  int get totalCards => gridRows * gridColumns;

  /// Get the number of pairs in the level
  int get totalPairs => totalCards ~/ 2;

  /// Get the grid size as a string (e.g., "4x4")
  String get gridSize => '${gridRows}x$gridColumns';

  /// Create a copy with modified fields
  MemoryLevel copyWith({
    String? id,
    int? levelNumber,
    int? gridRows,
    int? gridColumns,
    int? difficulty,
    int? timeLimit,
    bool? isCompleted,
    int? starsEarned,
    int? bestMoves,
    int? bestTime,
  }) {
    return MemoryLevel(
      id: id ?? this.id,
      levelNumber: levelNumber ?? this.levelNumber,
      gridRows: gridRows ?? this.gridRows,
      gridColumns: gridColumns ?? this.gridColumns,
      difficulty: difficulty ?? this.difficulty,
      timeLimit: timeLimit ?? this.timeLimit,
      isCompleted: isCompleted ?? this.isCompleted,
      starsEarned: starsEarned ?? this.starsEarned,
      bestMoves: bestMoves ?? this.bestMoves,
      bestTime: bestTime ?? this.bestTime,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'levelNumber': levelNumber,
      'gridRows': gridRows,
      'gridColumns': gridColumns,
      'difficulty': difficulty,
      'timeLimit': timeLimit,
      'isCompleted': isCompleted,
      'starsEarned': starsEarned,
      'bestMoves': bestMoves,
      'bestTime': bestTime,
    };
  }

  /// Create from JSON
  factory MemoryLevel.fromJson(Map<String, dynamic> json) {
    return MemoryLevel(
      id: json['id'] as String,
      levelNumber: json['levelNumber'] as int,
      gridRows: json['gridRows'] as int,
      gridColumns: json['gridColumns'] as int,
      difficulty: json['difficulty'] as int,
      timeLimit: json['timeLimit'] as int,
      isCompleted: json['isCompleted'] as bool? ?? false,
      starsEarned: json['starsEarned'] as int? ?? 0,
      bestMoves: json['bestMoves'] as int? ?? 0,
      bestTime: json['bestTime'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [
    id,
    levelNumber,
    gridRows,
    gridColumns,
    difficulty,
    timeLimit,
    isCompleted,
    starsEarned,
    bestMoves,
    bestTime,
  ];
}
