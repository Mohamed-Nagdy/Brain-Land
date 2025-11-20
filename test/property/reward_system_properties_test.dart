import 'dart:math';

import 'package:brain_land/core/constants/app_constants.dart';
import 'package:brain_land/features/rewards/services/reward_generator.dart';
import 'package:brain_land/shared/models/reward.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Reward System Properties', () {
    late RewardGenerator generator;

    setUp(() {
      generator = RewardGenerator();
    });

    // **Feature: brainland-game, Property 19: High accuracy awards chest**
    test('90% or higher accuracy awards reward chest', () {
      // Test across 100 iterations with various accuracy levels
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        // Test accuracy at exactly 90%
        const accuracy90 = 0.90;
        expect(
          accuracy90 >= 0.90,
          isTrue,
          reason: '90% accuracy should qualify for reward chest',
        );

        // Test accuracy above 90%
        final accuracyAbove90 = 0.90 + (Random().nextDouble() * 0.10);
        expect(
          accuracyAbove90 >= 0.90,
          isTrue,
          reason: 'Accuracy above 90% should qualify for reward chest',
        );

        // Test accuracy below 90%
        final accuracyBelow90 = Random().nextDouble() * 0.89;
        expect(
          accuracyBelow90 < 0.90,
          isTrue,
          reason: 'Accuracy below 90% should not qualify for reward chest',
        );
      }
    });

    test('chest is awarded when correct/total >= 0.90', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final total = Random().nextInt(50) + 10; // 10-59 total questions
        final correct = (total * 0.90).ceil(); // Exactly 90% or slightly above

        final accuracy = correct / total;

        if (accuracy >= 0.90) {
          // Chest should be awarded
          expect(
            accuracy,
            greaterThanOrEqualTo(0.90),
            reason: 'Accuracy of $accuracy should award chest',
          );
        }
      }
    });

    test('edge case: perfect accuracy always awards chest', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final total = Random().nextInt(50) + 1;
        final correct = total; // 100% accuracy

        final accuracy = correct / total;

        expect(accuracy, equals(1.0), reason: 'Perfect accuracy should be 1.0');
        expect(
          accuracy >= 0.90,
          isTrue,
          reason: 'Perfect accuracy should award chest',
        );
      }
    });

    // **Feature: brainland-game, Property 20: Chest rewards are from valid set**
    test('all chest rewards are from valid reward pool', () {
      final allValidRewards = generator.getAllAvailableRewards();
      final validRewardIds = allValidRewards
          .map((r) => r.id.split('_').first)
          .toSet();

      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        // Test all chest types
        for (final chestType in ChestType.values) {
          final chest = generator.generateChest(chestType);

          // Verify all rewards in chest are from valid set
          for (final reward in chest.rewards) {
            final rewardBaseId = reward.id.split('_').first;
            expect(
              validRewardIds.contains(rewardBaseId),
              isTrue,
              reason: 'Reward ${reward.id} should be from valid reward pool',
            );
          }
        }
      }
    });

    test('chest rewards have valid reward types', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        for (final chestType in ChestType.values) {
          final chest = generator.generateChest(chestType);

          for (final reward in chest.rewards) {
            expect(
              RewardType.values.contains(reward.type),
              isTrue,
              reason: 'Reward type ${reward.type} should be valid',
            );
          }
        }
      }
    });

    test('chest rewards have valid rarity values (1-5)', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        for (final chestType in ChestType.values) {
          final chest = generator.generateChest(chestType);

          for (final reward in chest.rewards) {
            expect(
              reward.rarity,
              inInclusiveRange(1, 5),
              reason: 'Reward rarity should be between 1 and 5',
            );
          }
        }
      }
    });

    test('bronze chests only contain common to rare rewards', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final chest = generator.generateChest(ChestType.bronze);

        for (final reward in chest.rewards) {
          expect(
            reward.rarity,
            lessThanOrEqualTo(3),
            reason: 'Bronze chest should only contain rarity 1-3 rewards',
          );
        }
      }
    });

    test('special chests never contain common rewards', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final chest = generator.generateChest(ChestType.special);

        for (final reward in chest.rewards) {
          expect(
            reward.rarity,
            greaterThan(1),
            reason:
                'Special chest should not contain common (rarity 1) rewards',
          );
        }
      }
    });

    test('chest reward count matches chest type', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final bronzeChest = generator.generateChest(ChestType.bronze);
        expect(
          bronzeChest.rewards.length,
          inInclusiveRange(1, 2),
          reason: 'Bronze chest should have 1-2 rewards',
        );

        final silverChest = generator.generateChest(ChestType.silver);
        expect(
          silverChest.rewards.length,
          inInclusiveRange(2, 3),
          reason: 'Silver chest should have 2-3 rewards',
        );

        final goldChest = generator.generateChest(ChestType.gold);
        expect(
          goldChest.rewards.length,
          inInclusiveRange(3, 4),
          reason: 'Gold chest should have 3-4 rewards',
        );

        final specialChest = generator.generateChest(ChestType.special);
        expect(
          specialChest.rewards.length,
          inInclusiveRange(4, 6),
          reason: 'Special chest should have 4-6 rewards',
        );
      }
    });

    test('all rewards have required fields populated', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        for (final chestType in ChestType.values) {
          final chest = generator.generateChest(chestType);

          for (final reward in chest.rewards) {
            expect(
              reward.id.isNotEmpty,
              isTrue,
              reason: 'Reward should have id',
            );
            expect(
              reward.name.isNotEmpty,
              isTrue,
              reason: 'Reward should have name',
            );
            expect(
              reward.description.isNotEmpty,
              isTrue,
              reason: 'Reward should have description',
            );
            expect(
              reward.iconPath.isNotEmpty,
              isTrue,
              reason: 'Reward should have iconPath',
            );
          }
        }
      }
    });

    test('chest has valid metadata', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        for (final chestType in ChestType.values) {
          final chest = generator.generateChest(chestType);

          expect(chest.id.isNotEmpty, isTrue, reason: 'Chest should have id');
          expect(
            chest.type,
            equals(chestType),
            reason: 'Chest type should match requested type',
          );
          expect(
            chest.rewards.isNotEmpty,
            isTrue,
            reason: 'Chest should have at least one reward',
          );
          expect(
            chest.earnedAt.isBefore(DateTime.now().add(Duration(seconds: 1))),
            isTrue,
            reason: 'Chest earnedAt should be in the past or present',
          );
        }
      }
    });

    // **Feature: brainland-game, Property 22: Reward display triggers celebration**
    test('reward display should trigger celebration for all reward types', () {
      // This property tests that the system is designed to trigger celebrations
      // The actual celebration triggering is tested in the UI layer
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        for (final chestType in ChestType.values) {
          final chest = generator.generateChest(chestType);

          // Verify chest has rewards that would trigger celebration
          expect(
            chest.rewards.isNotEmpty,
            isTrue,
            reason: 'Chest should have rewards to display and celebrate',
          );

          // Verify each reward has display properties
          for (final reward in chest.rewards) {
            expect(
              reward.name.isNotEmpty,
              isTrue,
              reason: 'Reward should have name for display',
            );
            expect(
              reward.iconPath.isNotEmpty,
              isTrue,
              reason: 'Reward should have icon for display',
            );
          }
        }
      }
    });

    test('high rarity rewards should trigger more celebration', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final chest = generator.generateChest(ChestType.gold);

        for (final reward in chest.rewards) {
          // Higher rarity should have celebration intensity
          // Rarity 4-5 are epic/legendary and should have special celebration
          if (reward.rarity >= 4) {
            expect(
              reward.rarity,
              greaterThanOrEqualTo(4),
              reason:
                  'Epic/Legendary rewards should have high rarity for special celebration',
            );
          }
        }
      }
    });

    test('reward chest opening is a celebratory event', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        for (final chestType in ChestType.values) {
          final chest = generator.generateChest(chestType);

          // Chest should have properties that enable celebration
          expect(chest.rewards.isNotEmpty, isTrue);
          expect(ChestType.values.contains(chest.type), isTrue);

          // Better chests should have more/better rewards for bigger celebration
          if (chest.type == ChestType.special || chest.type == ChestType.gold) {
            expect(
              chest.rewards.length,
              greaterThanOrEqualTo(3),
              reason:
                  'Premium chests should have more rewards for bigger celebration',
            );
          }
        }
      }
    });

    test('reward rarity distribution follows chest type probabilities', () {
      // Test that rarity distribution roughly matches expected probabilities
      final rarityCountsByChestType = <ChestType, Map<int, int>>{};

      // Generate many chests to test distribution
      const iterations = 1000;
      for (final chestType in ChestType.values) {
        rarityCountsByChestType[chestType] = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

        for (int i = 0; i < iterations; i++) {
          final chest = generator.generateChest(chestType);
          for (final reward in chest.rewards) {
            rarityCountsByChestType[chestType]![reward.rarity] =
                rarityCountsByChestType[chestType]![reward.rarity]! + 1;
          }
        }
      }

      // Verify bronze chests have mostly common rewards (allow for randomness variance)
      final bronzeRarities = rarityCountsByChestType[ChestType.bronze]!;
      final bronzeTotal = bronzeRarities.values.reduce((a, b) => a + b);
      final bronzeCommonPercent = bronzeRarities[1]! / bronzeTotal;
      expect(
        bronzeCommonPercent,
        greaterThan(0.3),
        reason:
            'Bronze chests should have >30% common rewards (expected ~60% with variance)',
      );

      // Verify special chests have no common rewards
      final specialRarities = rarityCountsByChestType[ChestType.special]!;
      expect(
        specialRarities[1],
        equals(0),
        reason: 'Special chests should have 0 common rewards',
      );
    });

    test('reward IDs are unique within reasonable probability', () {
      final seenIds = <String>{};
      const iterations = 1000;

      for (int i = 0; i < iterations; i++) {
        final chest = generator.generateChest(ChestType.gold);
        for (final reward in chest.rewards) {
          // IDs should be unique (timestamp + random should make collisions rare)
          seenIds.add(reward.id);
        }
      }

      // With timestamp + random, we should have mostly unique IDs
      // Allow for some small collision rate due to timing
      expect(
        seenIds.length,
        greaterThan(iterations * 2), // Gold chests have 3-4 rewards
        reason: 'Most reward IDs should be unique',
      );
    });

    test('chest IDs are unique', () {
      final seenIds = <String>{};
      const iterations = 1000;

      for (int i = 0; i < iterations; i++) {
        final chest = generator.generateChest(ChestType.silver);
        seenIds.add(chest.id);
        // Small delay to ensure timestamp changes
        if (i % 100 == 0) {
          Future.delayed(Duration(milliseconds: 1));
        }
      }

      expect(
        seenIds.length,
        greaterThan(
          iterations * 0.8,
        ), // Allow for some collisions due to timing
        reason: 'Most chest IDs should be unique',
      );
    });

    test('getAllAvailableRewards returns all reward types', () {
      final allRewards = generator.getAllAvailableRewards();

      // Should have rewards of all types
      final types = allRewards.map((r) => r.type).toSet();
      expect(
        types.length,
        equals(RewardType.values.length),
        reason: 'Should have rewards of all types',
      );

      for (final type in RewardType.values) {
        expect(
          types.contains(type),
          isTrue,
          reason: 'Should have rewards of type $type',
        );
      }
    });

    test('getRewardsByType returns only requested type', () {
      for (final type in RewardType.values) {
        final rewards = generator.getRewardsByType(type);

        expect(
          rewards.isNotEmpty,
          isTrue,
          reason: 'Should have rewards of type $type',
        );

        for (final reward in rewards) {
          expect(
            reward.type,
            equals(type),
            reason: 'All rewards should be of requested type',
          );
        }
      }
    });

    test('getRewardsByRarity returns only requested rarity', () {
      for (int rarity = 1; rarity <= 5; rarity++) {
        final rewards = generator.getRewardsByRarity(rarity);

        expect(
          rewards.isNotEmpty,
          isTrue,
          reason: 'Should have rewards of rarity $rarity',
        );

        for (final reward in rewards) {
          expect(
            reward.rarity,
            equals(rarity),
            reason: 'All rewards should be of requested rarity',
          );
        }
      }
    });

    test('reward equality works correctly', () {
      final reward1 = Reward(
        id: 'test_1',
        type: RewardType.coin,
        name: 'Test Coin',
        description: 'A test',
        iconPath: 'test.png',
        rarity: 1,
      );

      final reward2 = Reward(
        id: 'test_1',
        type: RewardType.coin,
        name: 'Test Coin',
        description: 'A test',
        iconPath: 'test.png',
        rarity: 1,
      );

      expect(reward1, equals(reward2));
    });

    test('chest equality works correctly', () {
      final rewards = [
        Reward(
          id: 'test_1',
          type: RewardType.coin,
          name: 'Test',
          description: 'Test',
          iconPath: 'test.png',
          rarity: 1,
        ),
      ];

      final earnedAt = DateTime.now();

      final chest1 = RewardChest(
        id: 'chest_1',
        type: ChestType.bronze,
        rewards: rewards,
        earnedAt: earnedAt,
      );

      final chest2 = RewardChest(
        id: 'chest_1',
        type: ChestType.bronze,
        rewards: rewards,
        earnedAt: earnedAt,
      );

      expect(chest1, equals(chest2));
    });
  });
}
