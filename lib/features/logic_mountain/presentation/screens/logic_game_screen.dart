import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../shared/widgets/fancy_button.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../models/logic_game_state.dart';
import '../../models/pattern_problem.dart';
import '../../providers/logic_game_provider.dart';
import '../widgets/pattern_option.dart';
import '../widgets/sequence_display.dart';

/// Logic Game Screen where players solve pattern puzzles
/// Features:
/// - Pattern sequence display at the top
/// - 4 answer options in a grid
/// - Hint button
/// - Correct answer counter
/// - Timer display
/// - Pause button
class LogicGameScreen extends ConsumerStatefulWidget {
  final String levelId;

  const LogicGameScreen({super.key, required this.levelId});

  @override
  ConsumerState<LogicGameScreen> createState() => _LogicGameScreenState();
}

class _LogicGameScreenState extends ConsumerState<LogicGameScreen> {
  PatternElement? _selectedAnswer;
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    // Start the level when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(logicGameProvider(widget.levelId).notifier).startLevel();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(logicGameProvider(widget.levelId));

    // Listen for level completion and navigate
    ref.listen<LogicGameState>(logicGameProvider(widget.levelId), (
      previous,
      next,
    ) {
      if (next.status == LogicGameStatus.completed &&
          previous?.status != LogicGameStatus.completed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _navigateToLevelComplete();
          }
        });
      }

      // Show hint when it becomes available
      if (next.currentHint != null && previous?.currentHint == null) {
        setState(() {
          _showHint = true;
        });
      }

      // Clear hint display when moving to next pattern
      if (next.currentHint == null && previous?.currentHint != null) {
        setState(() {
          _showHint = false;
        });
      }
    });

    return Scaffold(
      body: GradientBackground(
        gradient: AppColors.logicMountainGradient,
        child: SafeArea(
          child: gameState.status == LogicGameStatus.loading
              ? _buildLoadingState()
              : gameState.status == LogicGameStatus.error
              ? _buildErrorState(gameState.errorMessage ?? 'Unknown error')
              : gameState.status == LogicGameStatus.playing ||
                    gameState.status == LogicGameStatus.paused
              ? _buildGameState(gameState)
              : _buildInitialState(),
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
            Icon(Icons.error_outline, size: 64, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              error,
              style: AppTextStyles.heading2.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FancyButton(
              text: 'Go Back',
              onPressed: () => context.pop(),
              gradient: AppColors.primaryGradient,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: FancyButton(
        text: 'Start Level',
        onPressed: () {
          ref.read(logicGameProvider(widget.levelId).notifier).startLevel();
        },
        gradient: AppColors.primaryGradient,
      ),
    );
  }

  Widget _buildGameState(LogicGameState gameState) {
    final currentPattern = gameState.currentPattern;

    if (currentPattern == null) {
      return _buildErrorState('No pattern available');
    }

    return Column(
      children: [
        // Header with stats and controls
        _buildHeader(gameState),

        const SizedBox(height: 24),

        // Pattern sequence display
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SequenceDisplay(
            sequence: currentPattern.sequence,
            highlightIndex: currentPattern.missingIndex,
          ),
        ),

        const SizedBox(height: 24),

        // Hint display
        if (_showHint && gameState.currentHint != null)
          _buildHintDisplay(gameState.currentHint!),

        const Spacer(),

        // Answer options
        _buildAnswerOptions(currentPattern),

        const SizedBox(height: 24),

        // Hint button
        _buildHintButton(gameState),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildHeader(LogicGameState gameState) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Pause button
          IconButton(
            icon: Icon(
              gameState.status == LogicGameStatus.paused
                  ? Icons.play_arrow
                  : Icons.pause,
              color: Colors.white,
              size: 32,
            ),
            onPressed: () {
              if (gameState.status == LogicGameStatus.paused) {
                ref
                    .read(logicGameProvider(widget.levelId).notifier)
                    .resumeGame();
              } else {
                ref
                    .read(logicGameProvider(widget.levelId).notifier)
                    .pauseGame();
              }
            },
          ),

          // Correct answers counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Text(
                  '${gameState.correctAnswers}/${gameState.level?.targetScore ?? 0}',
                  style: AppTextStyles.heading3.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),

          // Timer
          if (gameState.level != null && gameState.level!.timeLimit > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: gameState.isTimeRunningOut
                    ? Colors.red.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.timer, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    '${gameState.timeRemaining}s',
                    style: AppTextStyles.heading3.copyWith(color: Colors.white),
                  ),
                ],
              ),
            )
          else
            const SizedBox(width: 48), // Spacer for alignment
        ],
      ),
    );
  }

  Widget _buildHintDisplay(String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.yellow[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.yellow[700]!, width: 2),
        ),
        child: Row(
          children: [
            Icon(Icons.lightbulb, color: Colors.yellow[700], size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hint,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerOptions(PatternProblem pattern) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.center,
        children: pattern.options.map((option) {
          return PatternOption(
            element: option,
            isSelected: _selectedAnswer == option,
            onTap: () => _handleAnswerSelection(option),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHintButton(LogicGameState gameState) {
    final canShowHint = gameState.canShowHint;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FancyButton(
        text: canShowHint ? 'Show Hint' : 'Hint Shown',
        onPressed: canShowHint
            ? () {
                ref
                    .read(logicGameProvider(widget.levelId).notifier)
                    .requestHint();
              }
            : null,
        gradient: canShowHint
            ? LinearGradient(colors: [Colors.yellow[600]!, Colors.orange[600]!])
            : LinearGradient(colors: [Colors.grey[400]!, Colors.grey[500]!]),
      ),
    );
  }

  void _handleAnswerSelection(PatternElement answer) {
    setState(() {
      _selectedAnswer = answer;
    });

    // Submit answer after a short delay for visual feedback
    Future.delayed(const Duration(milliseconds: 300), () {
      ref.read(logicGameProvider(widget.levelId).notifier).submitAnswer(answer);

      // Clear selection
      setState(() {
        _selectedAnswer = null;
      });
    });
  }

  void _navigateToLevelComplete() {
    // Navigate to level complete screen
    // For now, just pop back
    context.pop();
  }
}
