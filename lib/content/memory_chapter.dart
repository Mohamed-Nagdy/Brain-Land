/// Memory River card faces, one SVG each in `assets/svg/memory/`.
const memoryFaces = [
  'owl',
  'fish',
  'turtle',
  'fox',
  'bee',
  'snail',
  'frog',
  'rabbit',
  'crab',
  'butterfly',
  'hedgehog',
  'whale',
];

class MemoryTask {
  const MemoryTask(this.faces, {this.peekSeconds = 0});

  /// One entry per pair.
  final List<String> faces;

  /// Cards start face-up for this long so younger players can learn the board.
  final int peekSeconds;

  int get pairs => faces.length;

  /// Mismatches that still earn three stars (some are unavoidable).
  int get mistakeAllowance => pairs;
}

/// Memory River, chapter 1: from 2 to 6 pairs; early boards start with a peek.
const memoryChapter = <List<MemoryTask>>[
  [
    MemoryTask(['owl', 'fish'], peekSeconds: 3),
  ],
  [
    MemoryTask(['turtle', 'fox', 'bee'], peekSeconds: 3),
  ],
  [
    MemoryTask(['snail', 'frog', 'rabbit'], peekSeconds: 2),
  ],
  [
    MemoryTask(['crab', 'butterfly', 'hedgehog', 'whale'], peekSeconds: 2),
  ],
  [
    MemoryTask(['owl', 'turtle', 'bee', 'frog'], peekSeconds: 2),
  ],
  [
    MemoryTask(['fish', 'fox', 'snail', 'rabbit', 'crab']),
  ],
  [
    MemoryTask(['butterfly', 'hedgehog', 'whale', 'owl', 'bee']),
  ],
  [
    MemoryTask(['turtle', 'frog', 'crab', 'fox', 'fish', 'snail']),
  ],
  [
    MemoryTask(['rabbit', 'whale', 'owl', 'hedgehog', 'butterfly', 'frog']),
  ],
  [
    MemoryTask(['bee', 'crab', 'fox', 'turtle', 'whale', 'rabbit']),
  ],
];
