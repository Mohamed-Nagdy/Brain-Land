import 'package:brain_land/content/logic_chapter.dart';
import 'package:brain_land/content/math_chapter.dart';
import 'package:brain_land/content/missions.dart';
import 'package:brain_land/content/token.dart';
import 'package:brain_land/content/worlds.dart';
import 'package:flutter_test/flutter_test.dart';

/// Independent answer check, not using MathTask.answer.
int expectedMath(MathTask t) => switch (t.kind) {
  MathKind.count => t.a,
  MathKind.compare => t.a > t.b ? 0 : 1,
  MathKind.add => t.a + t.b,
  MathKind.takeAway => t.a - t.b,
  MathKind.fillTen => 10 - t.a,
  MathKind.equation => t.minus ? t.a - t.b : t.a + t.b,
  MathKind.missing => t.b - t.a,
};

/// The value a pattern gap must hold, derived from the visible cells.
Token? expectedGap(PatternTask t) {
  final i = t.gap;
  if (t.isNumbers) {
    final known = [
      for (var j = 0; j < t.cells.length; j++)
        if (t.cells[j] != null) (j, t.cells[j]!.number!),
    ];
    final step = (known[1].$2 - known[0].$2) ~/ (known[1].$1 - known[0].$1);
    for (var k = 1; k < known.length; k++) {
      final (j0, v0) = known[k - 1];
      final (j1, v1) = known[k];
      if ((v1 - v0) != step * (j1 - j0)) {
        return null; // not an arithmetic sequence
      }
    }
    return Token(number: known[0].$2 + step * (i - known[0].$1));
  }
  // Every visible cell must agree with the cell one unit before it.
  for (var j = t.unit; j < t.cells.length; j++) {
    final a = t.cells[j], b = t.cells[j - t.unit];
    if (a != null && b != null && a != b) return null;
  }
  if (i - t.unit >= 0) return t.cells[i - t.unit];
  if (i + t.unit < t.cells.length) return t.cells[i + t.unit];
  return null;
}

void main() {
  test('every world has 10,000 missions', () {
    expect(kMissionsPerWorld, 10000);
  });

  group('Math Forest', () {
    test('answers are right and choices are sound in all missions', () {
      for (var n = 0; n < kMissionsPerWorld; n++) {
        final items = mathMission(n);
        expect(items, hasLength(5), reason: 'mission $n');
        final seen = <String>{};
        for (final t in items) {
          final why = 'mission $n: ${t.kind} ${t.a} ${t.b} minus=${t.minus}';
          expect(t.answer, expectedMath(t), reason: why);
          expect(t.answer, greaterThanOrEqualTo(0), reason: why);
          expect(t.a, lessThanOrEqualTo(100), reason: why);
          expect(t.b, lessThanOrEqualTo(100), reason: why);
          final options = t.options.keys.toList();
          expect(options, contains(t.answer), reason: why);
          expect(options.toSet(), hasLength(options.length), reason: why);
          expect(options.every((o) => o >= 0), isTrue, reason: why);
          expect(
            options.length,
            t.kind == MathKind.compare ? 2 : inInclusiveRange(3, 4),
            reason: why,
          );
          if (t.kind == MathKind.compare) expect(t.a, isNot(t.b), reason: why);
          if (t.kind == MathKind.fillTen) {
            expect(t.a, inInclusiveRange(1, 9), reason: why);
          }
          expect(
            seen.add('${t.kind}/${t.a}/${t.b}/${t.minus}'),
            isTrue,
            reason: '$why repeated',
          );
        }
      }
    });

    test('the curated subtraction question matches its answer (v1.0 bug)', () {
      for (final t in mathChapter.expand((m) => m).where((t) => t.subtracts)) {
        expect(t.a, greaterThanOrEqualTo(t.b));
      }
    });

    test('numbers grow with the chapters', () {
      int maxIn(int from, int to) => [
        for (var n = from; n < to; n++)
          ...mathMission(
            n,
          ).map((t) => t.kind == MathKind.compare ? 0 : t.answer),
      ].reduce((a, b) => a > b ? a : b);
      expect(maxIn(0, 10), lessThanOrEqualTo(20));
      expect(maxIn(9900, 10000), greaterThan(50));
    });
  });

  group('Logic Mountain', () {
    test('every gap has exactly one right choice', () {
      for (var n = 0; n < kMissionsPerWorld; n++) {
        final items = logicMission(n);
        expect(items, hasLength(5), reason: 'mission $n');
        expect(
          items.map((t) => t.cells.toString()).toSet(),
          hasLength(5),
          reason: 'mission $n repeats',
        );
        for (final t in items) {
          final why = 'mission $n: ${t.cells} unit ${t.unit}';
          expect(t.cells.where((c) => c == null), hasLength(1), reason: why);
          expect(expectedGap(t), t.answer, reason: why);
          expect(
            t.choices.where((c) => c == t.answer),
            hasLength(1),
            reason: why,
          );
          expect(t.choices.toSet(), hasLength(t.choices.length), reason: why);
          expect(t.choices.length, inInclusiveRange(3, 4), reason: why);
          if (t.isNumbers) {
            expect(
              t.choices.every((c) => c.number! >= 0 && c.number! <= 110),
              isTrue,
              reason: why,
            );
          }
        }
      }
    });

    test('the answer is not always shown in the same place', () {
      final positions = {
        for (var n = 0; n < 50; n++)
          for (final t in logicMission(n)) t.choices.indexOf(t.answer),
      };
      expect(positions.length, greaterThan(1));
    });
  });

  group('Memory River', () {
    test('boards have 2–8 distinct pairs with real faces', () {
      for (var n = 0; n < kMissionsPerWorld; n++) {
        final t = memoryMission(n);
        expect(t.pairs, inInclusiveRange(2, 8), reason: 'mission $n');
        expect(t.faces.toSet(), hasLength(t.pairs), reason: 'mission $n');
      }
    });
  });

  group('Shape Valley', () {
    test('every piece fits exactly one slot, one piece per slot', () {
      for (var n = 0; n < kMissionsPerWorld; n++) {
        for (final board in shapeMission(n)) {
          final why = 'mission $n: ${board.pieces} → ${board.slots}';
          expect(board.pieces.length, board.slots.length, reason: why);
          expect(board.pieces.length, inInclusiveRange(3, 6), reason: why);
          for (final piece in board.pieces) {
            expect(board.slots.where(piece.fits), hasLength(1), reason: why);
          }
          // Square and diamond must never be turned (they would look alike).
          for (final s in board.slots) {
            if (s.shape == TokenShape.square ||
                s.shape == TokenShape.diamond ||
                s.shape == TokenShape.circle) {
              expect(s.turns, 0, reason: why);
            }
          }
          // Two sizes of one outline on a board are always small and large, never medium.
          for (final s in board.slots) {
            final same = board.slots.where(
              (o) => o.shape == s.shape && o.turns == s.turns,
            );
            if (same.length > 1) {
              expect(same.map((o) => o.size).toSet(), {
                TokenSize.small,
                TokenSize.large,
              }, reason: why);
            }
          }
        }
      }
    });
  });

  test('generated missions are stable across calls', () {
    expect(
      logicMission(345).map((t) => t.cells.toString()),
      logicMission(345).map((t) => t.cells.toString()),
    );
    expect(shapeMission(777).first.slots, shapeMission(777).first.slots);
  });
}
