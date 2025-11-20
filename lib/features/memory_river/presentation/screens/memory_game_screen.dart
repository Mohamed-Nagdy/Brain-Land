import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../models/memory_game_state.dart';
import '../../providers/memory_game_provider.dart';
import '../widgets/memory_card_widget.dart';

/// Memory Game Screen where players match pairs of cards
/// Features:
/// - Grid of memory cards
/// - Card selection and flip logic
/// - Match/mismatch animations
/// - Moves counter
/// - Timer display (if time limit exists)
/// - Completion detection
class MemoryGameScreen extends ConsumerStatefulWidget {
  final String levelId;

  const MemoryGameScreen({super.key, required this.levelId});

  @override
  ConsumerState<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends ConsumerState<MemoryGameScreen> {
  @override
  void initState() {
    super.initState();
    // Start the level when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(memoryGameProvider(widget.levelId).notifier).startLevel();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(memoryGameProvider(widget.levelId));

    // Listen for level completion and navigate
    ref.listen<MemoryGameState>(memoryGameProvider(widget.levelId), (
      previous,
      next,
    ) {
      if (next.status == MemoryGameStatus.completed &&
          previous?.status != MemoryGameStatus.completed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _navigateToLevelComplete();
          }
        });
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          Container(
            decoration: BoxDecoration(gradient: AppColors.memoryRiverGradient),
          ),
          // Floating water droplets animation
          ...List.generate(8, (index) => _buildFloatingDroplet(index)),
          // Game content
          SafeArea(
            child: gameState.status == MemoryGameStatus.loading
                ? _buildLoadingState()
                : gameState.status == MemoryGameStatus.error
                ? _buildErrorState(gameState.errorMessage ?? 'Unknown error')
                : gameState.status == MemoryGameStatus.playing ||
                      gameState.status == MemoryGameStatus.paused
                ? _buildGameState(gameState)
                : _buildInitialState(),
          ),
        ],
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
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }

  Widget _buildGameState(MemoryGameState gameState) {
    if (gameState.level == null) {
      return _buildErrorState('Level not found');
    }

    return Column(
      children: [
        // Header with stats and pause button
        _buildHeader(gameState),

        const SizedBox(height: 16),

        // Memory cards grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildCardsGrid(gameState),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildHeader(MemoryGameState gameState) {
    return Container(
      margin: const EdgeInsets.all(12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.3),
            Colors.white.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button with fun design
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () => _showExitDialog(),
            ),
          ),

          // Stats in playful bubbles
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatBubble(
                  emoji: '✋',
                  label: 'Moves',
                  value: '${gameState.moves}',
                  color: const Color(0xFFFF6B9D),
                ),
                const SizedBox(width: 12),
                _buildStatBubble(
                  emoji: '💝',
                  label: 'Pairs',
                  value:
                      '${gameState.matchedPairs}/${gameState.level!.totalPairs}',
                  color: const Color(0xFFFFA726),
                ),
                if (gameState.level!.timeLimit > 0) ...[
                  const SizedBox(width: 12),
                  _buildStatBubble(
                    emoji: '⏱️',
                    label: 'Time',
                    value: _formatTime(gameState.timeRemaining),
                    color: gameState.timeRemaining <= 10
                        ? const Color(0xFFFF5252)
                        : const Color(0xFF66BB6A),
                    pulse: gameState.timeRemaining <= 10,
                  ),
                ],
              ],
            ),
          ),

          // Pause button with fun design
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                gameState.status == MemoryGameStatus.paused
                    ? Icons.play_arrow_rounded
                    : Icons.pause_rounded,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () => _togglePause(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBubble({
    required String emoji,
    required String label,
    required String value,
    required Color color,
    bool pulse = false,
  }) {
    Widget bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.7)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    if (pulse) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: 1.1),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Transform.scale(scale: value, child: child);
        },
        onEnd: () {
          if (mounted) setState(() {});
        },
        child: bubble,
      );
    }

    return bubble;
  }

  Widget _buildCardsGrid(MemoryGameState gameState) {
    final level = gameState.level!;
    final cards = gameState.cards;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: level.gridColumns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return MemoryCardWidget(
          card: card,
          onTap: () => _handleCardTap(card.id),
          isEnabled:
              gameState.status == MemoryGameStatus.playing &&
              !gameState.hasTwoCardsSelected,
        );
      },
    );
  }

  void _handleCardTap(String cardId) {
    ref.read(memoryGameProvider(widget.levelId).notifier).selectCard(cardId);
  }

  void _togglePause() {
    final notifier = ref.read(memoryGameProvider(widget.levelId).notifier);
    final state = ref.read(memoryGameProvider(widget.levelId));

    if (state.status == MemoryGameStatus.paused) {
      notifier.resumeGame();
    } else {
      notifier.pauseGame();
      _showPauseDialog();
    }
  }

  void _showPauseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('⏸️', style: TextStyle(fontSize: 32)),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Take a Break!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E88E5),
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Rest your brain! Resume when you\'re ready to continue 🧠✨',
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.grey.shade200,
            ),
            onPressed: () {
              context.pop();
              context.pop(); // Exit game screen
            },
            child: const Text(
              'Exit',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: const Color(0xFF66BB6A),
              elevation: 4,
            ),
            onPressed: () {
              context.pop();
              ref
                  .read(memoryGameProvider(widget.levelId).notifier)
                  .resumeGame();
            },
            child: const Text(
              '▶️ Resume',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B9D), Color(0xFFFF5252)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('👋', style: TextStyle(fontSize: 32)),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Leaving?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF5252),
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Your progress will be lost if you leave now. Are you sure? 🤔',
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.grey.shade200,
            ),
            onPressed: () => context.pop(),
            child: const Text(
              'Stay',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: const Color(0xFFFF5252),
              elevation: 4,
            ),
            onPressed: () {
              context.pop();
              context.pop();
            },
            child: const Text(
              'Leave',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToLevelComplete() {
    final gameState = ref.read(memoryGameProvider(widget.levelId));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Text('🎉', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            const Text('Level Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Icon(
                  Icons.star,
                  color: index < (gameState.level?.starsEarned ?? 0)
                      ? Colors.amber
                      : Colors.grey.shade300,
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Moves: ${gameState.moves}', style: AppTextStyles.bodyLarge),
            Text(
              'Time: ${_formatTime(gameState.timeSpent)}',
              style: AppTextStyles.bodyMedium,
            ),
            Text(
              'Pairs: ${gameState.matchedPairs}',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop(); // Close dialog
              context.pop(); // Exit game
            },
            child: const Text('Back'),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop(); // Close dialog
              context.pop(); // Exit game
              // Navigate to next level
              final nextLevelNumber = (gameState.level?.levelNumber ?? 0) + 1;
              context.pushNamed(
                'memoryGame',
                pathParameters: {'levelId': 'memory_$nextLevelNumber'},
              );
            },
            child: const Text('Next Level'),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingDroplet(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(seconds: 3 + index),
      builder: (context, value, child) {
        return Positioned(
          left: (index * 50.0) % MediaQuery.of(context).size.width,
          top: -20 + (value * (MediaQuery.of(context).size.height + 40)),
          child: Opacity(
            opacity: 0.3,
            child: Text(
              '💧',
              style: TextStyle(fontSize: 20 + (index % 3) * 10),
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
