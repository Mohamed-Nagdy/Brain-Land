import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/difficulty_calculator.dart';
import '../models/math_level.dart';
import '../services/math_storage_service.dart';

/// Provider for the MathStorageService
final mathStorageServiceProvider = Provider<MathStorageService>((ref) {
  final calculator = DifficultyCalculator();
  return MathStorageService(difficultyCalculator: calculator);
});

/// Provider for fetching all Math Forest levels
final mathLevelsProvider = FutureProvider<List<MathLevel>>((ref) async {
  final storage = ref.watch(mathStorageServiceProvider);
  return storage.getAllLevels();
});
