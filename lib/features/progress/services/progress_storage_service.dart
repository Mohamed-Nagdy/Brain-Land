import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../shared/models/player_progress.dart';
import '../../../shared/models/zone_progress.dart';
import '../../../shared/services/storage_service.dart';

/// Service for managing player progress storage
class ProgressStorageService {
  final StorageService _storageService;

  ProgressStorageService({StorageService? storageService})
    : _storageService = storageService ?? StorageService.instance;

  static const String _progressKey = 'player_progress';

  /// Get the current player progress
  /// Returns a default progress if none exists
  Future<PlayerProgress> getProgress() async {
    try {
      final progress = _storageService.load<PlayerProgress>(
        boxName: AppConstants.progressBoxName,
        key: _progressKey,
      );

      if (progress == null) {
        // Return default progress for new players
        return _createDefaultProgress();
      }

      return progress;
    } catch (e, stackTrace) {
      throw StorageException(
        message: 'Failed to load player progress: $e',
        severity: ErrorSeverity.medium,
        stackTrace: stackTrace,
      );
    }
  }

  /// Update player progress
  Future<void> updateProgress(PlayerProgress progress) async {
    try {
      final updatedProgress = progress.copyWith(updatedAt: DateTime.now());

      await _storageService.save(
        boxName: AppConstants.progressBoxName,
        key: _progressKey,
        value: updatedProgress,
      );
    } catch (e, stackTrace) {
      throw StorageException(
        message: 'Failed to update player progress: $e',
        severity: ErrorSeverity.high,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get total stars earned across all zones
  Future<int> getTotalStars() async {
    final progress = await getProgress();
    return progress.totalStars;
  }

  /// Get zone completions map
  Future<Map<String, int>> getZoneCompletions() async {
    final progress = await getProgress();
    return progress.zoneProgress.map(
      (zoneId, zoneProgress) => MapEntry(zoneId, zoneProgress.levelsCompleted),
    );
  }

  /// Get current streak
  Future<int> getCurrentStreak() async {
    final progress = await getProgress();
    return progress.currentStreak;
  }

  /// Update zone progress
  Future<void> updateZoneProgress(
    String zoneId,
    ZoneProgress zoneProgress,
  ) async {
    final progress = await getProgress();
    final updatedZoneProgress = Map<String, ZoneProgress>.from(
      progress.zoneProgress,
    );
    updatedZoneProgress[zoneId] = zoneProgress;

    // Recalculate total stars
    final totalStars = updatedZoneProgress.values.fold<int>(
      0,
      (sum, zone) => sum + zone.totalStars,
    );

    await updateProgress(
      progress.copyWith(
        zoneProgress: updatedZoneProgress,
        totalStars: totalStars,
      ),
    );
  }

  /// Add stars to total
  Future<void> addStars(int stars) async {
    final progress = await getProgress();
    await updateProgress(
      progress.copyWith(totalStars: progress.totalStars + stars),
    );
  }

  /// Add coins to total
  Future<void> addCoins(int coins) async {
    final progress = await getProgress();
    await updateProgress(
      progress.copyWith(totalCoins: progress.totalCoins + coins),
    );
  }

  /// Unlock a pet
  Future<void> unlockPet(String petId) async {
    final progress = await getProgress();
    if (!progress.unlockedPets.contains(petId)) {
      final updatedPets = List<String>.from(progress.unlockedPets)..add(petId);
      await updateProgress(progress.copyWith(unlockedPets: updatedPets));
    }
  }

  /// Unlock a sticker
  Future<void> unlockSticker(String stickerId) async {
    final progress = await getProgress();
    if (!progress.unlockedStickers.contains(stickerId)) {
      final updatedStickers = List<String>.from(progress.unlockedStickers)
        ..add(stickerId);
      await updateProgress(
        progress.copyWith(unlockedStickers: updatedStickers),
      );
    }
  }

  /// Unlock an avatar item
  Future<void> unlockAvatarItem(String itemId) async {
    final progress = await getProgress();
    if (!progress.unlockedAvatarItems.contains(itemId)) {
      final updatedItems = List<String>.from(progress.unlockedAvatarItems)
        ..add(itemId);
      await updateProgress(
        progress.copyWith(unlockedAvatarItems: updatedItems),
      );
    }
  }

  /// Update streak based on login
  /// Returns true if streak was incremented, false if reset or same day
  Future<bool> updateStreak() async {
    final progress = await getProgress();
    final now = DateTime.now();
    final lastLogin = progress.lastLoginDate;

    // Calculate days difference
    final daysDifference = _daysBetween(lastLogin, now);

    int newStreak;
    bool wasIncremented = false;

    // Special case: if streak is 0, this is the first login
    if (progress.currentStreak == 0) {
      newStreak = 1;
      wasIncremented = false; // First login, not an increment
    } else if (daysDifference == 0) {
      // Same day login, no change
      return false;
    } else if (daysDifference == 1) {
      // Consecutive day, increment streak
      newStreak = progress.currentStreak + 1;
      wasIncremented = true;
    } else {
      // Missed days, reset streak
      newStreak = 1;
      wasIncremented = false;
    }

    await updateProgress(
      progress.copyWith(currentStreak: newStreak, lastLoginDate: now),
    );

    return wasIncremented;
  }

  /// Add play time in seconds
  Future<void> addPlayTime(int seconds) async {
    final progress = await getProgress();
    await updateProgress(
      progress.copyWith(totalPlayTime: progress.totalPlayTime + seconds),
    );
  }

  /// Reset all progress (for testing or user request)
  Future<void> resetProgress() async {
    await updateProgress(_createDefaultProgress());
  }

  /// Create default progress for new players
  PlayerProgress _createDefaultProgress() {
    final now = DateTime.now();
    return PlayerProgress(
      playerId: 'player_${now.millisecondsSinceEpoch}',
      totalStars: 0,
      totalCoins: 0,
      zoneProgress: {},
      unlockedPets: [],
      unlockedStickers: [],
      unlockedAvatarItems: [],
      currentStreak: 0,
      lastLoginDate: now,
      totalPlayTime: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Calculate days between two dates (ignoring time)
  int _daysBetween(DateTime from, DateTime to) {
    final fromDate = DateTime(from.year, from.month, from.day);
    final toDate = DateTime(to.year, to.month, to.day);
    return toDate.difference(fromDate).inDays;
  }
}
