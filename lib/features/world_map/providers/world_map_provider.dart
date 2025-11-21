import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/models/zone.dart';
import '../../../shared/models/zone_progress.dart';
import '../services/local/world_map_local_service.dart';

part 'world_map_provider.g.dart';

/// Provider for WorldMapLocalService
@riverpod
WorldMapLocalService worldMapLocalService(Ref ref) {
  return WorldMapLocalService();
}

/// Provider for managing world map state
@riverpod
class WorldMap extends _$WorldMap {
  @override
  Future<List<Zone>> build() async {
    final service = ref.read(worldMapLocalServiceProvider);
    return await service.getZones();
  }

  /// Unlock a zone
  Future<void> unlockZone(String zoneId) async {
    final service = ref.read(worldMapLocalServiceProvider);
    await service.unlockZone(zoneId);
    ref.invalidateSelf();
  }

  /// Update zone progress
  Future<void> updateZoneProgress(String zoneId, int completedLevels) async {
    final service = ref.read(worldMapLocalServiceProvider);
    await service.updateZoneProgress(zoneId, completedLevels);
    ref.invalidateSelf();
  }

  /// Get a specific zone
  Future<Zone?> getZone(String zoneId) async {
    final zones = state.value ?? [];
    try {
      return zones.firstWhere((zone) => zone.id == zoneId);
    } catch (e) {
      return null;
    }
  }

  /// Check if a zone is unlocked
  bool isZoneUnlocked(String zoneId) {
    final zones = state.value ?? [];
    try {
      final zone = zones.firstWhere((zone) => zone.id == zoneId);
      return zone.isUnlocked;
    } catch (e) {
      return false;
    }
  }

  /// Get zone progress
  Future<ZoneProgress?> getZoneProgress(String zoneId) async {
    final service = ref.read(worldMapLocalServiceProvider);
    return await service.getZoneProgress(zoneId);
  }

  /// Save zone progress
  Future<void> saveZoneProgress(ZoneProgress progress) async {
    final service = ref.read(worldMapLocalServiceProvider);
    await service.saveZoneProgress(progress);
    ref.invalidateSelf();
  }
}
