import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/models/player_progress.dart';
import '../../../shared/models/zone_progress.dart';
import '../services/debug_progress_helper.dart';
import '../services/progress_storage_service.dart';

part 'progress_provider.g.dart';

/// Provider for ProgressStorageService
@Riverpod(keepAlive: true)
ProgressStorageService progressStorageService(Ref ref) {
  return ProgressStorageService();
}

/// Provider for DebugProgressHelper (only in debug mode)
@Riverpod(keepAlive: true)
DebugProgressHelper? debugProgressHelper(Ref ref) {
  final helper = DebugProgressHelper(ref.read(progressStorageServiceProvider));
  return helper.isDebugMode ? helper : null;
}

/// Progress state notifier
@Riverpod(keepAlive: true)
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

  /// Increment consecutive levels completed
  /// Returns the new count
  Future<int> incrementConsecutiveLevels() async {
    try {
      final newCount = await _service.incrementConsecutiveLevels();
      ref.invalidateSelf();
      return newCount;
    } catch (e) {
      log('Failed to increment consecutive levels: $e');
      rethrow;
    }
  }

  /// Reset consecutive levels completed
  Future<void> resetConsecutiveLevels() async {
    try {
      await _service.resetConsecutiveLevels();
      ref.invalidateSelf();
    } catch (e) {
      log('Failed to reset consecutive levels: $e');
      rethrow;
    }
  }

  /// Refresh progress
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

/// Provider for total stars
@Riverpod(keepAlive: true)
Future<int> totalStars(Ref ref) async {
  final progress = await ref.watch(progressNotifierProvider.future);
  return progress.totalStars;
}

/// Provider for total coins
@Riverpod(keepAlive: true)
Future<int> totalCoins(Ref ref) async {
  final progress = await ref.watch(progressNotifierProvider.future);
  return progress.totalCoins;
}

/// Provider for current streak
@Riverpod(keepAlive: true)
Future<int> currentStreak(Ref ref) async {
  final progress = await ref.watch(progressNotifierProvider.future);
  return progress.currentStreak;
}

/// Provider for zone progress
@Riverpod(keepAlive: true)
Future<ZoneProgress?> zoneProgress(Ref ref, String zoneId) async {
  final progress = await ref.watch(progressNotifierProvider.future);
  return progress.zoneProgress[zoneId];
}

/// Provider for zone completion percentage
@Riverpod(keepAlive: true)
Future<double> zoneCompletionPercentage(
  Ref ref,
  String zoneId,
  int totalLevels,
) async {
  final progress = await ref.watch(progressNotifierProvider.future);
  final zoneProgress = progress.zoneProgress[zoneId];
  if (zoneProgress == null) return 0.0;
  return (zoneProgress.levelsCompleted / totalLevels * 100);
}

/// Provider for unlocked pets
@Riverpod(keepAlive: true)
Future<List<String>> unlockedPets(Ref ref) async {
  final progress = await ref.watch(progressNotifierProvider.future);
  return progress.unlockedPets;
}

/// Provider for unlocked stickers
@Riverpod(keepAlive: true)
Future<List<String>> unlockedStickers(Ref ref) async {
  final progress = await ref.watch(progressNotifierProvider.future);
  return progress.unlockedStickers;
}

/// Provider for unlocked avatar items
@Riverpod(keepAlive: true)
Future<List<String>> unlockedAvatarItems(Ref ref) async {
  final progress = await ref.watch(progressNotifierProvider.future);
  return progress.unlockedAvatarItems;
}

/// Provider for total play time (formatted)
@Riverpod(keepAlive: true)
Future<String> formattedPlayTime(Ref ref) async {
  final progress = await ref.watch(progressNotifierProvider.future);
  final seconds = progress.totalPlayTime;
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  return '${hours}h ${minutes}m';
}
