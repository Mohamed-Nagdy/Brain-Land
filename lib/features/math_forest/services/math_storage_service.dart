import 'dart:convert';
import 'dart:developer';

import 'package:hive/hive.dart';

import '../../../core/utils/difficulty_calculator.dart';
import '../../world_map/services/local/world_map_local_service.dart';
import '../models/level_result.dart';
import '../models/math_level.dart';

/// Service for managing Math Forest level data and progress
class MathStorageService {
  static const String _mathLevelsBoxName = 'math_levels';
  static const String _mathResultsBoxName = 'math_results';

  final DifficultyCalculator _difficultyCalculator;

  MathStorageService({DifficultyCalculator? difficultyCalculator})
    : _difficultyCalculator = difficultyCalculator ?? DifficultyCalculator();

  /// Get a specific level by ID
  Future<MathLevel> getLevel(String levelId) async {
    Box<MathLevel> box;
    try {
      box = await Hive.openBox<MathLevel>(_mathLevelsBoxName);
    } catch (e) {
      await Hive.deleteBoxFromDisk(_mathLevelsBoxName);
      box = await Hive.openBox<MathLevel>(_mathLevelsBoxName);
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
  Future<MathLevel> getLevelByNumber(int levelNumber) async {
    return getLevel('math_level_$levelNumber');
  }

  /// Get all levels
  Future<List<MathLevel>> getAllLevels() async {
    Box<MathLevel> box;
    try {
      box = await Hive.openBox<MathLevel>(_mathLevelsBoxName);
    } catch (e) {
      await Hive.deleteBoxFromDisk(_mathLevelsBoxName);
      box = await Hive.openBox<MathLevel>(_mathLevelsBoxName);
    }

    List<MathLevel> levels = [];

    for (int i = 1; i <= 1000; i++) {
      final id = 'math_level_$i';
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
  Future<void> updateLevelProgress(LevelResult result) async {
    final level = await getLevel(result.levelId);

    // Update level with new progress
    final updatedLevel = level.copyWith(
      isCompleted: true,
      starsEarned: result.starsEarned > level.starsEarned
          ? result.starsEarned
          : level.starsEarned,
      bestScore: result.correctAnswers > level.bestScore
          ? result.correctAnswers
          : level.bestScore,
      bestAccuracy: result.accuracyPercentage > level.bestAccuracy
          ? result.accuracyPercentage
          : level.bestAccuracy,
    );

    final box = await Hive.openBox<MathLevel>(_mathLevelsBoxName);
    await box.put(updatedLevel.id, updatedLevel);

    await _saveResult(result);

    // Update zone progress
    await _updateZoneProgress();
  }

  /// Update zone's completed levels count
  Future<void> _updateZoneProgress() async {
    try {
      // Count completed levels
      final allLevels = await getAllLevels();
      final completedCount = allLevels
          .where((level) => level.isCompleted)
          .length;

      // Update Math Forest zone progress
      final worldMapService = WorldMapLocalService();
      await worldMapService.updateZoneProgress('math_forest', completedCount);
    } catch (e) {
      log('Failed to update zone progress: $e');
    }
  }

  /// Save a level result
  Future<void> _saveResult(LevelResult result) async {
    final box = await Hive.openBox<String>(_mathResultsBoxName);
    final resultKey =
        '${result.levelId}_${result.completedAt.millisecondsSinceEpoch}';
    // We still use JSON for results as they are simple historical records
    // and we haven't created a Hive adapter for LevelResult yet
    final resultJson = jsonEncode(result.toJson());
    await box.put(resultKey, resultJson);
  }

  /// Get all results for a specific level
  Future<List<LevelResult>> getLevelResults(String levelId) async {
    final box = await Hive.openBox<String>(_mathResultsBoxName);
    final results = <LevelResult>[];

    for (final key in box.keys) {
      if (key.toString().startsWith(levelId)) {
        final resultJson = box.get(key);
        if (resultJson != null) {
          final resultMap = jsonDecode(resultJson) as Map<String, dynamic>;
          results.add(LevelResult.fromJson(resultMap));
        }
      }
    }

    // Sort by completion date (most recent first)
    results.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return results;
  }

  /// Get total stars earned across all Math Forest levels
  Future<int> getTotalStars() async {
    final levels = await getAllLevels();
    return levels.fold<int>(0, (sum, level) => sum + level.starsEarned);
  }

  /// Get number of completed levels
  Future<int> getCompletedLevelsCount() async {
    final levels = await getAllLevels();
    return levels.where((level) => level.isCompleted).length;
  }

  /// Create a level with appropriate difficulty progression
  MathLevel _createLevel(int levelNumber) {
    // Use the calculator for consistency, but ensure it scales to 1000
    // The current calculator might be tuned for fewer levels, so we adjust inputs

    // Map 1-1000 to difficulty 1-10
    int difficulty;
    if (levelNumber <= 100) {
      difficulty = ((levelNumber - 1) ~/ 34) + 1; // 1-3
    } else if (levelNumber <= 500) {
      difficulty = 4 + ((levelNumber - 101) ~/ 100); // 4-7
    } else {
      difficulty = 8 + ((levelNumber - 501) ~/ 167); // 8-10
    }
    difficulty = difficulty.clamp(1, 10);

    final timeLimit = _difficultyCalculator.calculateTimeLimit(difficulty);
    final targetScore = _difficultyCalculator.calculateTargetScore(difficulty);

    return MathLevel(
      id: 'math_level_$levelNumber',
      levelNumber: levelNumber,
      difficulty: difficulty,
      timeLimit: timeLimit,
      targetScore: targetScore,
    );
  }

  /// Reset all level progress
  Future<void> resetProgress() async {
    await Hive.deleteBoxFromDisk(_mathLevelsBoxName);
    await Hive.deleteBoxFromDisk(_mathResultsBoxName);
  }
}
