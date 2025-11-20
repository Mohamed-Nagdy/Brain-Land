import 'dart:io';
import 'dart:math';

import 'package:brain_land/core/constants/app_constants.dart';
import 'package:brain_land/shared/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Data Persistence Properties', () {
    late StorageService storage;
    late Directory testDir;

    setUp(() async {
      // Create a temporary directory for testing
      testDir = await Directory.systemTemp.createTemp('hive_test_');

      // Initialize storage with the test directory
      storage = StorageService.instance;
      await storage.initialize(path: testDir.path);
    });

    tearDown(() async {
      // Clean up after each test
      await storage.clearBox(AppConstants.progressBoxName);
      await storage.clearBox(AppConstants.avatarBoxName);
      await storage.clearBox(AppConstants.rewardsBoxName);
      await storage.clearBox(AppConstants.settingsBoxName);
      await storage.dispose();

      // Delete the test directory
      if (await testDir.exists()) {
        await testDir.delete(recursive: true);
      }
    });

    // **Feature: brainland-game, Property 42: Save and load preserves state (Round-trip)**
    test('save and load preserves player progress data', () async {
      final random = Random();

      // Run 100 iterations as specified in the design document
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        // Generate random progress data
        final playerId = 'player_${random.nextInt(10000)}';
        final totalStars = random.nextInt(1000);
        final totalCoins = random.nextInt(5000);
        final currentStreak = random.nextInt(30);
        final lastLoginTimestamp = DateTime.now()
            .subtract(Duration(days: random.nextInt(30)))
            .millisecondsSinceEpoch;

        final originalData = {
          'playerId': playerId,
          'totalStars': totalStars,
          'totalCoins': totalCoins,
          'currentStreak': currentStreak,
          'lastLoginTimestamp': lastLoginTimestamp,
        };

        // Save the data
        await storage.save(
          boxName: AppConstants.progressBoxName,
          key: playerId,
          value: originalData,
        );

        // Load the data back
        final loadedData = storage.load<Map>(
          boxName: AppConstants.progressBoxName,
          key: playerId,
        );

        // Verify the round-trip preserves all data
        expect(loadedData, isNotNull, reason: 'Loaded data should not be null');
        expect(
          loadedData!['playerId'],
          equals(originalData['playerId']),
          reason: 'Player ID should be preserved',
        );
        expect(
          loadedData['totalStars'],
          equals(originalData['totalStars']),
          reason: 'Total stars should be preserved',
        );
        expect(
          loadedData['totalCoins'],
          equals(originalData['totalCoins']),
          reason: 'Total coins should be preserved',
        );
        expect(
          loadedData['currentStreak'],
          equals(originalData['currentStreak']),
          reason: 'Current streak should be preserved',
        );
        expect(
          loadedData['lastLoginTimestamp'],
          equals(originalData['lastLoginTimestamp']),
          reason: 'Last login timestamp should be preserved',
        );

        // Clean up for next iteration
        await storage.delete(
          boxName: AppConstants.progressBoxName,
          key: playerId,
        );
      }
    });

    test('save and load preserves avatar customization data', () async {
      final random = Random();

      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final avatarId = 'avatar_${random.nextInt(10000)}';
        final baseTypes = ['panda', 'robot', 'cat'];
        final hats = ['hat1', 'hat2', 'hat3', null];
        final clothes = ['clothes1', 'clothes2', null];

        final originalData = {
          'id': avatarId,
          'baseType': baseTypes[random.nextInt(baseTypes.length)],
          'equippedHat': hats[random.nextInt(hats.length)],
          'equippedClothing': clothes[random.nextInt(clothes.length)],
          'background': 'bg_${random.nextInt(10)}',
        };

        // Save
        await storage.save(
          boxName: AppConstants.avatarBoxName,
          key: avatarId,
          value: originalData,
        );

        // Load
        final loadedData = storage.load<Map>(
          boxName: AppConstants.avatarBoxName,
          key: avatarId,
        );

        // Verify
        expect(loadedData, isNotNull);
        expect(loadedData!['id'], equals(originalData['id']));
        expect(loadedData['baseType'], equals(originalData['baseType']));
        expect(loadedData['equippedHat'], equals(originalData['equippedHat']));
        expect(
          loadedData['equippedClothing'],
          equals(originalData['equippedClothing']),
        );
        expect(loadedData['background'], equals(originalData['background']));

        // Clean up
        await storage.delete(
          boxName: AppConstants.avatarBoxName,
          key: avatarId,
        );
      }
    });

    test('save and load preserves reward data', () async {
      final random = Random();

      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final rewardId = 'reward_${random.nextInt(10000)}';
        final rewardTypes = ['coin', 'sticker', 'avatarItem', 'pet'];

        final originalData = {
          'id': rewardId,
          'type': rewardTypes[random.nextInt(rewardTypes.length)],
          'name': 'Reward $i',
          'rarity': random.nextInt(5) + 1,
          'earnedAt': DateTime.now().millisecondsSinceEpoch,
        };

        // Save
        await storage.save(
          boxName: AppConstants.rewardsBoxName,
          key: rewardId,
          value: originalData,
        );

        // Load
        final loadedData = storage.load<Map>(
          boxName: AppConstants.rewardsBoxName,
          key: rewardId,
        );

        // Verify
        expect(loadedData, isNotNull);
        expect(loadedData!['id'], equals(originalData['id']));
        expect(loadedData['type'], equals(originalData['type']));
        expect(loadedData['name'], equals(originalData['name']));
        expect(loadedData['rarity'], equals(originalData['rarity']));
        expect(loadedData['earnedAt'], equals(originalData['earnedAt']));

        // Clean up
        await storage.delete(
          boxName: AppConstants.rewardsBoxName,
          key: rewardId,
        );
      }
    });

    test('save and load preserves complex nested data structures', () async {
      final random = Random();

      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final playerId = 'player_${random.nextInt(10000)}';

        // Create complex nested structure
        final originalData = {
          'playerId': playerId,
          'totalStars': random.nextInt(1000),
          'zoneProgress': {
            'math_forest': {
              'levelsCompleted': random.nextInt(30),
              'stars': random.nextInt(90),
              'bestAccuracy': random.nextDouble(),
            },
            'logic_mountain': {
              'levelsCompleted': random.nextInt(30),
              'stars': random.nextInt(90),
              'bestAccuracy': random.nextDouble(),
            },
          },
          'unlockedItems': List.generate(
            random.nextInt(20),
            (index) => 'item_$index',
          ),
        };

        // Save
        await storage.save(
          boxName: AppConstants.progressBoxName,
          key: playerId,
          value: originalData,
        );

        // Load
        final loadedData = storage.load<Map>(
          boxName: AppConstants.progressBoxName,
          key: playerId,
        );

        // Verify
        expect(loadedData, isNotNull);
        expect(loadedData!['playerId'], equals(originalData['playerId']));
        expect(loadedData['totalStars'], equals(originalData['totalStars']));

        // Verify nested zone progress
        final loadedZoneProgress = loadedData['zoneProgress'] as Map;
        final originalZoneProgress = originalData['zoneProgress'] as Map;
        expect(
          loadedZoneProgress.keys.length,
          equals(originalZoneProgress.keys.length),
        );

        for (final zone in originalZoneProgress.keys) {
          final loadedZone = loadedZoneProgress[zone] as Map;
          final originalZone = originalZoneProgress[zone] as Map;
          expect(
            loadedZone['levelsCompleted'],
            equals(originalZone['levelsCompleted']),
          );
          expect(loadedZone['stars'], equals(originalZone['stars']));
          expect(
            loadedZone['bestAccuracy'],
            closeTo(originalZone['bestAccuracy'] as double, 0.0001),
          );
        }

        // Verify list data
        final loadedItems = loadedData['unlockedItems'] as List;
        final originalItems = originalData['unlockedItems'] as List;
        expect(loadedItems.length, equals(originalItems.length));
        for (int j = 0; j < originalItems.length; j++) {
          expect(loadedItems[j], equals(originalItems[j]));
        }

        // Clean up
        await storage.delete(
          boxName: AppConstants.progressBoxName,
          key: playerId,
        );
      }
    });
  });
}
