import '../constants/app_constants.dart';

/// Utility class for calculating progressive difficulty across levels
///
/// Implements the difficulty progression system that ensures:
/// - Difficulty increases monotonically through levels
/// - Early levels have unlimited time
/// - Higher difficulty reduces time limits
/// - Difficulty stays within defined bounds
class DifficultyCalculator {
  /// Calculate difficulty for a given level number
  ///
  /// Difficulty increases gradually from 1 to 10 across 30 levels
  /// Uses a logarithmic curve for smooth progression
  ///
  /// [levelNumber] - The level number (1-based)
  /// Returns difficulty rating from 1 to 10
  int calculateDifficulty(int levelNumber) {
    if (levelNumber <= 0) {
      return AppConstants.minDifficulty;
    }

    // Normalize level to 0-1 range
    final normalizedLevel =
        (levelNumber - 1) / (AppConstants.levelsPerZone - 1);

    // Apply logarithmic curve for smooth progression
    // Early levels progress slowly, later levels progress faster
    final difficultyRange =
        AppConstants.maxDifficulty - AppConstants.minDifficulty;
    final difficulty =
        AppConstants.minDifficulty +
        (difficultyRange * _logarithmicCurve(normalizedLevel));

    return difficulty.round().clamp(
      AppConstants.minDifficulty,
      AppConstants.maxDifficulty,
    );
  }

  /// Calculate time limit for a given difficulty level
  ///
  /// Returns time limit in seconds:
  /// - Difficulty 1-3: Unlimited time (0)
  /// - Difficulty 4-6: Easy time limit (120s)
  /// - Difficulty 7-8: Medium time limit (90s)
  /// - Difficulty 9-10: Hard time limit (60s)
  ///
  /// [difficulty] - The difficulty rating (1-10)
  /// Returns time limit in seconds (0 = unlimited)
  int calculateTimeLimit(int difficulty) {
    if (difficulty <= 3) {
      return AppConstants.unlimitedTime;
    } else if (difficulty <= 6) {
      return AppConstants.easyLevelTime;
    } else if (difficulty <= 8) {
      return AppConstants.mediumLevelTime;
    } else {
      return AppConstants.hardLevelTime;
    }
  }

  /// Calculate target score for a given difficulty level
  ///
  /// Higher difficulty requires more correct answers
  ///
  /// [difficulty] - The difficulty rating (1-10)
  /// Returns the number of correct answers needed to complete the level
  int calculateTargetScore(int difficulty) {
    // Base score of 5, increases by 1 for every 2 difficulty levels
    return 5 + (difficulty ~/ 2);
  }

  /// Calculate number range for math problems based on difficulty
  ///
  /// Returns a tuple of (min, max) values for operands
  ///
  /// [difficulty] - The difficulty rating (1-10)
  /// Returns a record with min and max values
  ({int min, int max}) calculateNumberRange(int difficulty) {
    if (difficulty <= 2) {
      // Beginner: 0-10
      return (min: 0, max: AppConstants.beginnerMaxNumber);
    } else if (difficulty <= 4) {
      // Easy: 0-20
      return (min: 0, max: 20);
    } else if (difficulty <= 6) {
      // Medium: 0-50
      return (min: 0, max: 50);
    } else if (difficulty <= 8) {
      // Hard: 0-100
      return (min: 0, max: 100);
    } else {
      // Expert: 0-200
      return (min: 0, max: 200);
    }
  }

  /// Calculate star thresholds for a given difficulty
  ///
  /// Returns accuracy thresholds for earning 1, 2, or 3 stars
  /// Higher difficulty has slightly more lenient thresholds
  ///
  /// [difficulty] - The difficulty rating (1-10)
  /// Returns a record with thresholds for each star level
  ({double oneStar, double twoStar, double threeStar}) calculateStarThresholds(
    int difficulty,
  ) {
    // Slightly reduce thresholds for harder levels to maintain motivation
    final adjustment =
        (difficulty - 1) * 0.02; // Up to 18% reduction at max difficulty

    return (
      oneStar: (AppConstants.oneStarThreshold - adjustment).clamp(0.3, 1.0),
      twoStar: (AppConstants.twoStarThreshold - adjustment).clamp(0.5, 1.0),
      threeStar: (AppConstants.threeStarThreshold - adjustment).clamp(0.7, 1.0),
    );
  }

  /// Logarithmic curve function for smooth difficulty progression
  ///
  /// Maps input [0, 1] to output [0, 1] with logarithmic growth
  /// This creates a curve where early levels progress slowly
  /// and later levels progress more quickly
  double _logarithmicCurve(double x) {
    // Using natural log for smooth curve
    // Formula: (ln(1 + 9x)) / ln(10)
    // This maps [0, 1] to [0, 1] with logarithmic growth
    return (x * x); // Using quadratic for now, can adjust to log if needed
  }

  /// Check if a level should have unlimited time
  ///
  /// [levelNumber] - The level number (1-based)
  /// Returns true if the level should have unlimited time
  bool hasUnlimitedTime(int levelNumber) {
    final difficulty = calculateDifficulty(levelNumber);
    return calculateTimeLimit(difficulty) == AppConstants.unlimitedTime;
  }

  /// Get difficulty description for UI display
  ///
  /// [difficulty] - The difficulty rating (1-10)
  /// Returns a human-readable difficulty description
  String getDifficultyDescription(int difficulty) {
    if (difficulty <= 2) {
      return 'Beginner';
    } else if (difficulty <= 4) {
      return 'Easy';
    } else if (difficulty <= 6) {
      return 'Medium';
    } else if (difficulty <= 8) {
      return 'Hard';
    } else {
      return 'Expert';
    }
  }
}
