import 'package:flutter/widgets.dart';

import '../core/theme.dart';
import '../l10n/app_localizations.dart';

enum World {
  math(Palette.math, 'math'),
  logic(Palette.logic, 'logic'),
  memory(Palette.memory, 'memory'),
  shape(Palette.shape, 'shape');

  const World(this.color, this.slug);

  final Color color;
  final String slug;

  String get scene => 'assets/svg/worlds/world_$slug.svg';
  String get trophy => 'assets/svg/rewards/trophy_$slug.svg';

  String title(AppLocalizations l) => switch (this) {
    World.math => l.worldMath,
    World.logic => l.worldLogic,
    World.memory => l.worldMemory,
    World.shape => l.worldShape,
  };

  static World fromSlug(String slug) =>
      World.values.firstWhere((w) => w.slug == slug);
}

/// Each world has [kChapters] chapters of [kMissionsPerChapter] missions.
/// Chapter 1 is hand-written; later chapters come from tested generators.
const int kMissionsPerChapter = 10;
const int kChapters = 1000;
const int kMissionsPerWorld = kMissionsPerChapter * kChapters;
