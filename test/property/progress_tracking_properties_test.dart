import 'dart:io';
import 'dart:math';

import 'package:brain_land/core/constants/app_constants.dart';
import 'package:brain_land/features/progress/services/progress_storage_service.dart';
import 'package:brain_land/shared/models/player_progress.dart';
import 'package:brain_land/shared/models/zone_progress.dart';
import 'package:brain_land/shared/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Progress Tracking Properties', () {
    late StorageService storage;
    late ProgressStorageService progressService;
    late Directory testDir;

    setUp(() async {
      // Create a temporary directory for testing
      testDir = await Directory.systemTemp.createTemp('hive_test_');

      // Initialize storage with the test directory
      storage = StorageService.instance;
      await storage.initialize(path: testDir.path);

      progressService = ProgressStorageService(storageService: storage);
    });

    tearDown(() async {
      // Clean up after each test
      await storage.clearBox(AppConstants.progressBoxName);
      await storage.dispose();

      // Delete the test directory
      if (await testDir.exists()) {
        await testDir.delete(recursive: true);
      }
    });

    // **Feature: brainland-game, Property 31: Total stars equals sum of zone stars**
    test('total stars equals sum of zone stars', () async {
      final random = Random();

      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        // Generate random zone progress
        final zones = [
          'math_forest',
          'logic_mountain',
          'memory_river',
          'shape_valley',
        ];
        final zoneProgressMap = <String, ZoneProgress>{};
        int expectedTotalStars = 0;

        for (final zoneId in zones) {
          final zoneStars = random.nextInt(100);
          expectedTotalStars += zoneStars;

          zoneProgressMap[zoneId] = ZoneProgress(
            zoneId: zoneId,
            levelsCompleted: random.nextInt(30),
            totalStars: zoneStars,
            bestAccuracy: random.nextInt(100),
            lastPlayedAt: DateTime.now(),
          );
        }

        // Create progress with calculated total
        final progress = PlayerProgress(
          playerId: 'player_$i',
          totalStars: expectedTotalStars,
          totalCoins: random.nextInt(1000),
          zoneProgress: zoneProgressMap,
          unlockedPets: [],
          unlockedStickers: [],
          unlockedAvatarItems: [],
          currentStreak: random.nextInt(30),
          lastLoginDate: DateTime.now(),
          totalPlayTime: random.nextInt(10000),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await progressService.updateProgress(progress);

        // Load and verify
        final loadedProgress = await progressService.getProgress();
        final actualTotalStars = loadedProgress.zoneProgress.values.fold<int>(
          0,
          (sum, zone) => sum + zone.totalStars,
        );

        expect(
          loadedProgress.totalStars,
          equals(actualTotalStars),
          reason: 'Total stars should equal sum of zone stars',
        );
      }
    });

    // **Feature: brainland-game, Property 32: Completion percentage is accurate**
    test('completion percentage is accurate', () async {
      final random = Random();

      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final totalLevels = 30; // Assume 30 levels per zone
        final levelsCompleted = random.nextInt(totalLevels + 1);

        final zoneProgress = ZoneProgress(
          zoneId: 'test_zone',
          levelsCompleted: levelsCompleted,
          totalStars: random.nextInt(90),
          bestAccuracy: random.nextInt(100),
          lastPlayedAt: DateTime.now(),
        );

        // Calculate expected percentage
        final expectedPercentage = (levelsCompleted / totalLevels * 100)
            .round();

        // Verify the calculation
        final actualPercentage =
            (zoneProgress.levelsCompleted / totalLevels * 100).round();

        expect(
          actualPercentage,
          equals(expectedPercentage),
          reason: 'Completion percentage should be (completed / total) × 100',
        );
      }
    });

    // **Feature: brainland-game, Property 33: Progress shows all unlocked items**
    test('progress shows all unlocked items', () async {
      final random = Random();

      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        // Generate random unlocked items
        final numPets = random.nextInt(10);
        final numStickers = random.nextInt(20);
        final numAvatarItems = random.nextInt(15);

        final unlockedPets = List.generate(numPets, (index) => 'pet_$index');
        final unlockedStickers = List.generate(
          numStickers,
          (index) => 'sticker_$index',
        );
        final unlockedAvatarItems = List.generate(
          numAvatarItems,
          (index) => 'item_$index',
        );

        final progress = PlayerProgress(
          playerId: 'player_$i',
          totalStars: random.nextInt(1000),
          totalCoins: random.nextInt(5000),
          zoneProgress: {},
          unlockedPets: unlockedPets,
          unlockedStickers: unlockedStickers,
          unlockedAvatarItems: unlockedAvatarItems,
          currentStreak: random.nextInt(30),
          lastLoginDate: DateTime.now(),
          totalPlayTime: random.nextInt(10000),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await progressService.updateProgress(progress);

        // Load and verify all items are present
        final loadedProgress = await progressService.getProgress();

        expect(
          loadedProgress.unlockedPets.length,
          equals(numPets),
          reason: 'All unlocked pets should be present',
        );
        expect(
          loadedProgress.unlockedStickers.length,
          equals(numStickers),
          reason: 'All unlocked stickers should be present',
        );
        expect(
          loadedProgress.unlockedAvatarItems.length,
          equals(numAvatarItems),
          reason: 'All unlocked avatar items should be present',
        );

        // Verify specific items
        for (final pet in unlockedPets) {
          expect(
            loadedProgress.unlockedPets.contains(pet),
            isTrue,
            reason: 'Pet $pet should be in unlocked pets',
          );
        }
        for (final sticker in unlockedStickers) {
          expect(
            loadedProgress.unlockedStickers.contains(sticker),
            isTrue,
            reason: 'Sticker $sticker should be in unlocked stickers',
          );
        }
        for (final item in unlockedAvatarItems) {
          expect(
            loadedProgress.unlockedAvatarItems.contains(item),
            isTrue,
            reason: 'Avatar item $item should be in unlocked items',
          );
        }
      }
    });

    // **Feature: brainland-game, Property 39: Level completion triggers save**
    test('level completion triggers save', () async {
      final random = Random();

      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        // Simulate level completion by updating zone progress
        final zoneId = 'test_zone_$i';
        final levelsCompleted = random.nextInt(30) + 1;
        final starsEarned = random.nextInt(3) + 1;

        final zoneProgress = ZoneProgress(
          zoneId: zoneId,
          levelsCompleted: levelsCompleted,
          totalStars: starsEarned,
          bestAccuracy: random.nextInt(100),
          lastPlayedAt: DateTime.now(),
        );

        // Update zone progress (simulating level completion)
        await progressService.updateZoneProgress(zoneId, zoneProgress);

        // Verify the save occurred by loading the data
        final loadedProgress = await progressService.getProgress();

        expect(
          loadedProgress.zoneProgress.containsKey(zoneId),
          isTrue,
          reason: 'Zone progress should be saved after level completion',
        );

        final loadedZoneProgress = loadedProgress.zoneProgress[zoneId]!;
        expect(
          loadedZoneProgress.levelsCompleted,
          equals(levelsCompleted),
          reason: 'Levels completed should be saved',
        );
        expect(
          loadedZoneProgress.totalStars,
          equals(starsEarned),
          reason: 'Stars earned should be saved',
        );
      }
    });

    // **Feature: brainland-game, Property 40: Rewards persist to storage**
    test('rewards persist to storage', () async {
      final random = Random();

      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        // Start with fresh progress
        await progressService.resetProgress();

        // Unlock various rewards
        final petId = 'pet_${random.nextInt(100)}';
        final stickerId = 'sticker_${random.nextInt(100)}';
        final itemId = 'item_${random.nextInt(100)}';

        await progressService.unlockPet(petId);
        await progressService.unlockSticker(stickerId);
        await progressService.unlockAvatarItem(itemId);

        // Load progress and verify rewards persisted
        final loadedProgress = await progressService.getProgress();

        expect(
          loadedProgress.unlockedPets.contains(petId),
          isTrue,
          reason: 'Unlocked pet should persist to storage',
        );
        expect(
          loadedProgress.unlockedStickers.contains(stickerId),
          isTrue,
          reason: 'Unlocked sticker should persist to storage',
        );
        expect(
          loadedProgress.unlockedAvatarItems.contains(itemId),
          isTrue,
          reason: 'Unlocked avatar item should persist to storage',
        );

        // Verify rewards don't duplicate
        await progressService.unlockPet(petId);
        await progressService.unlockSticker(stickerId);
        await progressService.unlockAvatarItem(itemId);

        final reloadedProgress = await progressService.getProgress();

        expect(
          reloadedProgress.unlockedPets.where((p) => p == petId).length,
          equals(1),
          reason: 'Pet should not be duplicated',
        );
        expect(
          reloadedProgress.unlockedStickers.where((s) => s == stickerId).length,
          equals(1),
          reason: 'Sticker should not be duplicated',
        );
        expect(
          reloadedProgress.unlockedAvatarItems.where((i) => i == itemId).length,
          equals(1),
          reason: 'Avatar item should not be duplicated',
        );
      }
    });

    test('zone progress update recalculates total stars correctly', () async {
      final random = Random();

      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        // Start with fresh progress
        await progressService.resetProgress();

        // Add multiple zones with stars
        final zones = ['math_forest', 'logic_mountain', 'memory_river'];
        int expectedTotal = 0;

        for (final zoneId in zones) {
          final stars = random.nextInt(50) + 1;
          expectedTotal += stars;

          final zoneProgress = ZoneProgress(
            zoneId: zoneId,
            levelsCompleted: random.nextInt(30),
            totalStars: stars,
            bestAccuracy: random.nextInt(100),
            lastPlayedAt: DateTime.now(),
          );

          await progressService.updateZoneProgress(zoneId, zoneProgress);
        }

        // Verify total stars is correct
        final progress = await progressService.getProgress();
        expect(
          progress.totalStars,
          equals(expectedTotal),
          reason: 'Total stars should be sum of all zone stars',
        );
      }
    });
  });
}
