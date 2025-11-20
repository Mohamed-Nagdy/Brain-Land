import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/progress_storage_service.dart';
import 'progress_provider.dart';

part 'streak_provider.g.dart';

/// Daily reward model
class DailyReward {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final int coinValue;
  final int day; // Day in the streak (1-7)

  const DailyReward({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.coinValue,
    required this.day,
  });
}

/// Streak state notifier
@riverpod
class StreakNotifier extends _$StreakNotifier {
  @override
  Future<int> build() async {
    return await _loadStreak();
  }

  ProgressStorageService get _service =>
      ref.read(progressStorageServiceProvider);

  /// Load current streak
  Future<int> _loadStreak() async {
    try {
      return await _service.getCurrentStreak();
    } catch (e) {
      log('Failed to load streak: $e');
      return 0;
    }
  }

  /// Update streak based on login
  /// Returns true if streak was incremented, false if reset or same day
  Future<bool> updateStreak() async {
    try {
      final wasIncremented = await _service.updateStreak();
      ref.invalidateSelf();
      // Also invalidate progress provider to refresh all data
      ref.invalidate(progressNotifierProvider);
      return wasIncremented;
    } catch (e) {
      log('Failed to update streak: $e');
      rethrow;
    }
  }

  /// Check if user should receive a special 7-day reward
  Future<bool> shouldReceiveWeeklyReward() async {
    final streak = await future;
    return streak == 7;
  }

  /// Refresh streak
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

/// Provider for daily rewards (7-day cycle)
@riverpod
List<DailyReward> dailyRewards(DailyRewardsRef ref) {
  return [
    const DailyReward(
      id: 'day_1',
      name: 'Welcome Coins',
      description: 'Start your journey!',
      iconPath: 'assets/icons/coin.png',
      coinValue: 10,
      day: 1,
    ),
    const DailyReward(
      id: 'day_2',
      name: 'Double Coins',
      description: 'Keep it up!',
      iconPath: 'assets/icons/coin.png',
      coinValue: 20,
      day: 2,
    ),
    const DailyReward(
      id: 'day_3',
      name: 'Triple Coins',
      description: 'You\'re on fire!',
      iconPath: 'assets/icons/coin.png',
      coinValue: 30,
      day: 3,
    ),
    const DailyReward(
      id: 'day_4',
      name: 'Bonus Coins',
      description: 'Amazing streak!',
      iconPath: 'assets/icons/coin.png',
      coinValue: 40,
      day: 4,
    ),
    const DailyReward(
      id: 'day_5',
      name: 'Super Coins',
      description: 'Almost there!',
      iconPath: 'assets/icons/coin.png',
      coinValue: 50,
      day: 5,
    ),
    const DailyReward(
      id: 'day_6',
      name: 'Mega Coins',
      description: 'One more day!',
      iconPath: 'assets/icons/coin.png',
      coinValue: 60,
      day: 6,
    ),
    const DailyReward(
      id: 'day_7',
      name: 'Weekly Surprise Box',
      description: 'You did it! Special reward!',
      iconPath: 'assets/icons/special_box.png',
      coinValue: 100,
      day: 7,
    ),
  ];
}

/// Provider for today's reward based on current streak
@riverpod
Future<DailyReward?> todaysReward(TodaysRewardRef ref) async {
  final streak = await ref.watch(streakNotifierProvider.future);
  final rewards = ref.watch(dailyRewardsProvider);

  if (streak == 0) return null;

  // Get reward for current day (1-7 cycle)
  final dayIndex = ((streak - 1) % 7);
  return rewards[dayIndex];
}

/// Provider to check if user has logged in today
@riverpod
Future<bool> hasLoggedInToday(HasLoggedInTodayRef ref) async {
  final progress = await ref.watch(progressNotifierProvider.future);
  final now = DateTime.now();
  final lastLogin = progress.lastLoginDate;

  final nowDate = DateTime(now.year, now.month, now.day);
  final lastLoginDate = DateTime(
    lastLogin.year,
    lastLogin.month,
    lastLogin.day,
  );

  return nowDate == lastLoginDate;
}

/// Provider for streak calendar (last 7 days)
@riverpod
Future<List<DateTime>> streakCalendar(StreakCalendarRef ref) async {
  final progress = await ref.watch(progressNotifierProvider.future);
  final streak = progress.currentStreak;
  final lastLogin = progress.lastLoginDate;

  final calendar = <DateTime>[];
  for (int i = streak - 1; i >= 0 && i < 7; i--) {
    final date = lastLogin.subtract(Duration(days: i));
    calendar.add(DateTime(date.year, date.month, date.day));
  }

  return calendar;
}

/// Provider to check if a specific date is in the streak
@riverpod
Future<bool> isDateInStreak(IsDateInStreakRef ref, DateTime date) async {
  final calendar = await ref.watch(streakCalendarProvider.future);
  final checkDate = DateTime(date.year, date.month, date.day);
  return calendar.any((d) => d == checkDate);
}
