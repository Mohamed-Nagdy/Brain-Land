import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/models/zone.dart';
import 'world_map_provider.dart';

part 'zone_unlock_provider.g.dart';

/// Provider for managing zone unlock logic
@riverpod
class ZoneUnlock extends _$ZoneUnlock {
  @override
  Future<void> build() async {
    // Initialize - check if any zones should be unlocked based on progress
    await _checkAndUnlockZones();
  }

  /// Check if zones should be unlocked based on progress
  Future<void> _checkAndUnlockZones() async {
    final worldMapNotifier = ref.read(worldMapProvider.notifier);
    final zones = await ref.read(worldMapProvider.future);

    // Logic Mountain unlocks after completing 10 levels in Math Forest
    final mathForest = zones.firstWhere((z) => z.type == ZoneType.mathForest);
    if (mathForest.completedLevels >= 10) {
      final logicMountain = zones.firstWhere(
        (z) => z.type == ZoneType.logicMountain,
      );
      if (!logicMountain.isUnlocked) {
        await worldMapNotifier.unlockZone(logicMountain.id);
      }
    }

    // Memory River unlocks after completing 10 levels in Logic Mountain
    final logicMountain = zones.firstWhere(
      (z) => z.type == ZoneType.logicMountain,
    );
    if (logicMountain.completedLevels >= 10) {
      final memoryRiver = zones.firstWhere(
        (z) => z.type == ZoneType.memoryRiver,
      );
      if (!memoryRiver.isUnlocked) {
        await worldMapNotifier.unlockZone(memoryRiver.id);
      }
    }

    // Shape Valley unlocks after completing 10 levels in Memory River
    final memoryRiver = zones.firstWhere((z) => z.type == ZoneType.memoryRiver);
    if (memoryRiver.completedLevels >= 10) {
      final shapeValley = zones.firstWhere(
        (z) => z.type == ZoneType.shapeValley,
      );
      if (!shapeValley.isUnlocked) {
        await worldMapNotifier.unlockZone(shapeValley.id);
      }
    }
  }

  /// Manually unlock a zone (for testing or special events)
  Future<void> unlockZone(String zoneId) async {
    final worldMapNotifier = ref.read(worldMapProvider.notifier);
    await worldMapNotifier.unlockZone(zoneId);
  }

  /// Check if a zone can be unlocked based on current progress
  Future<bool> canUnlockZone(String zoneId) async {
    final zones = await ref.read(worldMapProvider.future);
    final zone = zones.firstWhere((z) => z.id == zoneId);

    // If already unlocked, return true
    if (zone.isUnlocked) return true;

    // Check unlock requirements based on zone type
    switch (zone.type) {
      case ZoneType.mathForest:
        return true; // Always unlocked
      case ZoneType.logicMountain:
        final mathForest = zones.firstWhere(
          (z) => z.type == ZoneType.mathForest,
        );
        return mathForest.completedLevels >= 10;
      case ZoneType.memoryRiver:
        final logicMountain = zones.firstWhere(
          (z) => z.type == ZoneType.logicMountain,
        );
        return logicMountain.completedLevels >= 10;
      case ZoneType.shapeValley:
        final memoryRiver = zones.firstWhere(
          (z) => z.type == ZoneType.memoryRiver,
        );
        return memoryRiver.completedLevels >= 10;
    }
  }

  /// Get the unlock requirement message for a zone
  Future<String> getUnlockRequirement(String zoneId) async {
    final zones = await ref.read(worldMapProvider.future);
    final zone = zones.firstWhere((z) => z.id == zoneId);

    if (zone.isUnlocked) return 'Unlocked!';

    switch (zone.type) {
      case ZoneType.mathForest:
        return 'Available now!';
      case ZoneType.logicMountain:
        final mathForest = zones.firstWhere(
          (z) => z.type == ZoneType.mathForest,
        );
        final remaining = 10 - mathForest.completedLevels;
        return remaining > 0
            ? 'Complete $remaining more levels in Math Forest'
            : 'Ready to unlock!';
      case ZoneType.memoryRiver:
        final logicMountain = zones.firstWhere(
          (z) => z.type == ZoneType.logicMountain,
        );
        final remaining = 10 - logicMountain.completedLevels;
        return remaining > 0
            ? 'Complete $remaining more levels in Logic Mountain'
            : 'Ready to unlock!';
      case ZoneType.shapeValley:
        final memoryRiver = zones.firstWhere(
          (z) => z.type == ZoneType.memoryRiver,
        );
        final remaining = 10 - memoryRiver.completedLevels;
        return remaining > 0
            ? 'Complete $remaining more levels in Memory River'
            : 'Ready to unlock!';
    }
  }
}
