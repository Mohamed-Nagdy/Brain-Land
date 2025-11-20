import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'world_map_provider.dart';

part 'zone_unlock_provider.g.dart';

/// Provider to check if a zone is unlocked
@riverpod
class ZoneUnlock extends _$ZoneUnlock {
  @override
  Future<List<String>> build() async {
    final zones = await ref.watch(worldMapProvider.future);
    return zones
        .where((zone) => zone.isUnlocked)
        .map((zone) => zone.id)
        .toList();
  }

  /// Check if a specific zone is unlocked
  bool isZoneUnlocked(String zoneId) {
    return state.value?.contains(zoneId) ?? false;
  }
}
