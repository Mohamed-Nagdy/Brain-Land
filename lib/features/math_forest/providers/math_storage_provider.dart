import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/difficulty_calculator.dart';
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
