import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/math_level.dart';
import 'math_storage_provider.dart';

/// Provider for getting all Math Forest levels
final mathLevelsProvider = FutureProvider<List<MathLevel>>((ref) async {
  final storage = ref.watch(mathStorageServiceProvider);
  return storage.getAllLevels();
});

/// Provider for getting a specific level by ID
final mathLevelProvider = FutureProvider.family<MathLevel?, String>((
  ref,
  levelId,
) async {
  final storage = ref.watch(mathStorageServiceProvider);
  return storage.getLevel(levelId);
});

/// Provider for getting a level by level number
final mathLevelByNumberProvider = FutureProvider.family<MathLevel?, int>((
  ref,
  levelNumber,
) async {
  final storage = ref.watch(mathStorageServiceProvider);
  return storage.getLevelByNumber(levelNumber);
});

/// Provider for getting total stars earned in Math Forest
final mathTotalStarsProvider = FutureProvider<int>((ref) async {
  final storage = ref.watch(mathStorageServiceProvider);
  return storage.getTotalStars();
});

/// Provider for getting number of completed levels
final mathCompletedLevelsProvider = FutureProvider<int>((ref) async {
  final storage = ref.watch(mathStorageServiceProvider);
  return storage.getCompletedLevelsCount();
});

/// Provider for Math Forest progress percentage
final mathProgressPercentageProvider = FutureProvider<double>((ref) async {
  final storage = ref.watch(mathStorageServiceProvider);
  final completedCount = await storage.getCompletedLevelsCount();
  final levels = await storage.getAllLevels();

  if (levels.isEmpty) return 0.0;
  return (completedCount / levels.length) * 100;
});
