import 'dart:async';

import 'package:adventure_world/features/progress/providers/progress_provider.dart';
import 'package:adventure_world/features/world_map/providers/world_map_provider.dart';
import 'package:adventure_world/shared/models/zone_progress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/utils/difficulty_calculator.dart';
import '../../math_forest/providers/problem_generator_provider.dart';
import '../models/logic_game_state.dart';
import '../models/logic_level.dart';
import '../models/pattern_problem.dart';
import '../services/logic_storage_service.dart';
import '../services/pattern_generator.dart';
import 'logic_storage_provider.dart';
import 'pattern_generator_provider.dart';

/// Provider for managing the logic game state
final logicGameProvider =
    StateNotifierProvider.family<LogicGameNotifier, LogicGameState, String>((
      ref,
      levelId,
    ) {
      final generator = ref.watch(patternGeneratorProvider);
      final storage = ref.watch(logicStorageServiceProvider);
      final calculator = ref.watch(difficultyCalculatorProvider);

      return LogicGameNotifier(
        levelId: levelId,
        generator: generator,
        storage: storage,
        calculator: calculator,
        ref: ref,
      );
    });

/// Provider for fetching all logic levels
final logicLevelsProvider = FutureProvider<List<LogicLevel>>((ref) async {
  final storage = ref.watch(logicStorageServiceProvider);
  return storage.getAllLevels();
});

/// Notifier for managing logic game state
class LogicGameNotifier extends StateNotifier<LogicGameState> {
  final String levelId;
  final PatternGenerator generator;
  final LogicStorageService storage;
  final DifficultyCalculator calculator;
  final Ref ref;

  Timer? _timer;

  LogicGameNotifier({
    required this.levelId,
    required this.generator,
    required this.storage,
    required this.calculator,
    required this.ref,
  }) : super(LogicGameState.initial());

  /// Start the game level
  Future<void> startLevel() async {
    state = LogicGameState.loading();

    try {
      // Load level data
      final level = await storage.getLevel(levelId);

      // Generate patterns for the level
      final patternCount = level.targetScore + 3; // Extra patterns for variety
      final patterns = generator.generateMultiple(
        count: patternCount,
        difficulty: level.difficulty,
      );

      // Initialize game state
      state = LogicGameState(
        status: LogicGameStatus.playing,
        level: level,
        patterns: patterns,
        currentPatternIndex: 0,
        correctAnswers: 0,
        incorrectAnswers: 0,
        hintsUsed: 0,
        timeRemaining: level.timeLimit,
        startTime: DateTime.now(),
      );

      // Start timer if time limit is set
      if (level.timeLimit > 0) {
        _startTimer();
      }
    } catch (e) {
      state = LogicGameState.error('Failed to start level: $e');
    }
  }

  /// Submit an answer for the current pattern
  void submitAnswer(PatternElement answer) {
    if (state.status != LogicGameStatus.playing) return;
    if (state.currentPattern == null) return;

    final isCorrect = state.currentPattern!.checkAnswer(answer);

    if (isCorrect) {
      // Increment correct answers
      state = state.copyWith(
        correctAnswers: state.correctAnswers + 1,
        clearHint: true, // Clear hint on correct answer
      );

      // Check if level is complete
      if (state.level != null &&
          state.correctAnswers >= state.level!.targetScore) {
        _completeLevel();
        return;
      }

      // Move to next pattern
      _nextPattern();
    } else {
      // Incorrect answer - show hint without penalty (as per requirements)
      _showHint();
    }
  }

  /// Show hint for the current pattern
  void _showHint() {
    if (state.currentPattern == null) return;
    if (state.currentHint != null) return; // Hint already shown

    final hint = state.currentPattern!.getHint();
    state = state.copyWith(hintsUsed: state.hintsUsed + 1, currentHint: hint);
  }

  /// Request hint manually (button press)
  void requestHint() {
    _showHint();
  }

  /// Move to the next pattern
  void _nextPattern() {
    if (state.currentPatternIndex < state.patterns.length - 1) {
      state = state.copyWith(
        currentPatternIndex: state.currentPatternIndex + 1,
        clearHint: true, // Clear hint for new pattern
      );
    } else {
      // No more patterns, complete the level
      _completeLevel();
    }
  }

  /// Start the countdown timer
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeRemaining > 0) {
        state = state.copyWith(timeRemaining: state.timeRemaining - 1);
      } else {
        // Time expired
        timer.cancel();
        _completeLevel();
      }
    });
  }

  /// Pause the game
  void pauseGame() {
    if (state.status == LogicGameStatus.playing) {
      _timer?.cancel();
      state = state.copyWith(status: LogicGameStatus.paused);
    }
  }

  /// Resume the game
  void resumeGame() {
    if (state.status == LogicGameStatus.paused) {
      state = state.copyWith(status: LogicGameStatus.playing);
      if (state.level != null && state.level!.timeLimit > 0) {
        _startTimer();
      }
    }
  }

  /// Complete the level and calculate results
  Future<void> _completeLevel() async {
    _timer?.cancel();

    if (state.level == null || state.startTime == null) return;

    // Calculate stars earned
    final starsEarned = _calculateStars(
      state.accuracy,
      state.level!.difficulty,
    );

    // Create updated level with results
    final updatedLevel = state.level!.copyWith(
      isCompleted: true,
      starsEarned: starsEarned,
      bestScore: state.correctAnswers,
      bestAccuracy: (state.accuracy * 100).round(),
      hintsUsed: state.hintsUsed,
    );

    // Save progress
    await storage.saveProgress(updatedLevel);

    // Sync with global progress provider
    // This is critical because level selection relies on this provider to unlock levels
    final completedCount = await storage.getCompletedLevelsCount();
    final currentProgress = await ref.read(progressProvider.future);
    final currentZoneProgress =
        currentProgress.zoneProgress['logic_mountain'] ??
        ZoneProgress(
          zoneId: 'logic_mountain',
          levelsCompleted: 0,
          totalStars: 0,
          bestAccuracy: 0,
          lastPlayedAt: DateTime.now(),
        );

    final updatedZoneProgress = currentZoneProgress.copyWith(
      levelsCompleted: completedCount,
      lastPlayedAt: DateTime.now(),
    );

    await ref
        .read(progressProvider.notifier)
        .updateZoneProgress('logic_mountain', updatedZoneProgress);

    // Invalidate providers to ensure UI updates
    ref.invalidate(logicLevelsProvider);
    ref.invalidate(worldMapProvider); // Refresh world map display

    // Handle consecutive level completion for pet unlocking
    if (starsEarned > 0) {
      // Level was completed successfully
      await ref.read(progressProvider.notifier).incrementConsecutiveLevels();
    } else {
      // Level was failed, reset consecutive counter
      await ref.read(progressProvider.notifier).resetConsecutiveLevels();
    }

    // Update state to completed with the updated level
    state = state.copyWith(
      status: LogicGameStatus.completed,
      level: updatedLevel,
    );
  }

  /// Calculate stars earned based on accuracy and difficulty
  int _calculateStars(double accuracy, int difficulty) {
    final thresholds = calculator.calculateStarThresholds(difficulty);

    if (accuracy >= thresholds.threeStar) {
      return 3;
    } else if (accuracy >= thresholds.twoStar) {
      return 2;
    } else if (accuracy >= thresholds.oneStar) {
      return 1;
    } else {
      return 0;
    }
  }

  /// Reset the game
  void resetGame() {
    _timer?.cancel();
    state = LogicGameState.initial();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
