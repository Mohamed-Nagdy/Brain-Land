enum MathKind {
  /// Count the counters.
  count,

  /// Tap the group with more counters (answer 0 = first group, 1 = second).
  compare,

  /// a + b with counters.
  add,

  /// a − b with the taken-away counters crossed out.
  takeAway,

  /// a + ? = 10 on a ten frame.
  fillTen,

  /// Written sum or difference, no counters.
  equation,

  /// Written a + ? = b.
  missing,
}

enum Counter { acorn, mushroom, berry, leaf }

/// Why a wrong option is tempting, so feedback can name the mistake.
enum MathMistake { offByOne, wrongOperation, other }

class MathTask {
  const MathTask(
    this.kind,
    this.a, [
    this.b = 0,
    this.counter = Counter.acorn,
    this.minus = false,
  ]);

  final MathKind kind;
  final int a;
  final int b;
  final Counter counter;

  /// For [MathKind.equation]: subtraction instead of addition.
  final bool minus;

  int get answer => switch (kind) {
    MathKind.count => a,
    MathKind.compare => a > b ? 0 : 1,
    MathKind.add => a + b,
    MathKind.takeAway => a - b,
    MathKind.fillTen => 10 - a,
    MathKind.equation => minus ? a - b : a + b,
    MathKind.missing => b - a,
  };

  bool get subtracts =>
      kind == MathKind.takeAway || (kind == MathKind.equation && minus);

  /// Answer choices with the typical mistake each one represents.
  /// Deterministic, so every child sees the same curated choices.
  Map<int, MathMistake> get options {
    if (kind == MathKind.compare) {
      return const {0: MathMistake.other, 1: MathMistake.other};
    }
    final result = <int, MathMistake>{answer: MathMistake.other};
    void offer(int value, MathMistake why) {
      if (value >= 0 && !result.containsKey(value)) result[value] = why;
    }

    if (subtracts) offer(a + b, MathMistake.wrongOperation);
    if (kind == MathKind.missing) offer(b, MathMistake.wrongOperation);
    if (kind == MathKind.add || (kind == MathKind.equation && !minus)) {
      offer((a - b).abs(), MathMistake.wrongOperation);
    }
    offer(answer + 1, MathMistake.offByOne);
    offer(answer - 1, MathMistake.offByOne);
    offer(answer + 2, MathMistake.other);
    final wanted = kind == MathKind.count && a <= 5 ? 3 : 4;
    return Map.fromEntries(result.entries.take(wanted));
  }
}

/// Math Forest, chapter 1: counting to 10, comparing, adding and taking away
/// with objects, making ten, then written sums to 20.
const mathChapter = <List<MathTask>>[
  // 1 · Count to 5
  [
    MathTask(MathKind.count, 2),
    MathTask(MathKind.count, 4),
    MathTask(MathKind.count, 1),
    MathTask(MathKind.count, 5),
    MathTask(MathKind.count, 3),
  ],
  // 2 · Count to 10
  [
    MathTask(MathKind.count, 6, 0, Counter.mushroom),
    MathTask(MathKind.count, 8, 0, Counter.mushroom),
    MathTask(MathKind.count, 7, 0, Counter.mushroom),
    MathTask(MathKind.count, 10, 0, Counter.mushroom),
    MathTask(MathKind.count, 9, 0, Counter.mushroom),
  ],
  // 3 · Which has more?
  [
    MathTask(MathKind.compare, 3, 5, Counter.berry),
    MathTask(MathKind.compare, 6, 2, Counter.berry),
    MathTask(MathKind.compare, 4, 7, Counter.berry),
    MathTask(MathKind.compare, 8, 5, Counter.berry),
    MathTask(MathKind.compare, 9, 10, Counter.berry),
  ],
  // 4 · Adding within 5
  [
    MathTask(MathKind.add, 1, 1),
    MathTask(MathKind.add, 2, 1),
    MathTask(MathKind.add, 2, 2),
    MathTask(MathKind.add, 3, 2),
    MathTask(MathKind.add, 1, 4),
  ],
  // 5 · Adding within 10
  [
    MathTask(MathKind.add, 4, 3, Counter.leaf),
    MathTask(MathKind.add, 5, 2, Counter.leaf),
    MathTask(MathKind.add, 3, 6, Counter.leaf),
    MathTask(MathKind.add, 5, 5, Counter.leaf),
    MathTask(MathKind.add, 2, 7, Counter.leaf),
  ],
  // 6 · Taking away within 5
  [
    MathTask(MathKind.takeAway, 3, 1, Counter.berry),
    MathTask(MathKind.takeAway, 4, 2, Counter.berry),
    MathTask(MathKind.takeAway, 5, 1, Counter.berry),
    MathTask(MathKind.takeAway, 5, 3, Counter.berry),
    MathTask(MathKind.takeAway, 3, 3, Counter.berry),
  ],
  // 7 · Taking away within 10
  [
    MathTask(MathKind.takeAway, 7, 2, Counter.mushroom),
    MathTask(MathKind.takeAway, 9, 4, Counter.mushroom),
    MathTask(MathKind.takeAway, 10, 3, Counter.mushroom),
    MathTask(MathKind.takeAway, 8, 5, Counter.mushroom),
    MathTask(MathKind.takeAway, 6, 6, Counter.mushroom),
  ],
  // 8 · Making ten
  [
    MathTask(MathKind.fillTen, 7),
    MathTask(MathKind.fillTen, 5),
    MathTask(MathKind.fillTen, 8),
    MathTask(MathKind.fillTen, 4),
    MathTask(MathKind.fillTen, 9),
  ],
  // 9 · Written sums to 20
  [
    MathTask(MathKind.equation, 8, 5),
    MathTask(MathKind.equation, 9, 6),
    MathTask(MathKind.equation, 7, 7),
    MathTask(MathKind.equation, 12, 4),
    MathTask(MathKind.equation, 6, 9),
  ],
  // 10 · Mixed review to 20
  [
    MathTask(MathKind.equation, 15, 6, Counter.acorn, true),
    MathTask(MathKind.equation, 11, 7),
    MathTask(MathKind.equation, 13, 5, Counter.acorn, true),
    MathTask(MathKind.equation, 18, 9, Counter.acorn, true),
    MathTask(MathKind.equation, 9, 8),
  ],
];
