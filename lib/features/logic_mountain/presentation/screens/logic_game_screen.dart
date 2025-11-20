import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../shared/widgets/fancy_button.dart';
import '../../models/logic_game_state.dart';
import '../../models/pattern_problem.dart';
import '../../providers/logic_game_provider.dart';
import '../widgets/pattern_option.dart';
import '../widgets/sequence_display.dart';

/// Logic Game Screen where players solve pattern puzzles
class LogicGameScreen extends ConsumerStatefulWidget {
  final String levelId;

  const LogicGameScreen({super.key, required this.levelId});

  @override
  ConsumerState<LogicGameScreen> createState() => _LogicGameScreenState();
}

class _LogicGameScreenState extends ConsumerState<LogicGameScreen>
    with TickerProviderStateMixin {
  PatternElement? _selectedAnswer;
  bool _showHint = false;

  // Animation controllers
  late AnimationController _backgroundController;
  late AnimationController _confettiController;
  final List<_ConfettiParticle> _confetti = [];

  @override
  void initState() {
    super.initState();

    // Background animation
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    // Confetti animation
    _confettiController =
        AnimationController(duration: const Duration(seconds: 2), vsync: this)
          ..addListener(() {
            setState(() {
              for (var particle in _confetti) {
                particle.update();
              }
            });
          });

    // Start the level when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(logicGameProvider(widget.levelId).notifier).startLevel();
    });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _spawnConfetti() {
    _confetti.clear();
    for (int i = 0; i < 50; i++) {
      _confetti.add(_ConfettiParticle());
    }
    _confettiController.forward(from: 0);
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
        _spawnConfetti();
        Future.delayed(const Duration(seconds: 2), () {
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

      // Check for correct answer to spawn mini confetti
      if (next.correctAnswers > (previous?.correctAnswers ?? 0)) {
        _spawnConfetti();
      }
    });

    return Scaffold(
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;

          final shouldPop = await _showExitConfirmationDialog();
          if (shouldPop && context.mounted) {
            context.pop();
          }
        },
        child: Stack(
          children: [
            // Animated Background
            AnimatedBuilder(
              animation: _backgroundController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.lerp(
                          Colors.indigo[300],
                          Colors.purple[300],
                          _backgroundController.value,
                        )!,
                        Color.lerp(
                          Colors.blue[200],
                          Colors.teal[200],
                          _backgroundController.value,
                        )!,
                      ],
                    ),
                  ),
                );
              },
            ),

            // Mountain Decorations
            Positioned(
              bottom: -50,
              left: -50,
              child: Text(
                '🏔️',
                style: TextStyle(
                  fontSize: 200,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              right: -30,
              child: Text(
                '🏔️',
                style: TextStyle(
                  fontSize: 180,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
            ),
            Positioned(top: 50, right: 20, child: _buildFloatingCloud()),
            Positioned(
              top: 100,
              left: 30,
              child: _buildFloatingCloud(delay: 1.5),
            ),

            // Main Content
            SafeArea(
              child: Column(
                children: [
                  // Custom App Bar with Back Button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
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
                            onPressed: () async {
                              final shouldPop =
                                  await _showExitConfirmationDialog();
                              if (shouldPop && context.mounted) {
                                context.pop();
                              }
                            },
                          ),
                        ),
                        const Spacer(),
                        // Level Indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'LEVEL ${gameState.level?.levelNumber ?? 0}',
                            style: AppTextStyles.heading3.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 40), // Balance the back button
                      ],
                    ),
                  ),

                  Expanded(
                    child: gameState.status == LogicGameStatus.loading
                        ? _buildLoadingState()
                        : gameState.status == LogicGameStatus.error
                        ? _buildErrorState(
                            gameState.errorMessage ?? 'Unknown error',
                          )
                        : gameState.status == LogicGameStatus.playing ||
                              gameState.status == LogicGameStatus.paused
                        ? _buildGameState(gameState)
                        : _buildInitialState(),
                  ),
                ],
              ),
            ),

            // Confetti Overlay
            if (_confettiController.isAnimating)
              IgnorePointer(
                child: CustomPaint(
                  painter: _ConfettiPainter(_confetti),
                  size: Size.infinite,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showExitConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Row(
              children: [
                Text('🤔', style: TextStyle(fontSize: 32)),
                SizedBox(width: 12),
                Text('Quit Level?'),
              ],
            ),
            content: const Text(
              'Are you sure you want to give up? Progress will be lost!',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Keep Playing',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Quit', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _buildFloatingCloud({double delay = 0}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(seconds: 20),
      builder: (context, value, child) {
        final offset = sin((value * 2 * pi) + delay) * 20;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: const Text('☁️', style: TextStyle(fontSize: 60)),
        );
      },
      onEnd: () {}, // Loop handled by parent rebuilds or simple oscillation
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
            const Text('😕', style: TextStyle(fontSize: 64)),
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

        const SizedBox(height: 10),

        // Progress Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value:
                  gameState.correctAnswers /
                  (gameState.level?.targetScore ?? 1),
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.yellow),
              minHeight: 12,
            ),
          ),
        ),

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
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                gameState.status == LogicGameStatus.paused
                    ? Icons.play_arrow_rounded
                    : Icons.pause_rounded,
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
          ),

          // Level Info (Removed as it's now in the top bar)
          // Column(
          //   children: [
          //     Text(
          //       'LEVEL ${gameState.level?.levelNumber ?? 0}',
          //       ...
          //     ),
          //     Text(
          //       '${gameState.correctAnswers}/${gameState.level?.targetScore ?? 0}',
          //       ...
          //     ),
          //   ],
          // ),

          // Progress Info
          Column(
            children: [
              Text(
                '${gameState.correctAnswers}/${gameState.level?.targetScore ?? 0}',
                style: AppTextStyles.heading3.copyWith(
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              Text(
                'Solved',
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
              ),
            ],
          ),

          // Timer
          if (gameState.level != null && gameState.level!.timeLimit > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: gameState.isTimeRunningOut
                    ? Colors.red.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Text('⏱️', style: TextStyle(fontSize: 20)),
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.yellow[700]!, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Text('💡', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hint,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.bold,
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
    final gameState = ref.read(logicGameProvider(widget.levelId));
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
                  color: Colors.purple.shade700,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
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
                            'logic_level_${currentLevelNumber + 1}';
                        context.pushReplacementNamed(
                          'logicGame',
                          pathParameters: {'levelId': nextLevelId},
                        );
                      },
                      gradient: AppColors.primaryGradient,
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

// Simple Confetti Particle System
class _ConfettiParticle {
  late double x;
  late double y;
  late double speed;
  late double angle;
  late Color color;
  late double size;
  late double rotation;

  _ConfettiParticle() {
    reset();
  }

  void reset() {
    final random = Random();
    x = random.nextDouble() * 400; // Approx screen width
    y = -20; // Start above screen
    speed = 2 + random.nextDouble() * 5;
    angle = (random.nextDouble() - 0.5) * 0.5; // Slight drift
    color = Colors.primaries[random.nextInt(Colors.primaries.length)];
    size = 5 + random.nextDouble() * 10;
    rotation = random.nextDouble() * 2 * pi;
  }

  void update() {
    y += speed;
    x += sin(y * 0.05) * 2; // Wiggle
    rotation += 0.1;
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;

  _ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()..color = particle.color;

      canvas.save();
      canvas.translate(particle.x, particle.y);
      canvas.rotate(particle.rotation);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => true;
}
