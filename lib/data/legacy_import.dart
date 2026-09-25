import 'dart:math';

import 'package:hive/hive.dart';

import '../content/worlds.dart';

/// Version 1.0 stored 1000 generated levels per world in typed Hive boxes.
/// On first launch of 1.1 we carry over how far a player got — their
/// finished levels become finished missions in order, stars kept — then
/// delete the old boxes.
Future<void> importLegacyProgress(Box<dynamic> store) async {
  if (store.get('legacyImported') == true) return;
  for (var id = 0; id < 25; id++) {
    Hive.registerAdapter<_V1Object>(_LegacyAdapter(id), override: true);
  }
  for (final entry in _legacyLevelBoxes.entries) {
    final (world, completedField, starsField) = entry.value;
    if (!await Hive.boxExists(entry.key)) continue;
    try {
      final box = await Hive.openBox<dynamic>(entry.key);
      final done =
          box.values
              .whereType<_V1Object>()
              .map((o) => o.fields)
              .where((f) => f[completedField] == true)
              .toList()
            ..sort((a, b) => (a[1] as int).compareTo(b[1] as int));
      final stars = [
        for (var i = 0; i < kMissionsPerWorld; i++)
          i < done.length
              ? max(1, min(3, (done[i][starsField] as int?) ?? 1))
              : 0,
      ];
      if (stars.any((s) => s > 0)) {
        await store.put('stars.${world.slug}', stars);
      }
      await box.close();
    } catch (_) {
      // Unreadable old data is not worth blocking play for; start that world fresh.
    }
  }
  for (final name in [..._legacyLevelBoxes.keys, ..._legacyOtherBoxes]) {
    await Hive.deleteBoxFromDisk(name).catchError((_) {});
  }
  await store.put('legacyImported', true);
}

/// box name → (world, index of `isCompleted`, index of `starsEarned`).
const _legacyLevelBoxes = {
  'math_levels': (World.math, 5, 6),
  'logic_levels': (World.logic, 5, 6),
  'memory_levels': (World.memory, 6, 7),
  'shape_levels': (World.shape, 8, 9),
};
const _legacyOtherBoxes = [
  'math_results',
  'player_progress',
  'avatar_data',
  'rewards',
  'settings',
];

const _legacyEnumTypeIds = {0, 5, 7, 9, 11, 13, 14, 19, 21, 22};

/// A 1.0 object read as its raw field map (enums as their index).
class _V1Object {
  const _V1Object(this.fields);
  final Map<int, dynamic> fields;
}

class _LegacyAdapter extends TypeAdapter<_V1Object> {
  _LegacyAdapter(this.typeId);

  @override
  final int typeId;

  @override
  _V1Object read(BinaryReader reader) {
    if (_legacyEnumTypeIds.contains(typeId)) {
      return _V1Object({0: reader.readByte()});
    }
    final count = reader.readByte();
    return _V1Object({
      for (var i = 0; i < count; i++) reader.readByte(): reader.read(),
    });
  }

  @override
  void write(BinaryWriter writer, _V1Object obj) =>
      throw UnsupportedError('1.0 data is read-only');
}
