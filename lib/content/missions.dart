import 'dart:math';

import 'logic_chapter.dart';
import 'math_chapter.dart';
import 'memory_chapter.dart';
import 'shape_chapter.dart';
import 'token.dart';
import 'worlds.dart';

/// Mission content by world and mission number (0 … [kMissionsPerWorld] − 1).
/// Chapter 1 (missions 0–9) is the hand-written chapter; every later mission is
/// generated from a fixed seed, so a mission is the same on every device and
/// every play. Difficulty rises with the chapter. `test/content_test.dart`
/// checks every mission for correct answers and repetition.
List<MathTask> mathMission(int n) =>
    n < kMissionsPerChapter ? mathChapter[n] : _MathGen(n).mission();

List<PatternTask> logicMission(int n) =>
    n < kMissionsPerChapter ? logicChapter[n] : _LogicGen(n).mission();

MemoryTask memoryMission(int n) =>
    n < kMissionsPerChapter ? memoryChapter[n].single : _memory(n);

List<ShapeTask> shapeMission(int n) =>
    n < kMissionsPerChapter ? shapeChapter[n] : _ShapeGen(n).mission();

int _chapter(int n) => n ~/ kMissionsPerChapter;
Random _rng(World w, int n) => Random(w.index * 1000003 + n * 7919);

// ───────────────────────────── Math Forest ─────────────────────────────

class _MathGen {
  _MathGen(this.n) : c = _chapter(n), r = _rng(World.math, n);

  final int n;
  final int c;
  final Random r;

  /// Largest number used in this chapter.
  int get top => c < 5
      ? 20
      : c < 15
      ? 30
      : c < 30
      ? 50
      : 100;

  int _between(int lo, int hi) => lo + r.nextInt(hi - lo + 1);

  MathTask _one(int slot) {
    final small = top <= 20;
    switch (slot) {
      case 0:
        if (small && c < 3) {
          final a = _between(1, 9);
          return MathTask(
            MathKind.add,
            a,
            _between(1, 10 - a),
            Counter.values[r.nextInt(4)],
          );
        }
        return _sum();
      case 1:
        if (small && c < 3) {
          final a = _between(3, 10);
          return MathTask(
            MathKind.takeAway,
            a,
            _between(1, a),
            Counter.values[r.nextInt(4)],
          );
        }
        return _difference();
      case 2:
      case 5:
        return _sum();
      case 3:
      case 8:
        return _difference();
      case 4:
        if (c < 4) return MathTask(MathKind.fillTen, _between(1, 9));
        return _missing();
      case 6:
        if (c < 3) {
          return MathTask(
            MathKind.count,
            _between(6, 10),
            0,
            Counter.values[r.nextInt(4)],
          );
        }
        return _missing();
      case 7:
        if (c < 5) {
          final a = _between(2, 10);
          var b = _between(2, 10);
          if (b == a) b = a == 10 ? 9 : a + 1;
          return MathTask(MathKind.compare, a, b, Counter.values[r.nextInt(4)]);
        }
        return _sum();
      default:
        return r.nextBool() ? _sum() : _difference();
    }
  }

  MathTask _sum() {
    final a = _between(1, top - 1);
    return MathTask(MathKind.equation, a, _between(1, top - a));
  }

  MathTask _difference() {
    final a = _between(2, top);
    return MathTask(MathKind.equation, a, _between(1, a), Counter.acorn, true);
  }

  MathTask _missing() {
    final b = _between(5, top);
    return MathTask(MathKind.missing, _between(1, b - 1), b);
  }

  List<MathTask> mission() {
    final slot = n % kMissionsPerChapter;
    final seen = <String>{};
    final items = <MathTask>[];
    while (items.length < 5) {
      final t = _one(slot);
      if (seen.add('${t.kind}${t.a}${t.b}${t.minus}')) items.add(t);
    }
    return items;
  }
}

// ──────────────────────────── Logic Mountain ────────────────────────────

class _LogicGen {
  _LogicGen(this.n) : c = _chapter(n), r = _rng(World.logic, n);

  final int n;
  final int c;
  final Random r;

  static const _units = {
    'AB': 2,
    'AAB': 3,
    'ABB': 3,
    'ABC': 3,
    'AABB': 4,
    'ABCD': 4,
    'ABAC': 4,
  };

  List<String> get _allowedUnits => c < 10
      ? ['AB', 'AAB', 'ABB', 'ABC']
      : c < 30
      ? ['AB', 'AAB', 'ABB', 'ABC', 'AABB']
      : _units.keys.toList();

  static const _shapes = [
    TokenShape.circle,
    TokenShape.square,
    TokenShape.triangle,
    TokenShape.star,
    TokenShape.heart,
    TokenShape.diamond,
    TokenShape.hexagon,
  ];

  /// Distinct tokens for the letters of a pattern, varying colour, shape, both or size.
  List<Token> _elements(int count) {
    final mode = c < 3
        ? r.nextInt(2)
        : r.nextInt(4); // 0 colour, 1 shape, 2 both, 3 size
    if (mode == 3 && count <= 3) {
      final shape = _shapes[r.nextInt(_shapes.length)];
      final color = TokenColor.values[r.nextInt(TokenColor.values.length)];
      final sizes = [...TokenSize.values]..shuffle(r);
      return [
        for (var i = 0; i < count; i++)
          Token(shape: shape, color: color, size: sizes[i]),
      ];
    }
    final colors = [...TokenColor.values]..shuffle(r);
    final shapes = [..._shapes]..shuffle(r);
    return [
      for (var i = 0; i < count; i++)
        Token(
          color: mode == 1 ? colors.first : colors[i],
          shape: mode == 0 ? shapes.first : shapes[i],
        ),
    ];
  }

  PatternTask _tokens({required bool middleGap}) {
    final name = _allowedUnits[r.nextInt(_allowedUnits.length)];
    final unit = _units[name]!;
    final letters = name.split('').toSet().length;
    final pool = _elements(letters + 1);
    final elements = pool.take(letters).toList();
    Token at(int i) => elements[name.codeUnitAt(i % unit) - 65];
    final length = unit * 2 + 1 + r.nextInt(2);
    final cells = <Token?>[for (var i = 0; i < length; i++) at(i)];
    final gap = middleGap ? unit + r.nextInt(length - unit - 1) : length - 1;
    final answer = cells[gap]!;
    cells[gap] = null;
    final distractors = {...elements, pool.last}..remove(answer);
    final choices = [answer, ...distractors.take(c >= 20 ? 3 : 2)];
    return PatternTask.of(cells, choices, unit: unit);
  }

  PatternTask _numbers({required bool middleGap}) {
    final steps = c < 10
        ? [1, 2]
        : c < 30
        ? [1, 2, 3, 5]
        : [2, 3, 4, 5, 10];
    var step = steps[r.nextInt(steps.length)];
    if (c >= 5 && r.nextInt(3) == 0) step = -step;
    final length = 5;
    final maxStart = 100 - step.abs() * (length - 1);
    var start = 1 + r.nextInt(max(1, (c < 10 ? 10 : maxStart)));
    if (step < 0) start += step.abs() * (length - 1);
    final values = [for (var i = 0; i < length; i++) start + step * i];
    final gap = middleGap ? 1 + r.nextInt(length - 2) : length - 1;
    final answer = values[gap];
    final options = <int>{answer, answer + 1, answer - 1, answer + step}
      ..removeWhere((v) => v < 0);
    final choices = [for (final v in options.take(3)) Token(number: v)];
    return PatternTask.of(
      [
        for (var i = 0; i < length; i++)
          i == gap ? null : Token(number: values[i]),
      ],
      choices,
      unit: step,
    );
  }

  List<PatternTask> mission() {
    final slot = n % kMissionsPerChapter;
    final items = <PatternTask>[];
    final seen = <String>{};
    while (items.length < 5) {
      final numbers =
          slot == 7 || slot == 8 || (slot == 9 && items.length.isOdd);
      final middle = slot == 9 || (c >= 10 && r.nextInt(4) == 0);
      final t = numbers
          ? _numbers(middleGap: middle)
          : _tokens(middleGap: middle);
      if (seen.add(t.cells.toString())) items.add(t);
    }
    return items;
  }
}

// ───────────────────────────── Memory River ─────────────────────────────

MemoryTask _memory(int n) {
  final c = _chapter(n);
  final r = _rng(World.memory, n);
  final pairs = min(8, 3 + c ~/ 10 + (n % 3 == 2 ? 1 : 0));
  final faces = [...memoryFaces]..shuffle(r);
  return MemoryTask(faces.take(pairs).toList(), peekSeconds: c < 5 ? 1 : 0);
}

// ───────────────────────────── Shape Valley ─────────────────────────────

class _ShapeGen {
  _ShapeGen(this.n) : c = _chapter(n), r = _rng(World.shape, n);

  final int n;
  final int c;
  final Random r;

  /// Turns that visibly change each outline (a turned square is still a square).
  static const _turns = {
    TokenShape.circle: [0],
    TokenShape.square: [0],
    TokenShape.diamond: [0],
    TokenShape.triangle: [0, 90, 180, 270],
    TokenShape.star: [0, 36],
    TokenShape.heart: [0, 180],
    TokenShape.hexagon: [0, 30],
    TokenShape.rectangle: [0, 90],
  };

  ShapeTask _board() {
    final count = min(6, 3 + c ~/ 15 + n % 2);
    final keys = <String>{};
    final slots = <Token>[];
    final shapes = [...TokenShape.values]..shuffle(r);
    for (final shape in shapes) {
      if (slots.length >= count) break;
      final turns = c >= 5
          ? _turns[shape]![r.nextInt(_turns[shape]!.length)]
          : 0;
      // From chapter 11, sometimes put a big and a small version of one shape on the board.
      final pair = c >= 10 && slots.length <= count - 2 && r.nextInt(3) == 0;
      final sizes = pair
          ? [TokenSize.small, TokenSize.large]
          : [TokenSize.medium];
      for (final size in sizes) {
        final slot = Token(shape: shape, size: size, turns: turns);
        if (keys.add('$shape$size$turns')) slots.add(slot);
      }
    }
    final colors = [...TokenColor.values]..shuffle(r);
    final pieces = [
      for (var i = 0; i < slots.length; i++)
        Token(
          shape: slots[i].shape,
          size: slots[i].size,
          turns: slots[i].turns,
          color: colors[i % colors.length],
        ),
    ]..shuffle(r);
    slots.shuffle(r);
    return ShapeTask.of(pieces, slots);
  }

  List<ShapeTask> mission() => [_board(), _board()];
}
