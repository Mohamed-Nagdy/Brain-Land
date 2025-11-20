import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/difficulty_calculator.dart';
import '../models/math_level.dart';
import '../services/math_storage_service.dart';

/// Provider for the MathStorageService
final mathStorageServiceProvider = Provider<MathStorageService>((ref) {
  final calculator = DifficultyCalculator();
  final service = MathStorageService(difficultyCalculator: calculator);

  // Initialize the service
  service.init();

  // Clean up when provider is disposed
  ref.onDispose(() {
    service.close();
  });

  return service;
});

/// Provider for fetching all Math Forest levels
final mathLevelsProvider = FutureProvider<List<MathLevel>>((ref) async {
  final storage = ref.watch(mathStorageServiceProvider);
  return storage.getAllLevels();
});
