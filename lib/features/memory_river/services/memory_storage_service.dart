import '../models/memory_level.dart';

/// Service for managing Memory River level data and progress
class MemoryStorageService {
  /// Get a specific level by ID
  Future<MemoryLevel?> getLevel(String levelId) async {
    // For now, return predefined levels
    // In a full implementation, this would load from storage
    final levels = _generateLevels();
    return levels.firstWhere(
      (level) => level.id == levelId,
      orElse: () => levels.first,
    );
  }

  /// Get all available levels
  Future<List<MemoryLevel>> getAllLevels() async {
    return _generateLevels();
  }

  /// Update level progress after completion
  Future<void> updateLevelProgress({
    required String levelId,
    required int moves,
    required int timeSpent,
    required int starsEarned,
  }) async {
    // In a full implementation, this would save to Hive storage
    // For now, we'll just log the progress
    print(
      'Level $levelId completed: $moves moves, $timeSpent seconds, $starsEarned stars',
    );
  }

  /// Generate predefined levels
  List<MemoryLevel> _generateLevels() {
    return [
      // Easy levels (2x2 and 2x3)
      const MemoryLevel(
        id: 'memory_1',
        levelNumber: 1,
        gridRows: 2,
        gridColumns: 2,
        difficulty: 1,
        timeLimit: 0, // Unlimited
      ),
      const MemoryLevel(
        id: 'memory_2',
        levelNumber: 2,
        gridRows: 2,
        gridColumns: 3,
        difficulty: 1,
        timeLimit: 0,
      ),
      const MemoryLevel(
        id: 'memory_3',
        levelNumber: 3,
        gridRows: 2,
        gridColumns: 4,
        difficulty: 2,
        timeLimit: 0,
      ),
      // Medium levels (3x4)
      const MemoryLevel(
        id: 'memory_4',
        levelNumber: 4,
        gridRows: 3,
        gridColumns: 4,
        difficulty: 2,
        timeLimit: 120, // 2 minutes
      ),
      const MemoryLevel(
        id: 'memory_5',
        levelNumber: 5,
        gridRows: 3,
        gridColumns: 4,
        difficulty: 3,
        timeLimit: 100,
      ),
      // Hard levels (4x4)
      const MemoryLevel(
        id: 'memory_6',
        levelNumber: 6,
        gridRows: 4,
        gridColumns: 4,
        difficulty: 3,
        timeLimit: 90,
      ),
      const MemoryLevel(
        id: 'memory_7',
        levelNumber: 7,
        gridRows: 4,
        gridColumns: 4,
        difficulty: 4,
        timeLimit: 80,
      ),
      // Expert levels (4x5)
      const MemoryLevel(
        id: 'memory_8',
        levelNumber: 8,
        gridRows: 4,
        gridColumns: 5,
        difficulty: 4,
        timeLimit: 100,
      ),
      const MemoryLevel(
        id: 'memory_9',
        levelNumber: 9,
        gridRows: 4,
        gridColumns: 5,
        difficulty: 5,
        timeLimit: 90,
      ),
      const MemoryLevel(
        id: 'memory_10',
        levelNumber: 10,
        gridRows: 5,
        gridColumns: 6,
        difficulty: 5,
        timeLimit: 120,
      ),
    ];
  }
}
