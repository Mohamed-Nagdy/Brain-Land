import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/reward_generator.dart';

/// Provider for the reward generator service
final rewardGeneratorProvider = Provider<RewardGenerator>((ref) {
  return RewardGenerator();
});
