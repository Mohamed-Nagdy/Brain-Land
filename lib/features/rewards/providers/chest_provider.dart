import 'package:brain_land/features/rewards/services/reward_generator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/reward.dart';
import 'reward_generator_provider.dart';

/// State for chest opening animation and logic
class ChestState {
  final RewardChest? currentChest;
  final bool isOpening;
  final bool isOpened;
  final List<Reward> revealedRewards;
  final String? error;

  const ChestState({
    this.currentChest,
    this.isOpening = false,
    this.isOpened = false,
    this.revealedRewards = const [],
    this.error,
  });

  ChestState copyWith({
    RewardChest? currentChest,
    bool? isOpening,
    bool? isOpened,
    List<Reward>? revealedRewards,
    String? error,
  }) {
    return ChestState(
      currentChest: currentChest ?? this.currentChest,
      isOpening: isOpening ?? this.isOpening,
      isOpened: isOpened ?? this.isOpened,
      revealedRewards: revealedRewards ?? this.revealedRewards,
      error: error ?? this.error,
    );
  }

  ChestState reset() {
    return const ChestState();
  }
}

/// Provider for managing chest opening state
final chestProvider = StateNotifierProvider<ChestNotifier, ChestState>((ref) {
  final generator = ref.watch(rewardGeneratorProvider);
  return ChestNotifier(generator: generator);
});

/// Notifier for managing chest opening logic
class ChestNotifier extends StateNotifier<ChestState> {
  final RewardGenerator generator;

  ChestNotifier({required this.generator}) : super(const ChestState());

  /// Set the current chest to open
  void setChest(RewardChest chest) {
    state = state.copyWith(
      currentChest: chest,
      isOpening: false,
      isOpened: false,
      revealedRewards: [],
    );
  }

  /// Start opening the chest
  void startOpening() {
    if (state.currentChest == null) {
      state = state.copyWith(error: 'No chest to open');
      return;
    }

    state = state.copyWith(isOpening: true, error: null);
  }

  /// Complete the chest opening and reveal rewards
  void completeOpening() {
    if (state.currentChest == null) {
      state = state.copyWith(error: 'No chest to open');
      return;
    }

    state = state.copyWith(
      isOpening: false,
      isOpened: true,
      revealedRewards: state.currentChest!.rewards,
    );
  }

  /// Reveal rewards one by one (for animation)
  void revealNextReward() {
    if (state.currentChest == null || !state.isOpened) return;

    final totalRewards = state.currentChest!.rewards.length;
    final revealedCount = state.revealedRewards.length;

    if (revealedCount < totalRewards) {
      final nextReward = state.currentChest!.rewards[revealedCount];
      state = state.copyWith(
        revealedRewards: [...state.revealedRewards, nextReward],
      );
    }
  }

  /// Check if all rewards have been revealed
  bool get allRewardsRevealed {
    if (state.currentChest == null) return false;
    return state.revealedRewards.length == state.currentChest!.rewards.length;
  }

  /// Reset the chest state
  void reset() {
    state = const ChestState();
  }

  /// Generate and set a new chest
  void generateChest(ChestType chestType) {
    final chest = generator.generateChest(chestType);
    setChest(chest);
  }
}
