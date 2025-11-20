import 'package:hive_flutter/hive_flutter.dart';

import '../models/logic_level.dart';

/// Service for managing Logic Mountain level data and progress
/// Service for managing Logic Mountain level data and progress
class LogicStorageService {
  final String _boxName = 'logic_levels';

  /// Get a specific level by ID
  Future<LogicLevel> getLevel(String levelId) async {
    Box<LogicLevel> box;
    try {
      box = await Hive.openBox<LogicLevel>(_boxName);
    } catch (e) {
      await Hive.deleteBoxFromDisk(_boxName);
      box = await Hive.openBox<LogicLevel>(_boxName);
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

  /// Get all levels for Logic Mountain
  Future<List<LogicLevel>> getAllLevels() async {
    Box<LogicLevel> box;
    try {
      box = await Hive.openBox<LogicLevel>(_boxName);
    } catch (e) {
      // If opening fails (e.g. type mismatch or corruption), delete and recreate
      await Hive.deleteBoxFromDisk(_boxName);
      box = await Hive.openBox<LogicLevel>(_boxName);
    }

    List<LogicLevel> levels = [];

    // For the level selection screen, we need to know the status of levels.
    // Iterating 1000 times is fast enough for simple object creation.
    for (int i = 1; i <= 1000; i++) {
      final id = 'logic_level_$i';
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
        // If reading a specific level fails, regenerate it
        levels.add(_createLevel(i));
      }
    }

    return levels;
  }

  /// Save level progress
  Future<void> saveProgress(LogicLevel level) async {
    final box = await Hive.openBox<LogicLevel>(_boxName);
    await box.put(level.id, level);
  }

  /// Create a level with appropriate difficulty progression
  LogicLevel _createLevel(int levelNumber) {
    // Calculate difficulty (1-10 scale) based on 1000 levels
    // Level 1-100: Difficulty 1-3 (Easy)
    // Level 101-500: Difficulty 4-7 (Medium)
    // Level 501-1000: Difficulty 8-10 (Hard)

    int difficulty;
    if (levelNumber <= 100) {
      // Levels 1-100 map to difficulty 1-3
      difficulty = ((levelNumber - 1) ~/ 34) + 1;
    } else if (levelNumber <= 500) {
      // Levels 101-500 map to difficulty 4-7
      difficulty = 4 + ((levelNumber - 101) ~/ 100);
    } else {
      // Levels 501-1000 map to difficulty 8-10
      difficulty = 8 + ((levelNumber - 501) ~/ 167);
    }

    // Calculate time limit (0 for unlimited in early levels)
    // Levels 1-20: Unlimited
    // Levels 21+: Starts at 120s, decreases by 5s every 50 levels, min 30s
    final timeLimit = levelNumber <= 20
        ? 0
        : (120 - ((levelNumber - 20) ~/ 50) * 5).clamp(30, 120);

    // Calculate target score (number of patterns to solve)
    // Increases gradually from 5 to 20
    final targetScore = (5 + (levelNumber ~/ 50)).clamp(5, 20);

    return LogicLevel(
      id: 'logic_level_$levelNumber',
      levelNumber: levelNumber,
      difficulty: difficulty.clamp(1, 10),
      timeLimit: timeLimit,
      targetScore: targetScore,
    );
  }
}
