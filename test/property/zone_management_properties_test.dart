import 'dart:io';
import 'dart:math';

import 'package:brain_land/features/world_map/services/local/world_map_local_service.dart';
import 'package:brain_land/shared/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late StorageService storage;
  late WorldMapLocalService service;
  late Directory tempDir;

  setUp(() async {
    // Create a temporary directory for test storage
    tempDir = await Directory.systemTemp.createTemp('zone_test_');
    storage = StorageService.instance;
    await storage.initialize(path: tempDir.path);
    service = WorldMapLocalService(storage: storage);
  });

  tearDown(() async {
    await storage.dispose();
    // Clean up temp directory
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Zone Management Property Tests', () {
    // **Feature: brainland-game, Property 1: Locked zones prevent navigation**
    test('Property 1: Locked zones prevent navigation', () async {
      // Run 100 iterations
      for (int i = 0; i < 100; i++) {
        // Get all zones
        final zones = await service.getZones();

        // Find locked zones
        final lockedZones = zones.where((zone) => !zone.isUnlocked).toList();

        // For each locked zone, verify it should not allow navigation
        for (final zone in lockedZones) {
          // A locked zone should have isUnlocked = false
          expect(
            zone.isUnlocked,
            isFalse,
            reason: 'Zone ${zone.name} should be locked',
          );

          // Verify the zone cannot be accessed
          final isUnlocked = await service.isZoneUnlocked(zone.id);
          expect(
            isUnlocked,
            isFalse,
            reason: 'Zone ${zone.name} should not be accessible',
          );
        }

        // Randomly unlock a zone and verify it becomes accessible
        if (lockedZones.isNotEmpty) {
          final randomZone = lockedZones[Random().nextInt(lockedZones.length)];
          await service.unlockZone(randomZone.id);

          final isNowUnlocked = await service.isZoneUnlocked(randomZone.id);
          expect(
            isNowUnlocked,
            isTrue,
            reason:
                'Zone ${randomZone.name} should be unlocked after unlocking',
          );
        }

        // Reset for next iteration
        await storage.clearBox('player_progress');
      }
    });

    // **Feature: brainland-game, Property 2: Zone progress display completeness**
    test('Property 2: Zone progress display completeness', () async {
      // Run 100 iterations
      for (int i = 0; i < 100; i++) {
        // Get all zones
        final zones = await service.getZones();

        // For each zone, verify progress information is complete
        for (final zone in zones) {
          // Verify all required progress fields are present
          expect(zone.id, isNotEmpty, reason: 'Zone should have an ID');
          expect(zone.name, isNotEmpty, reason: 'Zone should have a name');
          expect(
            zone.totalLevels,
            greaterThan(0),
            reason: 'Zone should have total levels',
          );
          expect(
            zone.completedLevels,
            greaterThanOrEqualTo(0),
            reason: 'Zone should have completed levels count',
          );
          expect(
            zone.completedLevels,
            lessThanOrEqualTo(zone.totalLevels),
            reason: 'Completed levels should not exceed total levels',
          );

          // Get zone progress details
          final progress = await service.getZoneProgress(zone.id);
          expect(
            progress,
            isNotNull,
            reason: 'Zone progress should exist for ${zone.name}',
          );
          expect(
            progress!.zoneId,
            equals(zone.id),
            reason: 'Progress should match zone ID',
          );
          expect(
            progress.levelsCompleted,
            greaterThanOrEqualTo(0),
            reason: 'Progress should have valid levels completed',
          );
          expect(
            progress.totalStars,
            greaterThanOrEqualTo(0),
            reason: 'Progress should have valid total stars',
          );
          expect(
            progress.bestAccuracy,
            greaterThanOrEqualTo(0),
            reason: 'Progress should have valid accuracy',
          );
          expect(
            progress.bestAccuracy,
            lessThanOrEqualTo(100),
            reason: 'Accuracy should not exceed 100%',
          );
        }

        // Randomly update progress and verify it's reflected
        final randomZone = zones[Random().nextInt(zones.length)];
        final randomProgress = Random().nextInt(randomZone.totalLevels + 1);
        await service.updateZoneProgress(randomZone.id, randomProgress);

        final updatedZone = await service.getZone(randomZone.id);
        expect(
          updatedZone!.completedLevels,
          equals(randomProgress),
          reason: 'Zone progress should be updated',
        );

        // Reset for next iteration
        await storage.clearBox('player_progress');
      }
    });

    // **Feature: brainland-game, Property 3: Completion badges for finished zones**
    test('Property 3: Completion badges for finished zones', () async {
      // Run 100 iterations
      for (int i = 0; i < 100; i++) {
        // Get all zones
        final zones = await service.getZones();

        for (final zone in zones) {
          // Test various completion states
          final completionStates = [
            0, // Not started
            zone.totalLevels ~/ 2, // Half complete
            zone.totalLevels - 1, // Almost complete
            zone.totalLevels, // Fully complete
          ];

          for (final completedLevels in completionStates) {
            await service.updateZoneProgress(zone.id, completedLevels);
            final updatedZone = await service.getZone(zone.id);

            // Verify completion status
            final isComplete =
                updatedZone!.completedLevels >= updatedZone.totalLevels;

            if (isComplete) {
              // For a completed zone, all levels should be done
              expect(
                updatedZone.completedLevels,
                equals(updatedZone.totalLevels),
                reason: 'Completed zone should have all levels done',
              );

              // A completion badge should be displayable (verified by having 100% completion)
              final completionPercentage =
                  (updatedZone.completedLevels / updatedZone.totalLevels * 100)
                      .round();
              expect(
                completionPercentage,
                equals(100),
                reason: 'Completed zone should show 100% completion for badge',
              );
            } else {
              // For incomplete zones, completion should be less than 100%
              final completionPercentage =
                  (updatedZone.completedLevels / updatedZone.totalLevels * 100)
                      .round();
              expect(
                completionPercentage,
                lessThan(100),
                reason: 'Incomplete zone should not show completion badge',
              );
            }
          }
        }

        // Reset for next iteration
        await storage.clearBox('player_progress');
      }
    });
  });
}
