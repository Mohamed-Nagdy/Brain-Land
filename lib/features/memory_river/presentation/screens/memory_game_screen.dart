import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/audio_manager.dart';
import '../../../../features/ads/services/interstitial_ad_service.dart';
import '../../../../shared/widgets/fancy_button.dart';
import '../../models/memory_card.dart';
import '../../models/memory_game_state.dart';
import '../../providers/memory_game_provider.dart';
import '../widgets/memory_card_widget.dart';

class MemoryGameScreen extends ConsumerStatefulWidget {
  final String levelId;

  const MemoryGameScreen({super.key, required this.levelId});

  @override
  ConsumerState<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends ConsumerState<MemoryGameScreen>
    with TickerProviderStateMixin {
  late AnimationController _bubbleController;
  Timer? _timer;
  final InterstitialAdService _interstitialAdService = InterstitialAdService();

  @override
  void initState() {
    super.initState();
    // Start bubble animation
    _bubbleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    // Load Ads
    _interstitialAdService.loadAd();

    // Start the level when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(memoryGameProvider(widget.levelId).notifier).startLevel();
      _startTimer();
    });
  }

  @override
  void dispose() {
    _bubbleController.dispose();
    _timer?.cancel();
    _interstitialAdService.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final gameState = ref.read(memoryGameProvider(widget.levelId));
      if (gameState.status == MemoryGameStatus.playing) {
        // Just trigger rebuild to update timeSpent
        setState(() {});
      }
    });
  }

  Future<void> _handleCardTap(MemoryCard card) async {
    final notifier = ref.read(memoryGameProvider(widget.levelId).notifier);
    notifier.selectCard(card.id);
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(memoryGameProvider(widget.levelId));

    // Listen for game completion
    ref.listen<MemoryGameState>(memoryGameProvider(widget.levelId), (
      previous,
      next,
    ) async {
      if (next.status == MemoryGameStatus.completed &&
          previous?.status != MemoryGameStatus.completed) {
        _timer?.cancel();
        AudioManager.instance.playSound('level_complete.mp3');

        // Show Ad before level complete dialog
        await _interstitialAdService.show();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showLevelCompleteDialog(next);
          }
        });
      }
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade300, Colors.blue.shade800],
          ),
        ),
        child: Stack(
          children: [
            // Rising Bubbles Animation
            _buildBubbles(),

            // Game content
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(gameState),
                  Expanded(
                    child: gameState.status == MemoryGameStatus.loading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : gameState.status == MemoryGameStatus.error
                        ? _buildErrorState(
                            gameState.errorMessage ?? 'Unknown error',
                          )
                        : gameState.status == MemoryGameStatus.playing ||
                              gameState.status == MemoryGameStatus.paused ||
                              gameState.status == MemoryGameStatus.completed
                        ? _buildGrid(gameState)
                        : _buildInitialState(),
                  ),
                  _buildFooter(gameState),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBubbles() {
    return AnimatedBuilder(
      animation: _bubbleController,
      builder: (context, child) {
        return Stack(
          children: List.generate(10, (index) {
            final random = math.Random(index);
            final size = random.nextDouble() * 30 + 10;
            final speed = random.nextDouble() * 0.5 + 0.5;
            final initialX =
                random.nextDouble() * MediaQuery.of(context).size.width;
            final y =
                MediaQuery.of(context).size.height *
                (1 - ((_bubbleController.value * speed + index * 0.1) % 1));

            return Positioned(
              left: initialX,
              top: y,
              child: Opacity(
                opacity: 0.3,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.2),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildInitialState() {
    return const SizedBox.shrink();
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.errorRed,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops!',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(MemoryGameState gameState) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  _formatTime(gameState.timeSpent),
                  style: AppTextStyles.heading3.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.yellow),
                const SizedBox(width: 8),
                Text(
                  '${gameState.matchedPairs}',
                  style: AppTextStyles.heading3.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(MemoryGameState gameState) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getCrossAxisCount(gameState.cards.length);
        final aspectRatio = _getAspectRatio(crossAxisCount, constraints);

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: aspectRatio,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: gameState.cards.length,
          itemBuilder: (context, index) {
            final card = gameState.cards[index];
            return MemoryCardWidget(
              card: card,
              onTap: () => _handleCardTap(card),
              isPeeking: false,
            );
          },
        );
      },
    );
  }

  Widget _buildFooter(MemoryGameState gameState) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FancyButton(
            text: 'Restart',
            onPressed: () {
              ref
                  .read(memoryGameProvider(widget.levelId).notifier)
                  .startLevel();
              _startTimer();
            },
            icon: Icons.refresh,
            gradient: LinearGradient(
              colors: [Colors.orange.shade400, Colors.orange.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ],
      ),
    );
  }

  int _getCrossAxisCount(int itemCount) {
    if (itemCount <= 6) return 2;
    if (itemCount <= 12) return 3;
    return 4;
  }

  double _getAspectRatio(int crossAxisCount, BoxConstraints constraints) {
    // Calculate roughly to keep cards somewhat square or standard card ratio
    return 0.75; // 3:4 ratio
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showLevelCompleteDialog(MemoryGameState state) {
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
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 80)),
              const SizedBox(height: 16),
              Text(
                'Level Complete!',
                textAlign: TextAlign.center,
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.memoryRiverPurple,
                ),
              ),
              const SizedBox(height: 24),

              // Stats Container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text('Pairs', style: AppTextStyles.bodySmall),
                        const SizedBox(height: 4),
                        Text(
                          '${state.matchedPairs}',
                          style: AppTextStyles.heading3.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey.shade300,
                    ),
                    Column(
                      children: [
                        Text('Time', style: AppTextStyles.bodySmall),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(state.timeSpent),
                          style: AppTextStyles.heading3.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  final stars = state.level?.starsEarned ?? 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      index < stars ? Icons.star : Icons.star_border,
                      color: AppColors.starGold,
                      size: 48,
                    ),
                  );
                }),
              ),

              SizedBox(height: 32),

              // Action Buttons
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FancyButton(
                    text: 'Next Level',
                    onPressed: () {
                      context.pop(); // Close dialog
                      context.pop(); // Go back to level selection
                      // Ideally navigate to next level directly, but for now back to map is safe
                    },
                    icon: Icons.arrow_forward_rounded,
                    gradient: AppColors.memoryRiverGradient,
                  ),
                  const SizedBox(height: 12),
                  FancyButton(
                    text: 'Play Again',
                    onPressed: () {
                      context.pop(); // Close dialog
                      ref
                          .read(memoryGameProvider(widget.levelId).notifier)
                          .startLevel();
                      _startTimer();
                    },
                    icon: Icons.refresh,
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade400, Colors.orange.shade700],
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
