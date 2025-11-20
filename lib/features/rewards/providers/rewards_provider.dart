import 'package:brain_land/features/rewards/services/reward_generator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/reward.dart';
import 'reward_generator_provider.dart';

/// State for managing player rewards
class RewardsState {
  final List<Reward> earnedRewards;
  final List<RewardChest> pendingChests;
  final bool isLoading;
  final String? error;

  const RewardsState({
    this.earnedRewards = const [],
    this.pendingChests = const [],
    this.isLoading = false,
    this.error,
  });

  RewardsState copyWith({
    List<Reward>? earnedRewards,
    List<RewardChest>? pendingChests,
    bool? isLoading,
    String? error,
  }) {
    return RewardsState(
      earnedRewards: earnedRewards ?? this.earnedRewards,
      pendingChests: pendingChests ?? this.pendingChests,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Provider for managing rewards state
final rewardsProvider = StateNotifierProvider<RewardsNotifier, RewardsState>((
  ref,
) {
  final generator = ref.watch(rewardGeneratorProvider);
  return RewardsNotifier(generator: generator);
});

/// Notifier for managing rewards
class RewardsNotifier extends StateNotifier<RewardsState> {
  final RewardGenerator generator;

  RewardsNotifier({required this.generator}) : super(const RewardsState());

  /// Award a chest based on performance
  void awardChest(ChestType chestType) {
    final chest = generator.generateChest(chestType);
    state = state.copyWith(pendingChests: [...state.pendingChests, chest]);
  }

  /// Award a chest for high accuracy (90%+)
  void awardChestForHighAccuracy(double accuracy) {
    if (accuracy >= 0.90) {
      // Award gold chest for 95%+, silver for 90-94%
      final chestType = accuracy >= 0.95 ? ChestType.gold : ChestType.silver;
      awardChest(chestType);
    }
  }

  /// Open a pending chest and add rewards to earned rewards
  void openChest(String chestId) {
    final chest = state.pendingChests.firstWhere(
      (c) => c.id == chestId,
      orElse: () => throw Exception('Chest not found'),
    );

    // Add rewards to earned rewards
    final newEarnedRewards = [...state.earnedRewards, ...chest.rewards];

    // Remove chest from pending
    final newPendingChests = state.pendingChests
        .where((c) => c.id != chestId)
        .toList();

    state = state.copyWith(
      earnedRewards: newEarnedRewards,
      pendingChests: newPendingChests,
    );
  }

  /// Add a single reward directly
  void addReward(Reward reward) {
    state = state.copyWith(earnedRewards: [...state.earnedRewards, reward]);
  }

  /// Get rewards by type
  List<Reward> getRewardsByType(RewardType type) {
    return state.earnedRewards.where((r) => r.type == type).toList();
  }

  /// Get rewards by rarity
  List<Reward> getRewardsByRarity(int rarity) {
    return state.earnedRewards.where((r) => r.rarity == rarity).toList();
  }

  /// Check if player has a specific reward
  bool hasReward(String rewardId) {
    return state.earnedRewards.any((r) => r.id == rewardId);
  }

  /// Get total count of rewards
  int get totalRewardsCount => state.earnedRewards.length;

  /// Get count of pending chests
  int get pendingChestsCount => state.pendingChests.length;

  /// Clear all rewards (for testing)
  void clearAllRewards() {
    state = const RewardsState();
  }

  /// Load rewards from storage (to be implemented with storage service)
  Future<void> loadRewards(
    List<Reward> rewards,
    List<RewardChest> chests,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      state = state.copyWith(
        earnedRewards: rewards,
        pendingChests: chests,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load rewards: $e',
      );
    }
  }
}
