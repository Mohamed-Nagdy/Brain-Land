import 'dart:developer';

import 'package:hive/hive.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/zone.dart';
import '../../../../shared/models/zone_progress.dart';
import '../../../../shared/services/storage_service.dart';
import '../../../math_forest/models/math_level.dart';
import '../../../memory_river/models/memory_level.dart';

/// Local service for managing world map data
class WorldMapLocalService {
  final StorageService _storage;

  WorldMapLocalService({StorageService? storage})
    : _storage = storage ?? StorageService.instance;

  /// Get all zones with their current state
  Future<List<Zone>> getZones() async {
    try {
      // Try to load zones from storage
      final box = _storage.getBox(AppConstants.progressBoxName);
      final List<dynamic>? storedZones = box.get('zones');

      List<Zone> zones;
      if (storedZones != null && storedZones.isNotEmpty) {
        zones = storedZones.cast<Zone>();

        // FORCE UNLOCK: Ensure all zones are unlocked (override old cached data)
        zones = zones.map((zone) => zone.copyWith(isUnlocked: true)).toList();
      } else {
        // If no zones exist, create default zones
        zones = _createDefaultZones();
        await _saveZones(zones);
      }

      // IMPORTANT: Always recalculate zone progress from actual level data
      // This ensures the UI shows correct numbers even if zone wasn't updated properly
      zones = await _syncZoneProgressWithLevels(zones);
      await _saveZones(zones); // Save the updated progress and unlock status

      return zones;
    } catch (e) {
      log('Error loading zones: $e');
      // If loading fails, return default zones
      return _createDefaultZones();
    }
  }

  /// Get a specific zone by ID
  Future<Zone?> getZone(String zoneId) async {
    final zones = await getZones();
    try {
      return zones.firstWhere((zone) => zone.id == zoneId);
    } catch (e) {
      return null;
    }
  }

  /// Unlock a zone
  Future<void> unlockZone(String zoneId) async {
    final zones = await getZones();
    final updatedZones = zones.map((zone) {
      if (zone.id == zoneId) {
        return zone.copyWith(isUnlocked: true);
      }
      return zone;
    }).toList();

    await _saveZones(updatedZones);
  }

  /// Update zone progress (completed levels)
  Future<void> updateZoneProgress(String zoneId, int completedLevels) async {
    final zones = await getZones();
    final updatedZones = zones.map((zone) {
      if (zone.id == zoneId) {
        return zone.copyWith(completedLevels: completedLevels);
      }
      return zone;
    }).toList();

    await _saveZones(updatedZones);
  }

  /// Get zone progress details
  Future<ZoneProgress?> getZoneProgress(String zoneId) async {
    try {
      final box = _storage.getBox(AppConstants.progressBoxName);
      final Map<dynamic, dynamic>? progressMap = box.get('zone_progress');

      if (progressMap != null && progressMap.containsKey(zoneId)) {
        return progressMap[zoneId] as ZoneProgress;
      }

      // Return default progress if none exists
      return ZoneProgress(
        zoneId: zoneId,
        levelsCompleted: 0,
        totalStars: 0,
        bestAccuracy: 0,
        lastPlayedAt: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Save zone progress details
  Future<void> saveZoneProgress(ZoneProgress progress) async {
    try {
      final box = _storage.getBox(AppConstants.progressBoxName);
      Map<dynamic, dynamic> progressMap = box.get('zone_progress') ?? {};
      progressMap[progress.zoneId] = progress;
      await box.put('zone_progress', progressMap);
    } catch (e) {
      rethrow;
    }
  }

  /// Check if a zone is unlocked
  Future<bool> isZoneUnlocked(String zoneId) async {
    final zone = await getZone(zoneId);
    return zone?.isUnlocked ?? false;
  }

  /// Save zones to storage
  Future<void> _saveZones(List<Zone> zones) async {
    await _storage.save(
      boxName: AppConstants.progressBoxName,
      key: 'zones',
      value: zones,
    );
  }

  /// Create default zones for initial game state
  List<Zone> _createDefaultZones() {
    return [
      const Zone(
        id: 'math_forest',
        name: 'Math Forest',
        description: 'Learn counting, addition, and subtraction',
        iconPath: 'assets/icons/math_forest.png',
        type: ZoneType.mathForest,
        isUnlocked: true,
        totalLevels: 1000,
        completedLevels: 0,
        availableGames: ['counting', 'addition', 'subtraction'],
      ),
      const Zone(
        id: 'logic_mountain',
        name: 'Logic Mountain',
        description: 'Solve patterns and sequences',
        iconPath: 'assets/icons/logic_mountain.png',
        type: ZoneType.logicMountain,
        isUnlocked: true, // ✅ Now unlocked!
        totalLevels: 1000,
        completedLevels: 0,
        availableGames: ['patterns', 'sequences'],
      ),
      const Zone(
        id: 'memory_river',
        name: 'Memory River',
        description: 'Match cards and improve memory',
        iconPath: 'assets/icons/memory_river.png',
        type: ZoneType.memoryRiver,
        isUnlocked: true, // ✅ Now unlocked!
        totalLevels: 1000,
        completedLevels: 0,
        availableGames: ['memory_match'],
      ),
      const Zone(
        id: 'shape_valley',
        name: 'Shape Valley',
        description: 'Sort and match shapes',
        iconPath: 'assets/icons/shape_valley.png',
        type: ZoneType.shapeValley,
        isUnlocked: true, // ✅ Now unlocked!
        totalLevels: 1000,
        completedLevels: 0,
        availableGames: ['shape_sort', 'shape_match'],
      ),
    ];
  }

  /// Sync zone progress with actual level completion data
  /// This ensures zones always show correct progress
  Future<List<Zone>> _syncZoneProgressWithLevels(List<Zone> zones) async {
    final updatedZones = <Zone>[];

    for (final zone in zones) {
      int completedCount = 0;

      // Count completed levels for each zone
      switch (zone.id) {
        case 'math_forest':
          completedCount = await _countCompletedMathLevels();
          break;
        case 'logic_mountain':
          completedCount = await _countCompletedLogicLevels();
          break;
        case 'memory_river':
          completedCount = await _countCompletedMemoryLevels();
          break;
        // Add other zones here when their storage is implemented
        default:
          completedCount = zone.completedLevels;
      }

      log(
        '[Zone Sync] ${zone.name}: $completedCount/${zone.totalLevels} completed',
      );

      if (completedCount != zone.completedLevels) {
        updatedZones.add(zone.copyWith(completedLevels: completedCount));
      } else {
        updatedZones.add(zone);
      }
    }

    return updatedZones;
  }

  /// Count completed Math Forest levels
  Future<int> _countCompletedMathLevels() async {
    try {
      final box = await Hive.openBox<MathLevel>('math_levels');
      int count = 0;

      for (final key in box.keys) {
        final level = box.get(key);
        if (level != null && level.isCompleted) {
          count++;
        }
      }

      log('[Math Levels] Found $count completed levels');
      return count;
    } catch (e) {
      log('[Math Levels] Error counting: $e');
      return 0;
    }
  }

  /// Count completed Logic Mountain levels
  Future<int> _countCompletedLogicLevels() async {
    try {
      final box = await Hive.openBox('logic_levels');
      int count = 0;

      for (final key in box.keys) {
        final dynamic level = box.get(key);
        if (level != null) {
          try {
            if ((level as dynamic).isCompleted == true) {
              count++;
            }
          } catch (e) {
            log('[Logic Levels] Error accessing level data: $e');
          }
        }
      }

      log('[Logic Levels] Found $count completed levels');
      return count;
    } catch (e) {
      log('[Logic Levels] Error counting: $e');
      return 0;
    }
  }

  /// Count completed Memory River levels
  Future<int> _countCompletedMemoryLevels() async {
    try {
      final box = await Hive.openBox<MemoryLevel>('memory_levels');
      int count = 0;

      for (final key in box.keys) {
        final level = box.get(key);
        if (level != null && level.isCompleted) {
          count++;
        }
      }

      log('[Memory Levels] Found $count completed levels');
      return count;
    } catch (e) {
      log('[Memory Levels] Error counting: $e');
      return 0;
    }
  }
}
