/// Core application constants for BrainLand game
class AppConstants {
  // Prevent instantiation
  AppConstants._();

  // Game Configuration
  static const String appName = 'Brain Land';
  static const String appVersion = '1.0.0';

  // Zone Configuration
  static const int totalZones = 4;
  static const int levelsPerZone = 30;

  // Difficulty Settings
  static const int minDifficulty = 1;
  static const int maxDifficulty = 10;
  static const int beginnerMaxNumber = 10;

  // Reward Thresholds
  static const double chestAccuracyThreshold = 0.90;
  static const int consecutiveLevelsForPet = 5;
  static const int streakForSpecialBox = 7;

  // Star Thresholds
  static const double threeStarThreshold = 0.90;
  static const double twoStarThreshold = 0.70;
  static const double oneStarThreshold = 0.50;

  // Time Limits (in seconds, 0 = unlimited)
  static const int unlimitedTime = 0;
  static const int easyLevelTime = 120;
  static const int mediumLevelTime = 90;
  static const int hardLevelTime = 60;

  // Touch Target Sizes (in logical pixels)
  static const double minTouchTargetSize = 48.0;
  static const double buttonHeight = 56.0;
  static const double buttonWidth = 200.0;

  // Animation Durations
  static const int shortAnimationMs = 200;
  static const int mediumAnimationMs = 400;
  static const int longAnimationMs = 800;

  // Storage Keys
  static const String progressBoxName = 'player_progress';
  static const String avatarBoxName = 'avatar_data';
  static const String rewardsBoxName = 'rewards';
  static const String settingsBoxName = 'settings';

  // Property-Based Testing
  static const int pbtIterations = 100;
}
