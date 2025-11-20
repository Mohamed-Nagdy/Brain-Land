import '../models/logic_level.dart';

/// Service for managing Logic Mountain level data and progress
class LogicStorageService {
  /// Get a specific level by ID
  Future<LogicLevel> getLevel(String levelId) async {
    // For now, return predefined levels
    // In a full implementation, this would load from Hive storage
    final levelNumber = int.parse(levelId.split('_').last);
    return _createLevel(levelNumber);
  }

  /// Get all levels for Logic Mountain
  Future<List<LogicLevel>> getAllLevels() async {
    // Return 10 predefined levels
    return List.generate(10, (index) => _createLevel(index + 1));
  }

  /// Save level progress
  Future<void> saveProgress(LogicLevel level) async {
    // In a full implementation, this would save to Hive storage
    // For now, this is a placeholder
  }

  /// Create a level with appropriate difficulty progression
  LogicLevel _createLevel(int levelNumber) {
    // Calculate difficulty (1-10 scale)
    final difficulty = ((levelNumber - 1) ~/ 3) + 1;

    // Calculate time limit (0 for unlimited in early levels)
    final timeLimit = levelNumber <= 3 ? 0 : 120 - (levelNumber * 5);

    // Calculate target score (number of patterns to solve)
    final targetScore = 5 + (levelNumber ~/ 2);

    return LogicLevel(
      id: 'logic_level_$levelNumber',
      levelNumber: levelNumber,
      difficulty: difficulty.clamp(1, 10),
      timeLimit: timeLimit.clamp(0, 120),
      targetScore: targetScore.clamp(5, 15),
    );
  }
}
