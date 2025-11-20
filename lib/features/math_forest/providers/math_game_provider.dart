import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/difficulty_calculator.dart';
import '../models/level_result.dart';
import '../models/math_game_state.dart';
import '../services/math_storage_service.dart';
import '../services/problem_generator.dart';
import 'math_storage_provider.dart';
import 'problem_generator_provider.dart';

/// Provider for managing the math game state
final mathGameProvider =
    StateNotifierProvider.family<MathGameNotifier, MathGameState, String>((
      ref,
      levelId,
    ) {
      final generator = ref.watch(problemGeneratorProvider);
      final storage = ref.watch(mathStorageServiceProvider);
      final calculator = ref.watch(difficultyCalculatorProvider);

      return MathGameNotifier(
        levelId: levelId,
        generator: generator,
        storage: storage,
        calculator: calculator,
      );
    });

/// Notifier for managing math game state
class MathGameNotifier extends StateNotifier<MathGameState> {
  final String levelId;
  final ProblemGenerator generator;
  final MathStorageService storage;
  final DifficultyCalculator calculator;

  Timer? _timer;

  MathGameNotifier({
    required this.levelId,
    required this.generator,
    required this.storage,
    required this.calculator,
  }) : super(MathGameState.initial());

  /// Start the game level
  Future<void> startLevel() async {
    state = MathGameState.loading();

    try {
      // Load level data
      final level = await storage.getLevel(levelId);
      if (level == null) {
        state = MathGameState.error('Level not found');
        return;
      }

      // Generate problems for the level
      final problemCount = level.targetScore + 5; // Extra problems for variety
      final problems = generator.generateMultiple(
        count: problemCount,
        difficulty: level.difficulty,
      );

      // Initialize game state
      state = MathGameState(
        status: GameStatus.playing,
        level: level,
        problems: problems,
        currentProblemIndex: 0,
        correctAnswers: 0,
        incorrectAnswers: 0,
        timeRemaining: level.timeLimit,
        startTime: DateTime.now(),
      );

      // Start timer if time limit is set
      if (level.timeLimit > 0) {
        _startTimer();
      }
    } catch (e) {
      state = MathGameState.error('Failed to start level: $e');
    }
  }

  /// Submit an answer for the current problem
  void submitAnswer(int answer) {
    if (state.status != GameStatus.playing) return;
    if (state.currentProblem == null) return;

    final isCorrect = state.currentProblem!.checkAnswer(answer);

    if (isCorrect) {
      // Increment correct answers
      state = state.copyWith(correctAnswers: state.correctAnswers + 1);

      // Check if level is complete
      if (state.level != null &&
          state.correctAnswers >= state.level!.targetScore) {
        _completeLevel();
        return;
      }
    } else {
      // Increment incorrect answers
      state = state.copyWith(incorrectAnswers: state.incorrectAnswers + 1);
    }

    // Move to next problem
    _nextProblem();
  }

  /// Move to the next problem
  void _nextProblem() {
    if (state.currentProblemIndex < state.problems.length - 1) {
      state = state.copyWith(
        currentProblemIndex: state.currentProblemIndex + 1,
      );
    } else {
      // No more problems, complete the level
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
    if (state.status == GameStatus.playing) {
      _timer?.cancel();
      state = state.copyWith(status: GameStatus.paused);
    }
  }

  /// Resume the game
  void resumeGame() {
    if (state.status == GameStatus.paused) {
      state = state.copyWith(status: GameStatus.playing);
      if (state.level != null && state.level!.timeLimit > 0) {
        _startTimer();
      }
    }
  }

  /// Complete the level and calculate results
  Future<void> _completeLevel() async {
    _timer?.cancel();

    if (state.level == null || state.startTime == null) return;

    // Calculate time spent
    final timeSpent = DateTime.now().difference(state.startTime!).inSeconds;

    // Calculate stars earned
    final starsEarned = _calculateStars(
      state.accuracy,
      state.level!.difficulty,
    );

    // Create level result
    final result = LevelResult(
      levelId: levelId,
      correctAnswers: state.correctAnswers,
      totalQuestions: state.totalAnswered,
      timeSpent: timeSpent,
      starsEarned: starsEarned,
      accuracy: state.accuracy,
      completedAt: DateTime.now(),
    );

    // Save progress
    await storage.updateLevelProgress(result);

    // Update state to completed
    state = state.copyWith(status: GameStatus.completed);
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
    state = MathGameState.initial();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
