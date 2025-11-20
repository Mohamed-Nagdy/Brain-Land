import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/models/player_progress.dart';
import '../../../shared/models/zone_progress.dart';
import '../services/progress_storage_service.dart';

part 'progress_provider.g.dart';

/// Provider for ProgressStorageService
@riverpod
ProgressStorageService progressStorageService(ProgressStorageServiceRef ref) {
  return ProgressStorageService();
}

/// Progress state notifier
@riverpod
class ProgressNotifier extends _$ProgressNotifier {
  @override
  Future<PlayerProgress> build() async {
    return await _loadProgress();
  }

  ProgressStorageService get _service =>
      ref.read(progressStorageServiceProvider);

  /// Load progress from storage
  Future<PlayerProgress> _loadProgress() async {
    try {
      return await _service.getProgress();
    } catch (e) {
      log('Failed to load progress: $e');
      rethrow;
    }
  }

  /// Update progress
  Future<void> updateProgress(PlayerProgress progress) async {
    try {
      await _service.updateProgress(progress);
      ref.invalidateSelf();
    } catch (e) {
      log('Failed to update progress: $e');
      rethrow;
    }
  }

  /// Update zone progress
  Future<void> updateZoneProgress(
    String zoneId,
    ZoneProgress zoneProgress,
  ) async {
    try {
      await _service.updateZoneProgress(zoneId, zoneProgress);
      ref.invalidateSelf();
    } catch (e) {
      log('Failed to update zone progress: $e');
      rethrow;
    }
  }

  /// Add stars
  Future<void> addStars(int stars) async {
    try {
      await _service.addStars(stars);
      ref.invalidateSelf();
    } catch (e) {
      log('Failed to add stars: $e');
      rethrow;
    }
  }

  /// Add coins
  Future<void> addCoins(int coins) async {
    try {
      await _service.addCoins(coins);
      ref.invalidateSelf();
    } catch (e) {
      log('Failed to add coins: $e');
      rethrow;
    }
  }

  /// Unlock a pet
  Future<void> unlockPet(String petId) async {
    try {
      await _service.unlockPet(petId);
      ref.invalidateSelf();
    } catch (e) {
      log('Failed to unlock pet: $e');
      rethrow;
    }
  }

  /// Unlock a sticker
  Future<void> unlockSticker(String stickerId) async {
    try {
      await _service.unlockSticker(stickerId);
      ref.invalidateSelf();
    } catch (e) {
      log('Failed to unlock sticker: $e');
      rethrow;
    }
  }

  /// Unlock an avatar item
  Future<void> unlockAvatarItem(String itemId) async {
    try {
      await _service.unlockAvatarItem(itemId);
      ref.invalidateSelf();
    } catch (e) {
      log('Failed to unlock avatar item: $e');
      rethrow;
    }
  }

  /// Add play time
  Future<void> addPlayTime(int seconds) async {
    try {
      await _service.addPlayTime(seconds);
      ref.invalidateSelf();
    } catch (e) {
      log('Failed to add play time: $e');
      rethrow;
    }
  }

  /// Reset progress
  Future<void> resetProgress() async {
    try {
      await _service.resetProgress();
      ref.invalidateSelf();
    } catch (e) {
      log('Failed to reset progress: $e');
      rethrow;
    }
  }

  /// Refresh progress
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

/// Provider for total stars
@riverpod
Future<int> totalStars(TotalStarsRef ref) async {
  final progress = await ref.watch(progressNotifierProvider.future);
  return progress.totalStars;
}

/// Provider for total coins
@riverpod
Future<int> totalCoins(TotalCoinsRef ref) async {
  final progress = await ref.watch(progressNotifierProvider.future);
  return progress.totalCoins;
}

/// Provider for current streak
@riverpod
Future<int> currentStreak(CurrentStreakRef ref) async {
  final progress = await ref.watch(progressNotifierProvider.future);
  return progress.currentStreak;
}

/// Provider for zone progress
@riverpod
Future<ZoneProgress?> zoneProgress(ZoneProgressRef ref, String zoneId) async {
  final progress = await ref.watch(progressNotifierProvider.future);
  return progress.zoneProgress[zoneId];
}

/// Provider for zone completion percentage
@riverpod
Future<double> zoneCompletionPercentage(
  ZoneCompletionPercentageRef ref,
  String zoneId,
  int totalLevels,
) async {
  final progress = await ref.watch(progressNotifierProvider.future);
  final zoneProgress = progress.zoneProgress[zoneId];
  if (zoneProgress == null) return 0.0;
  return (zoneProgress.levelsCompleted / totalLevels * 100);
}

/// Provider for unlocked pets
@riverpod
Future<List<String>> unlockedPets(UnlockedPetsRef ref) async {
  final progress = await ref.watch(progressNotifierProvider.future);
  return progress.unlockedPets;
}

/// Provider for unlocked stickers
@riverpod
Future<List<String>> unlockedStickers(UnlockedStickersRef ref) async {
  final progress = await ref.watch(progressNotifierProvider.future);
  return progress.unlockedStickers;
}

/// Provider for unlocked avatar items
@riverpod
Future<List<String>> unlockedAvatarItems(UnlockedAvatarItemsRef ref) async {
  final progress = await ref.watch(progressNotifierProvider.future);
  return progress.unlockedAvatarItems;
}

/// Provider for total play time (formatted)
@riverpod
Future<String> formattedPlayTime(FormattedPlayTimeRef ref) async {
  final progress = await ref.watch(progressNotifierProvider.future);
  final seconds = progress.totalPlayTime;
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  return '${hours}h ${minutes}m';
}
