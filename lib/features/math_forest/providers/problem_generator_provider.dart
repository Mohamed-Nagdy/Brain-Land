import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/difficulty_calculator.dart';
import '../services/problem_generator.dart';

/// Provider for the DifficultyCalculator
final difficultyCalculatorProvider = Provider<DifficultyCalculator>((ref) {
  return DifficultyCalculator();
});

/// Provider for the ProblemGenerator
final problemGeneratorProvider = Provider<ProblemGenerator>((ref) {
  final calculator = ref.watch(difficultyCalculatorProvider);
  return ProblemGenerator(difficultyCalculator: calculator);
});
