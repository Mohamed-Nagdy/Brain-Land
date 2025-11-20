import 'dart:math';

import 'package:brain_land/shared/models/reward.dart';

/// Service for generating random rewards based on rarity and chest type
class RewardGenerator {
  final Random _random;

  RewardGenerator({Random? random}) : _random = random ?? Random();

  /// Available rewards pool organized by type and rarity
  static const Map<RewardType, List<RewardData>> _rewardPool = {
    RewardType.coin: [
      RewardData(
        'coin_small',
        'Small Coin Bag',
        '10 coins',
        'assets/icons/coin_small.png',
        1,
      ),
      RewardData(
        'coin_medium',
        'Medium Coin Bag',
        '25 coins',
        'assets/icons/coin_medium.png',
        2,
      ),
      RewardData(
        'coin_large',
        'Large Coin Bag',
        '50 coins',
        'assets/icons/coin_large.png',
        3,
      ),
      RewardData(
        'coin_huge',
        'Huge Coin Bag',
        '100 coins',
        'assets/icons/coin_huge.png',
        4,
      ),
      RewardData(
        'coin_mega',
        'Mega Coin Bag',
        '250 coins',
        'assets/icons/coin_mega.png',
        5,
      ),
    ],
    RewardType.sticker: [
      RewardData(
        'sticker_star',
        'Star Sticker',
        'A shiny star',
        'assets/stickers/star.png',
        1,
      ),
      RewardData(
        'sticker_heart',
        'Heart Sticker',
        'A lovely heart',
        'assets/stickers/heart.png',
        1,
      ),
      RewardData(
        'sticker_rainbow',
        'Rainbow Sticker',
        'A colorful rainbow',
        'assets/stickers/rainbow.png',
        2,
      ),
      RewardData(
        'sticker_unicorn',
        'Unicorn Sticker',
        'A magical unicorn',
        'assets/stickers/unicorn.png',
        3,
      ),
      RewardData(
        'sticker_dragon',
        'Dragon Sticker',
        'A fierce dragon',
        'assets/stickers/dragon.png',
        4,
      ),
      RewardData(
        'sticker_galaxy',
        'Galaxy Sticker',
        'A cosmic galaxy',
        'assets/stickers/galaxy.png',
        5,
      ),
    ],
    RewardType.avatarItem: [
      RewardData(
        'hat_cap',
        'Baseball Cap',
        'A cool cap',
        'assets/avatar/hats/cap.png',
        1,
      ),
      RewardData(
        'hat_wizard',
        'Wizard Hat',
        'A magical hat',
        'assets/avatar/hats/wizard.png',
        3,
      ),
      RewardData(
        'hat_crown',
        'Golden Crown',
        'A royal crown',
        'assets/avatar/hats/crown.png',
        5,
      ),
      RewardData(
        'clothes_tshirt',
        'Cool T-Shirt',
        'A comfy shirt',
        'assets/avatar/clothes/tshirt.png',
        1,
      ),
      RewardData(
        'clothes_superhero',
        'Superhero Suit',
        'A hero outfit',
        'assets/avatar/clothes/superhero.png',
        4,
      ),
      RewardData(
        'eyes_sparkle',
        'Sparkle Eyes',
        'Shiny eyes',
        'assets/avatar/eyes/sparkle.png',
        2,
      ),
    ],
    RewardType.pet: [
      RewardData(
        'pet_bunny',
        'Fluffy Bunny',
        'A cute bunny',
        'assets/pets/bunny.png',
        3,
      ),
      RewardData(
        'pet_dragon',
        'Baby Dragon',
        'A tiny dragon',
        'assets/pets/dragon.png',
        4,
      ),
      RewardData(
        'pet_phoenix',
        'Phoenix',
        'A legendary bird',
        'assets/pets/phoenix.png',
        5,
      ),
    ],
    RewardType.background: [
      RewardData(
        'bg_forest',
        'Forest Background',
        'A peaceful forest',
        'assets/backgrounds/forest.png',
        2,
      ),
      RewardData(
        'bg_space',
        'Space Background',
        'The cosmos',
        'assets/backgrounds/space.png',
        3,
      ),
      RewardData(
        'bg_castle',
        'Castle Background',
        'A grand castle',
        'assets/backgrounds/castle.png',
        4,
      ),
    ],
  };

  /// Rarity weights for different chest types
  static const Map<ChestType, Map<int, double>> _rarityWeights = {
    ChestType.bronze: {
      1: 0.60, // 60% common
      2: 0.30, // 30% uncommon
      3: 0.10, // 10% rare
      4: 0.00, // 0% epic
      5: 0.00, // 0% legendary
    },
    ChestType.silver: {
      1: 0.40, // 40% common
      2: 0.35, // 35% uncommon
      3: 0.20, // 20% rare
      4: 0.05, // 5% epic
      5: 0.00, // 0% legendary
    },
    ChestType.gold: {
      1: 0.20, // 20% common
      2: 0.30, // 30% uncommon
      3: 0.30, // 30% rare
      4: 0.15, // 15% epic
      5: 0.05, // 5% legendary
    },
    ChestType.special: {
      1: 0.00, // 0% common
      2: 0.20, // 20% uncommon
      3: 0.30, // 30% rare
      4: 0.30, // 30% epic
      5: 0.20, // 20% legendary
    },
  };

  /// Generate a reward chest with random rewards based on chest type
  RewardChest generateChest(ChestType chestType) {
    final rewardCount = _getRewardCount(chestType);
    final rewards = <Reward>[];

    for (int i = 0; i < rewardCount; i++) {
      final reward = _generateSingleReward(chestType);
      rewards.add(reward);
    }

    return RewardChest(
      id: 'chest_${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(999999)}',
      type: chestType,
      rewards: rewards,
      earnedAt: DateTime.now(),
    );
  }

  /// Generate a single random reward based on chest type
  Reward _generateSingleReward(ChestType chestType) {
    // Select rarity based on chest type weights
    final rarity = _selectRarity(chestType);

    // Select reward type randomly
    final rewardType = _selectRewardType();

    // Get available rewards for this type and rarity
    final availableRewards = _rewardPool[rewardType]!
        .where((r) => r.rarity == rarity)
        .toList();

    // If no rewards match the rarity, get closest rarity
    final rewardData = availableRewards.isNotEmpty
        ? availableRewards[_random.nextInt(availableRewards.length)]
        : _getClosestRarityReward(rewardType, rarity);

    return Reward(
      id: '${rewardData.id}_${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(999999)}',
      type: rewardType,
      name: rewardData.name,
      description: rewardData.description,
      iconPath: rewardData.iconPath,
      rarity: rewardData.rarity,
    );
  }

  /// Select rarity based on chest type probability weights
  int _selectRarity(ChestType chestType) {
    final weights = _rarityWeights[chestType]!;
    final roll = _random.nextDouble();
    double cumulative = 0.0;

    for (final entry in weights.entries) {
      cumulative += entry.value;
      if (roll <= cumulative) {
        return entry.key;
      }
    }

    // Fallback to rarity 1 if something goes wrong
    return 1;
  }

  /// Select reward type randomly (equal probability for all types)
  RewardType _selectRewardType() {
    final types = RewardType.values;
    return types[_random.nextInt(types.length)];
  }

  /// Get the closest rarity reward if exact match not found
  RewardData _getClosestRarityReward(RewardType type, int targetRarity) {
    final allRewards = _rewardPool[type]!;

    // Find reward with closest rarity
    RewardData closest = allRewards.first;
    int minDiff = (allRewards.first.rarity - targetRarity).abs();

    for (final reward in allRewards) {
      final diff = (reward.rarity - targetRarity).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = reward;
      }
    }

    return closest;
  }

  /// Determine number of rewards based on chest type
  int _getRewardCount(ChestType chestType) {
    switch (chestType) {
      case ChestType.bronze:
        return 1 + _random.nextInt(2); // 1-2 rewards
      case ChestType.silver:
        return 2 + _random.nextInt(2); // 2-3 rewards
      case ChestType.gold:
        return 3 + _random.nextInt(2); // 3-4 rewards
      case ChestType.special:
        return 4 + _random.nextInt(3); // 4-6 rewards
    }
  }

  /// Get all available rewards (for testing and display purposes)
  List<Reward> getAllAvailableRewards() {
    final allRewards = <Reward>[];

    _rewardPool.forEach((type, rewardDataList) {
      for (final data in rewardDataList) {
        allRewards.add(
          Reward(
            id: data.id,
            type: type,
            name: data.name,
            description: data.description,
            iconPath: data.iconPath,
            rarity: data.rarity,
          ),
        );
      }
    });

    return allRewards;
  }

  /// Get rewards by type
  List<Reward> getRewardsByType(RewardType type) {
    return _rewardPool[type]!
        .map(
          (data) => Reward(
            id: data.id,
            type: type,
            name: data.name,
            description: data.description,
            iconPath: data.iconPath,
            rarity: data.rarity,
          ),
        )
        .toList();
  }

  /// Get rewards by rarity
  List<Reward> getRewardsByRarity(int rarity) {
    final rewards = <Reward>[];

    _rewardPool.forEach((type, rewardDataList) {
      for (final data in rewardDataList.where((r) => r.rarity == rarity)) {
        rewards.add(
          Reward(
            id: data.id,
            type: type,
            name: data.name,
            description: data.description,
            iconPath: data.iconPath,
            rarity: data.rarity,
          ),
        );
      }
    });

    return rewards;
  }
}

/// Internal data class for reward definitions
class RewardData {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final int rarity;

  const RewardData(
    this.id,
    this.name,
    this.description,
    this.iconPath,
    this.rarity,
  );
}
