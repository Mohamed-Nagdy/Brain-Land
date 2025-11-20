import 'package:brain_land/core/utils/audio_manager.dart';
import 'package:brain_land/features/math_forest/presentation/widgets/celebration_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../models/math_game_state.dart';
import '../../providers/math_game_provider.dart';
import '../widgets/answer_bubble.dart';
import '../widgets/problem_display.dart';
import '../widgets/timer_widget.dart';

/// Math Game Screen where players solve math problems
/// Features:
/// - Problem display at the top
/// - 4 answer bubbles in a grid
/// - Timer display
/// - Correct answer counter
/// - Pause button
class MathGameScreen extends ConsumerStatefulWidget {
  final String levelId;

  const MathGameScreen({super.key, required this.levelId});

  @override
  ConsumerState<MathGameScreen> createState() => _MathGameScreenState();
}

class _MathGameScreenState extends ConsumerState<MathGameScreen> {
  int? _selectedAnswer;
  bool? _isCorrect;
  bool _showCelebration = false;

  @override
  void initState() {
    super.initState();
    // Start the level when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mathGameProvider(widget.levelId).notifier).startLevel();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(mathGameProvider(widget.levelId));

    // Listen for level completion and navigate
    ref.listen<MathGameState>(mathGameProvider(widget.levelId), (
      previous,
      next,
    ) {
      if (next.status == GameStatus.completed &&
          previous?.status != GameStatus.completed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _navigateToLevelComplete();
          }
        });
      }
    });

    return Scaffold(
      body: GradientBackground(
        gradient: AppColors.mathForestGradient,
        child: SafeArea(
          child: Stack(
            children: [
              // Main game content
              gameState.status == GameStatus.loading
                  ? _buildLoadingState()
                  : gameState.status == GameStatus.error
                  ? _buildErrorState(gameState.errorMessage ?? 'Unknown error')
                  : gameState.status == GameStatus.playing ||
                        gameState.status == GameStatus.paused
                  ? _buildGameState(gameState)
                  : _buildInitialState(),

              // Celebration overlay
              if (_showCelebration)
                Positioned.fill(child: const CelebrationWidget()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              'Oops!',
              style: AppTextStyles.heading1.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }

  Widget _buildGameState(MathGameState gameState) {
    final problem = gameState.currentProblem;
    if (problem == null) {
      return _buildErrorState('No problem available');
    }

    return Column(
      children: [
        // Header with timer, counter, and pause button
        _buildHeader(gameState),

        const SizedBox(height: 24),

        // Problem display
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ProblemDisplay(problem: problem),
        ),

        const Spacer(),

        // Answer bubbles grid
        _buildAnswerBubbles(problem.options),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildHeader(MathGameState gameState) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Pause button
          IconButton(
            onPressed: _handlePause,
            icon: Icon(
              gameState.status == GameStatus.paused
                  ? Icons.play_arrow
                  : Icons.pause,
              color: Colors.white,
              size: 28,
            ),
          ),

          // Timer
          if (gameState.level != null)
            TimerWidget(
              timeRemaining: gameState.timeRemaining,
              totalTime: gameState.level!.timeLimit,
            ),

          // Correct answer counter
          _buildCorrectCounter(gameState),
        ],
      ),
    );
  }

  Widget _buildCorrectCounter(MathGameState gameState) {
    final target = gameState.level?.targetScore ?? 0;
    final current = gameState.correctAnswers;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            '$current / $target',
            style: AppTextStyles.heading3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerBubbles(List<int> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: 1.0,
        ),
        itemCount: options.length,
        itemBuilder: (context, index) {
          final option = options[index];
          bool? isCorrect;

          // Show feedback if this option was selected
          if (_selectedAnswer == option) {
            isCorrect = _isCorrect;
          }

          return AnswerBubble(
            answer: option.toString(),
            onTap: () => _handleAnswerTap(option),
            isCorrect: isCorrect,
            isEnabled: _selectedAnswer == null,
          );
        },
      ),
    );
  }

  void _handleAnswerTap(int answer) {
    final gameState = ref.read(mathGameProvider(widget.levelId));

    // Only allow answers when playing and no answer is currently selected
    if (gameState.status != GameStatus.playing || _selectedAnswer != null) {
      return;
    }

    final problem = gameState.currentProblem;
    if (problem == null) return;

    // Check if answer is correct
    final isCorrect = problem.checkAnswer(answer);

    // Update UI state to show feedback
    setState(() {
      _selectedAnswer = answer;
      _isCorrect = isCorrect;
    });

    // Play audio feedback
    if (isCorrect) {
      AudioManager.instance.playSound(SoundEffect.correctAnswer.path);
      // Show brief celebration for correct answer
      setState(() {
        _showCelebration = true;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _showCelebration = false;
          });
        }
      });
    } else {
      AudioManager.instance.playSound(SoundEffect.incorrectAnswer.path);
    }

    // Wait for feedback animation, then submit answer
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        // Submit answer to game provider
        ref
            .read(mathGameProvider(widget.levelId).notifier)
            .submitAnswer(answer);

        // Reset selection state for next problem
        setState(() {
          _selectedAnswer = null;
          _isCorrect = null;
        });
      }
    });
  }

  void _handlePause() {
    final notifier = ref.read(mathGameProvider(widget.levelId).notifier);
    final gameState = ref.read(mathGameProvider(widget.levelId));

    if (gameState.status == GameStatus.playing) {
      notifier.pauseGame();
      _showPauseDialog();
    } else if (gameState.status == GameStatus.paused) {
      notifier.resumeGame();
    }
  }

  void _showPauseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Paused'),
        content: const Text('Take a break! Tap Resume when ready.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(mathGameProvider(widget.levelId).notifier).resumeGame();
            },
            child: const Text('Resume'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              context.go('/math-forest'); // Navigate back to level selection
            },
            child: const Text('Quit'),
          ),
        ],
      ),
    );
  }

  void _navigateToLevelComplete() {
    // Navigate to level complete screen
    context.push('/math-forest/complete/${widget.levelId}');
  }
}
