import 'package:hive/hive.dart';

import '../models/memory_level.dart';

/// Service for managing Memory River level data and progress
class MemoryStorageService {
  static const String _memoryLevelsBoxName = 'memory_levels';

  /// Get a specific level by ID
  Future<MemoryLevel> getLevel(String levelId) async {
    Box<MemoryLevel> box;
    try {
      box = await Hive.openBox<MemoryLevel>(_memoryLevelsBoxName);
    } catch (e) {
      await Hive.deleteBoxFromDisk(_memoryLevelsBoxName);
      box = await Hive.openBox<MemoryLevel>(_memoryLevelsBoxName);
    }

    // Try to get from storage first
    try {
      final storedLevel = box.get(levelId);
      if (storedLevel != null) {
        return storedLevel;
      }
    } catch (e) {
      // Ignore read error and regenerate
    }

    // If not in storage, generate it (first time access)
    final levelNumber = int.parse(levelId.split('_').last);
    final newLevel = _createLevel(levelNumber);

    // Save to storage for future use
    await box.put(levelId, newLevel);

    return newLevel;
  }

  /// Get a level by level number
  Future<MemoryLevel> getLevelByNumber(int levelNumber) async {
    return getLevel('memory_$levelNumber');
  }

  /// Get all levels
  Future<List<MemoryLevel>> getAllLevels() async {
    Box<MemoryLevel> box;
    try {
      box = await Hive.openBox<MemoryLevel>(_memoryLevelsBoxName);
    } catch (e) {
      await Hive.deleteBoxFromDisk(_memoryLevelsBoxName);
      box = await Hive.openBox<MemoryLevel>(_memoryLevelsBoxName);
    }

    List<MemoryLevel> levels = [];

    for (int i = 1; i <= 1000; i++) {
      final id = 'memory_$i';
      try {
        if (box.containsKey(id)) {
          final level = box.get(id);
          if (level != null) {
            levels.add(level);
          } else {
            levels.add(_createLevel(i));
          }
        } else {
          levels.add(_createLevel(i));
        }
      } catch (e) {
        levels.add(_createLevel(i));
      }
    }

    // Ensure levels are sorted by levelNumber
    levels.sort((a, b) => a.levelNumber.compareTo(b.levelNumber));

    return levels;
  }

  /// Update level progress after completion
  Future<void> updateLevelProgress({
    required String levelId,
    required int moves,
    required int timeSpent,
    required int starsEarned,
  }) async {
    final level = await getLevel(levelId);

    // Update level with new progress
    final updatedLevel = level.copyWith(
      isCompleted: true,
      starsEarned: starsEarned > level.starsEarned
          ? starsEarned
          : level.starsEarned,
      bestMoves: level.bestMoves == 0 || moves < level.bestMoves
          ? moves
          : level.bestMoves,
      bestTime: level.bestTime == 0 || timeSpent < level.bestTime
          ? timeSpent
          : level.bestTime,
    );

    final box = await Hive.openBox<MemoryLevel>(_memoryLevelsBoxName);
    await box.put(updatedLevel.id, updatedLevel);
  }

  /// Get number of completed levels
  Future<int> getCompletedLevelsCount() async {
    final levels = await getAllLevels();
    return levels.where((level) => level.isCompleted).length;
  }

  /// Create a level with appropriate difficulty progression
  MemoryLevel _createLevel(int levelNumber) {
    // Map 1-1000 to grid sizes and difficulty
    int gridRows, gridColumns, difficulty, timeLimit;

    if (levelNumber <= 100) {
      // Easy levels: 2x2 to 3x4
      difficulty = ((levelNumber - 1) ~/ 34) + 1; // 1-3
      if (levelNumber <= 20) {
        gridRows = 2;
        gridColumns = 2;
        timeLimit = 0; // Unlimited
      } else if (levelNumber <= 50) {
        gridRows = 2;
        gridColumns = 3;
        timeLimit = 0;
      } else {
        gridRows = 3;
        gridColumns = 4;
        timeLimit = 120;
      }
    } else if (levelNumber <= 500) {
      // Medium levels: 3x4 to 4x5
      difficulty = 4 + ((levelNumber - 101) ~/ 100); // 4-7
      if (levelNumber <= 300) {
        gridRows = 3;
        gridColumns = 4;
        timeLimit = 100;
      } else {
        gridRows = 4;
        gridColumns = 5;
        timeLimit = 90;
      }
    } else {
      // Hard levels: 4x5 to 6x6
      difficulty = 8 + ((levelNumber - 501) ~/ 167); // 8-10
      if (levelNumber <= 750) {
        gridRows = 4;
        gridColumns = 5;
        timeLimit = 80;
      } else {
        gridRows = 5;
        gridColumns = 6;
        timeLimit = 100;
      }
    }

    difficulty = difficulty.clamp(1, 10);

    return MemoryLevel(
      id: 'memory_$levelNumber',
      levelNumber: levelNumber,
      gridRows: gridRows,
      gridColumns: gridColumns,
      difficulty: difficulty,
      timeLimit: timeLimit,
    );
  }

  /// Reset all level progress
  Future<void> resetProgress() async {
    await Hive.deleteBoxFromDisk(_memoryLevelsBoxName);
  }
}
