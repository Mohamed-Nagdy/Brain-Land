import 'package:brain_land/content/worlds.dart';
import 'package:brain_land/data/legacy_import.dart';
import 'package:brain_land/data/store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'helpers.dart';

/// Writes objects in exactly the byte layout version 1.0's generated
/// MathLevelAdapter used (typeId 17, fields 0–8).
class _V1MathLevel {
  _V1MathLevel(this.number, this.completed, this.stars);
  final int number;
  final bool completed;
  final int stars;
}

class _V1MathLevelWriter extends TypeAdapter<_V1MathLevel> {
  @override
  final int typeId = 17;

  @override
  _V1MathLevel read(BinaryReader reader) => throw UnimplementedError();

  @override
  void write(BinaryWriter w, _V1MathLevel o) {
    w
      ..writeByte(9)
      ..writeByte(0)
      ..write('math_${o.number}')
      ..writeByte(1)
      ..write(o.number)
      ..writeByte(2)
      ..write(1)
      ..writeByte(3)
      ..write(0)
      ..writeByte(4)
      ..write(5)
      ..writeByte(5)
      ..write(o.completed)
      ..writeByte(6)
      ..write(o.stars)
      ..writeByte(7)
      ..write(0)
      ..writeByte(8)
      ..write(0);
  }
}

void main() {
  test(
    '1.0 progress carries over in order and old boxes are removed',
    () async {
      final store = await openTestStore();
      Hive.registerAdapter(_V1MathLevelWriter());
      final old = await Hive.openBox<_V1MathLevel>('math_levels');
      // Stored out of order, with a gap: levels 1, 2 and 3 done, 4 not.
      await old.putAll({
        'b': _V1MathLevel(2, true, 3),
        'a': _V1MathLevel(1, true, 2),
        'd': _V1MathLevel(4, false, 0),
        'c': _V1MathLevel(3, true, 1),
      });
      await old.close();
      await Hive.openBox<dynamic>('player_progress').then((b) => b.close());

      await importLegacyProgress(store);

      final p = containerWith(store).read(progressProvider);
      expect(p.of(World.math).take(4), [2, 3, 1, 0]);
      expect(p.completedIn(World.logic), 0);
      expect(await Hive.boxExists('math_levels'), isFalse);
      expect(await Hive.boxExists('player_progress'), isFalse);
      expect(store.get('legacyImported'), isTrue);

      // Runs once only.
      containerWith(store).read(progressProvider.notifier).reset();
      await importLegacyProgress(store);
      expect(containerWith(store).read(progressProvider).totalStars, 0);
    },
  );
}
