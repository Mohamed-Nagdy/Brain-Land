import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/audio_manager.dart';
import '../../../../shared/models/reward.dart';
import '../../../../shared/widgets/fancy_button.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../providers/chest_provider.dart';
import '../../providers/rewards_provider.dart';
import '../widgets/chest_animation.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/reward_card.dart';

/// RewardChestScreen displays chest opening animation and rewards
/// Features:
/// - Animated chest that opens on tap
/// - Confetti overlay for celebration
/// - Reward cards with staggered animations
/// - Collect button to claim rewards
class RewardChestScreen extends ConsumerStatefulWidget {
  final String chestId;

  const RewardChestScreen({super.key, required this.chestId});

  @override
  ConsumerState<RewardChestScreen> createState() => _RewardChestScreenState();
}

class _RewardChestScreenState extends ConsumerState<RewardChestScreen> {
  bool _showConfetti = false;
  bool _showRewards = false;

  @override
  void initState() {
    super.initState();
    _initializeChest();
  }

  void _initializeChest() {
    // Get the chest from rewards provider
    final rewardsState = ref.read(rewardsProvider);
    final chest = rewardsState.pendingChests.firstWhere(
      (c) => c.id == widget.chestId,
      orElse: () => throw Exception('Chest not found'),
    );

    // Set the chest in chest provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chestProvider.notifier).setChest(chest);
    });
  }

  void _handleChestTap() {
    final chestState = ref.read(chestProvider);

    if (!chestState.isOpening && !chestState.isOpened) {
      // Play chest opening sound
      AudioManager.instance.playSound(SoundEffect.chestOpen.path);

      // Start opening animation
      ref.read(chestProvider.notifier).startOpening();
    }
  }

  void _handleOpeningComplete() {
    // Complete the opening
    ref.read(chestProvider.notifier).completeOpening();

    // Play reward unlock sound
    AudioManager.instance.playSound(SoundEffect.rewardUnlock.path);

    // Show confetti
    setState(() {
      _showConfetti = true;
    });

    // Show rewards after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showRewards = true;
        });
      }
    });
  }

  void _handleCollect() {
    final chestState = ref.read(chestProvider);

    if (chestState.currentChest != null) {
      // Add rewards to player's collection
      ref.read(rewardsProvider.notifier).openChest(widget.chestId);

      // Reset chest state
      ref.read(chestProvider.notifier).reset();

      // Navigate back
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final chestState = ref.watch(chestProvider);
    final chest = chestState.currentChest;

    if (chest == null) {
      return Scaffold(
        body: GradientBackground(
          gradient: AppColors.primaryGradient,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      body: GradientBackground(
        gradient: _getChestGradient(chest.type),
        child: SafeArea(
          child: Stack(
            children: [
              // Confetti overlay
              if (_showConfetti)
                const Positioned.fill(child: ConfettiOverlay()),

              // Main content
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title
                      Text(
                        _getChestTitle(chest.type),
                        style: AppTextStyles.heading1.copyWith(
                          color: Colors.white,
                          fontSize: 36,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      // Subtitle
                      if (!chestState.isOpened)
                        Text(
                          'Tap to open!',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),

                      const SizedBox(height: 48),

                      // Chest animation
                      ChestAnimation(
                        chestType: chest.type,
                        isOpening: chestState.isOpening,
                        isOpened: chestState.isOpened,
                        onTap: _handleChestTap,
                        onOpeningComplete: _handleOpeningComplete,
                      ),

                      const SizedBox(height: 48),

                      // Rewards display
                      if (_showRewards && chestState.isOpened) ...[
                        Text(
                          'Your Rewards!',
                          style: AppTextStyles.heading2.copyWith(
                            color: Colors.white,
                            fontSize: 28,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 24),

                        // Reward cards
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          alignment: WrapAlignment.center,
                          children: List.generate(
                            chest.rewards.length,
                            (index) => RewardCard(
                              reward: chest.rewards[index],
                              delay: Duration(milliseconds: 200 * index),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Collect button
                        FancyButton(
                          text: 'Collect Rewards',
                          icon: Icons.check_circle,
                          gradient: AppColors.buttonSuccessGradient,
                          onPressed: _handleCollect,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Close button (top right)
              if (chestState.isOpened)
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: () => context.pop(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Gradient _getChestGradient(ChestType type) {
    switch (type) {
      case ChestType.bronze:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B4513), Color(0xFFCD7F32)],
        );
      case ChestType.silver:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF808080), Color(0xFFC0C0C0)],
        );
      case ChestType.gold:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFDAA520), Color(0xFFFFD700)],
        );
      case ChestType.special:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9B30FF), Color(0xFFFF1493)],
        );
    }
  }

  String _getChestTitle(ChestType type) {
    switch (type) {
      case ChestType.bronze:
        return 'Bronze Chest';
      case ChestType.silver:
        return 'Silver Chest';
      case ChestType.gold:
        return 'Gold Chest';
      case ChestType.special:
        return 'Special Chest';
    }
  }
}
