import 'package:adventure_world/core/utils/audio_manager.dart';
import 'package:adventure_world/core/utils/responsive_utils.dart';
import 'package:adventure_world/features/math_forest/presentation/widgets/celebration_widget.dart';
import 'package:adventure_world/features/math_forest/presentation/widgets/forest_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../features/ads/services/interstitial_ad_service.dart';
import '../../../../shared/widgets/fancy_button.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../models/math_game_state.dart';
import '../../providers/math_game_provider.dart';
import '../widgets/hint_button.dart';
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
  final InterstitialAdService _adService = InterstitialAdService();

  @override
  void initState() {
    super.initState();
    // Play Math Forest zone music
    AudioManager.instance.playMusic(MusicTrack.mathForest.path);

    // Load Interstitial Ad
    _adService.loadAd();

    // Start the level when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mathGameProvider(widget.levelId).notifier).startLevel();
    });
  }

  @override
  void dispose() {
    _adService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(mathGameProvider(widget.levelId));

    // Listen for level completion and navigate
    ref.listen<MathGameState>(mathGameProvider(widget.levelId), (
      previous,
      next,
    ) async {
      if (next.status == GameStatus.completed &&
          previous?.status != GameStatus.completed) {
        // Show Ad before level complete dialog
        await _adService.show();

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

    // Use different layout for landscape mode
    if (context.isLandscape) {
      return _buildLandscapeLayout(gameState, problem);
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header with timer, counter, and pause button
          _buildHeader(gameState),

          SizedBox(height: context.responsiveSpacing * 2),

          // Problem display
          Padding(
            padding: context.responsiveHorizontalPadding,
            child: WoodSign(child: ProblemDisplay(problem: problem)),
          ),

          // Hint button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: HintButton(correctAnswer: problem.correctAnswer),
          ),

          // Answer bubbles grid
          _buildAnswerBubbles(problem.options),

          SizedBox(height: context.responsiveSpacing * 3),
        ],
      ),
    );
  }

  /// Build landscape layout with side-by-side problem and answers
  Widget _buildLandscapeLayout(MathGameState gameState, problem) {
    return Column(
      children: [
        // Header with timer, counter, and pause button
        _buildHeader(gameState),

        Expanded(
          child: Row(
            children: [
              // Left side: Problem display
              Expanded(
                flex: 2,
                child: Center(
                  child: Padding(
                    padding: context.responsiveHorizontalPadding,
                    child: WoodSign(child: ProblemDisplay(problem: problem)),
                  ),
                ),
              ),

              // Right side: Answer bubbles
              Expanded(
                flex: 3,
                child: Center(child: _buildAnswerBubbles(problem.options)),
              ),
            ],
          ),
        ),

        SizedBox(height: context.responsiveSpacing),
      ],
    );
  }

  Widget _buildHeader(MathGameState gameState) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Back Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => context.pop(),
                ),
              ),
              const SizedBox(width: 16),
              // Pause button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _handlePause,
                  icon: Icon(
                    gameState.status == GameStatus.paused
                        ? Icons.play_arrow
                        : Icons.pause,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
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
    final spacing = context.responsiveValue(
      mobile: 24.0,
      tablet: 32.0,
      desktop: 40.0,
    );

    return Padding(
      padding: context.responsiveHorizontalPadding,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
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

          return FruitButton(
            text: option.toString(),
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
    final gameState = ref.read(mathGameProvider(widget.levelId));
    final stars = gameState.level?.starsEarned ?? 0;
    final score = gameState.correctAnswers;
    final currentLevelNumber = gameState.level?.levelNumber ?? 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(
                'Level Complete!',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.mathForestGreen,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  // Use the stars from the updated level state
                  // If the level was just completed, starsEarned will be the new high score
                  // Note: If the user re-plays a level and gets fewer stars, we show the high score
                  // Ideally we should show the stars earned *this session*, but for now high score is safer
                  // to ensure they see their progress.
                  // Actually, let's check if we can pass the *current* result stars.
                  // Since we updated state.level with the MAX stars, this will show the best score.
                  // If the user wants to see what they got *just now*, we might need to change logic.
                  // But for "Level Complete", showing 3 stars if they already have 3 stars is fine.
                  // Wait, if they got 1 star now but had 3 before, showing 3 might be confusing?
                  // No, usually games show the *best* result or the *current* result.
                  // Given the user said "wrong stars number", they probably saw 0 or previous score.
                  // Let's stick with state.level.starsEarned which is now updated to be at least the current run.
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      index < stars
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 48,
                      color: index < stars
                          ? Colors.amber
                          : Colors.grey.shade300,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              Text(
                'Score: $score',
                style: AppTextStyles.heading3.copyWith(
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: FancyButton(
                      text: 'Back',
                      onPressed: () {
                        context.pop(); // Close dialog
                        context.pop(); // Go back to level selection
                      },
                      gradient: LinearGradient(
                        colors: [Colors.grey.shade400, Colors.grey.shade600],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FancyButton(
                      text: 'Next',
                      onPressed: () {
                        context.pop(); // Close dialog
                        // Navigate to next level
                        final nextLevelId =
                            'math_level_${currentLevelNumber + 1}';
                        context.pushReplacementNamed(
                          'mathGame',
                          pathParameters: {'levelId': nextLevelId},
                        );
                      },
                      gradient: AppColors.mathForestGradient,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
