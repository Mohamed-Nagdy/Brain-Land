import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/zone.dart';
import '../../../../shared/models/zone_progress.dart';
import '../../../../shared/services/storage_service.dart';

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

      if (storedZones != null && storedZones.isNotEmpty) {
        return storedZones.cast<Zone>();
      }

      // If no zones exist, create default zones
      final defaultZones = _createDefaultZones();
      await _saveZones(defaultZones);
      return defaultZones;
    } catch (e) {
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
        isUnlocked: true, // First zone is unlocked by default
        totalLevels: 30,
        completedLevels: 0,
        availableGames: ['counting', 'addition', 'subtraction'],
      ),
      const Zone(
        id: 'logic_mountain',
        name: 'Logic Mountain',
        description: 'Solve patterns and sequences',
        iconPath: 'assets/icons/logic_mountain.png',
        type: ZoneType.logicMountain,
        isUnlocked: false,
        totalLevels: 20,
        completedLevels: 0,
        availableGames: ['patterns', 'sequences'],
      ),
      const Zone(
        id: 'memory_river',
        name: 'Memory River',
        description: 'Match cards and improve memory',
        iconPath: 'assets/icons/memory_river.png',
        type: ZoneType.memoryRiver,
        isUnlocked: false,
        totalLevels: 20,
        completedLevels: 0,
        availableGames: ['memory_match'],
      ),
      const Zone(
        id: 'shape_valley',
        name: 'Shape Valley',
        description: 'Sort and match shapes',
        iconPath: 'assets/icons/shape_valley.png',
        type: ZoneType.shapeValley,
        isUnlocked: false,
        totalLevels: 20,
        completedLevels: 0,
        availableGames: ['shape_sort', 'shape_match'],
      ),
    ];
  }
}
