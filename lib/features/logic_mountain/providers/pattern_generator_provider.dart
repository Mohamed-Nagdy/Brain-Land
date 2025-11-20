import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/pattern_generator.dart';

/// Provider for the PatternGenerator
final patternGeneratorProvider = Provider<PatternGenerator>((ref) {
  return PatternGenerator();
});
