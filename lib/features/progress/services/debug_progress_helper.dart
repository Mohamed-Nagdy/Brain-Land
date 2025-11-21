import '../../../shared/models/player_progress.dart';
import '../../../shared/models/zone_progress.dart';
import 'progress_storage_service.dart';

/// Debug helper for populating test data
/// Only available in debug mode
class DebugProgressHelper {
  final ProgressStorageService _service;

  DebugProgressHelper(this._service);

  /// Check if running in debug mode
  bool get isDebugMode =>
      const bool.fromEnvironment('dart.vm.product') == false;

  /// Populate sample progress data
  Future<void> populateSampleData() async {
    if (!isDebugMode) return;

    final now = DateTime.now();
    final sampleProgress = PlayerProgress(
      playerId: 'debug_player_${now.millisecondsSinceEpoch}',
      totalStars: 250,
      totalCoins: 600,
      zoneProgress: {
        'forest': ZoneProgress(
          zoneId: 'forest',
          levelsCompleted: 10,
          totalStars: 90,
          bestAccuracy: 98,
          lastPlayedAt: now.subtract(const Duration(hours: 1)),
        ),
        'mountain': ZoneProgress(
          zoneId: 'mountain',
          levelsCompleted: 8,
          totalStars: 72,
          bestAccuracy: 95,
          lastPlayedAt: now.subtract(const Duration(hours: 3)),
        ),
        'river': ZoneProgress(
          zoneId: 'river',
          levelsCompleted: 6,
          totalStars: 54,
          bestAccuracy: 93,
          lastPlayedAt: now.subtract(const Duration(hours: 6)),
        ),
        'desert': ZoneProgress(
          zoneId: 'desert',
          levelsCompleted: 4,
          totalStars: 34,
          bestAccuracy: 88,
          lastPlayedAt: now.subtract(const Duration(days: 1)),
        ),
        'shape_valley': ZoneProgress(
          zoneId: 'shape_valley',
          levelsCompleted: 2,
          totalStars: 18,
          bestAccuracy: 82,
          lastPlayedAt: now.subtract(const Duration(days: 2)),
        ),
      },
      unlockedPets: [
        'pet_dog',
        'pet_cat',
        'pet_bird',
        'pet_rabbit',
        'pet_hamster',
      ],
      unlockedStickers: [
        'sticker_star',
        'sticker_heart',
        'sticker_smile',
        'sticker_trophy',
        'sticker_rainbow',
        'sticker_fire',
        'sticker_diamond',
      ],
      unlockedAvatarItems: [
        'hat_wizard',
        'hat_crown',
        'glasses_cool',
        'glasses_star',
        'shirt_hero',
        'shirt_rainbow',
        'shoes_sneakers',
        'shoes_boots',
      ],
      currentStreak: 6,
      lastLoginDate: now,
      totalPlayTime: 5400, // 1.5 hours
      createdAt: now.subtract(const Duration(days: 6)),
      updatedAt: now,
    );

    await _service.updateProgress(sampleProgress);
  }

  /// Populate minimal data (for testing empty states)
  Future<void> populateMinimalData() async {
    if (!isDebugMode) return;

    final now = DateTime.now();
    final minimalProgress = PlayerProgress(
      playerId: 'minimal_player_${now.millisecondsSinceEpoch}',
      totalStars: 15,
      totalCoins: 50,
      zoneProgress: {
        'forest': ZoneProgress(
          zoneId: 'forest',
          levelsCompleted: 2,
          totalStars: 15,
          bestAccuracy: 85,
          lastPlayedAt: now.subtract(const Duration(hours: 2)),
        ),
      },
      unlockedPets: ['pet_dog'],
      unlockedStickers: ['sticker_star'],
      unlockedAvatarItems: [],
      currentStreak: 1,
      lastLoginDate: now,
      totalPlayTime: 300, // 5 minutes
      createdAt: now.subtract(const Duration(days: 1)),
      updatedAt: now,
    );

    await _service.updateProgress(minimalProgress);
  }

  /// Reset to empty progress
  Future<void> resetToEmpty() async {
    if (!isDebugMode) return;
    await _service.resetProgress();
  }

  /// Add quick test rewards
  Future<void> addTestRewards() async {
    if (!isDebugMode) return;
    await _service.addStars(100);
    await _service.addCoins(200);
  }

  /// Add test coins
  Future<void> addTestCoins(int amount) async {
    if (!isDebugMode) return;
    await _service.addCoins(amount);
  }

  /// Add test stars
  Future<void> addTestStars(int amount) async {
    if (!isDebugMode) return;
    await _service.addStars(amount);
  }

  /// Set streak to specific value
  Future<void> setStreak(int streak) async {
    if (!isDebugMode) return;

    final progress = await _service.getProgress();
    final now = DateTime.now();

    await _service.updateProgress(
      progress.copyWith(currentStreak: streak, lastLoginDate: now),
    );
  }

  /// Unlock all test items
  Future<void> unlockAllTestItems() async {
    if (!isDebugMode) return;

    // Unlock pets
    for (var i = 1; i <= 5; i++) {
      await _service.unlockPet('pet_$i');
    }

    // Unlock stickers
    for (var i = 1; i <= 10; i++) {
      await _service.unlockSticker('sticker_$i');
    }

    // Unlock avatar items
    for (var i = 1; i <= 8; i++) {
      await _service.unlockAvatarItem('avatar_item_$i');
    }
  }
}
