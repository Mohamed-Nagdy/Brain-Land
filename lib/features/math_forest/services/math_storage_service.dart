import 'dart:convert';
import 'dart:developer';

import 'package:hive/hive.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/difficulty_calculator.dart';
import '../../world_map/services/local/world_map_local_service.dart';
import '../models/level_result.dart';
import '../models/math_level.dart';

/// Service for managing Math Forest level data and progress
class MathStorageService {
  static const String _mathLevelsBoxName = 'math_levels';
  static const String _mathResultsBoxName = 'math_results';

  final DifficultyCalculator _difficultyCalculator;
  Box<String>? _levelsBox;
  Box<String>? _resultsBox;

  MathStorageService({DifficultyCalculator? difficultyCalculator})
    : _difficultyCalculator = difficultyCalculator ?? DifficultyCalculator();

  /// Initialize the storage service
  Future<void> init() async {
    _levelsBox = await Hive.openBox<String>(_mathLevelsBoxName);
    _resultsBox = await Hive.openBox<String>(_mathResultsBoxName);

    // Initialize default levels if not already created
    if (_levelsBox!.isEmpty) {
      await _initializeDefaultLevels();
    }
  }

  /// Initialize default levels for Math Forest
  Future<void> _initializeDefaultLevels() async {
    for (int i = 1; i <= AppConstants.levelsPerZone; i++) {
      final difficulty = _difficultyCalculator.calculateDifficulty(i);
      final timeLimit = _difficultyCalculator.calculateTimeLimit(difficulty);
      final targetScore = _difficultyCalculator.calculateTargetScore(
        difficulty,
      );

      final level = MathLevel(
        id: 'math_level_$i',
        levelNumber: i,
        difficulty: difficulty,
        timeLimit: timeLimit,
        targetScore: targetScore,
      );

      await _saveLevel(level);
    }
  }

  /// Get a specific level by ID
  Future<MathLevel?> getLevel(String levelId) async {
    if (_levelsBox == null) {
      await init();
    }

    final levelJson = _levelsBox!.get(levelId);
    if (levelJson == null) return null;

    final levelMap = jsonDecode(levelJson) as Map<String, dynamic>;
    return MathLevel.fromJson(levelMap);
  }

  /// Get a level by level number
  Future<MathLevel?> getLevelByNumber(int levelNumber) async {
    return getLevel('math_level_$levelNumber');
  }

  /// Get all levels
  Future<List<MathLevel>> getAllLevels() async {
    if (_levelsBox == null) {
      await init();
    }

    final levels = <MathLevel>[];
    for (final key in _levelsBox!.keys) {
      final levelJson = _levelsBox!.get(key);
      if (levelJson != null) {
        final levelMap = jsonDecode(levelJson) as Map<String, dynamic>;
        levels.add(MathLevel.fromJson(levelMap));
      }
    }

    // Sort by level number
    levels.sort((a, b) => a.levelNumber.compareTo(b.levelNumber));
    return levels;
  }

  /// Save level data
  Future<void> _saveLevel(MathLevel level) async {
    if (_levelsBox == null) {
      await init();
    }

    final levelJson = jsonEncode(level.toJson());
    await _levelsBox!.put(level.id, levelJson);
  }

  /// Update level progress after completion
  Future<void> updateLevelProgress(LevelResult result) async {
    final level = await getLevel(result.levelId);
    if (level == null) return;

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

    await _saveLevel(updatedLevel);
    await _saveResult(result);

    // Update zone progress and check for zone unlocks
    await _updateZoneProgress();
  }

  /// Update zone's completed levels count and check for unlocks
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

      // Note: Zone unlocking removed - all zones are now available

      // Note: The provider will automatically refresh on the next read
      // because we're using Riverpod's auto-refresh mechanism
    } catch (e) {
      // Silent failure - don't break game flow if zone update fails
      log('Failed to update zone progress: $e');
    }
  }

  /// Save a level result
  Future<void> _saveResult(LevelResult result) async {
    if (_resultsBox == null) {
      await init();
    }

    final resultKey =
        '${result.levelId}_${result.completedAt.millisecondsSinceEpoch}';
    final resultJson = jsonEncode(result.toJson());
    await _resultsBox!.put(resultKey, resultJson);
  }

  /// Get all results for a specific level
  Future<List<LevelResult>> getLevelResults(String levelId) async {
    if (_resultsBox == null) {
      await init();
    }

    final results = <LevelResult>[];
    for (final key in _resultsBox!.keys) {
      if (key.toString().startsWith(levelId)) {
        final resultJson = _resultsBox!.get(key);
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

  /// Reset all level progress (for testing or reset functionality)
  Future<void> resetProgress() async {
    if (_levelsBox == null || _resultsBox == null) {
      await init();
    }

    await _levelsBox!.clear();
    await _resultsBox!.clear();
    await _initializeDefaultLevels();
  }

  /// Close the storage boxes
  Future<void> close() async {
    await _levelsBox?.close();
    await _resultsBox?.close();
  }
}
