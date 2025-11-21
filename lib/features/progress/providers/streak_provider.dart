import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  /// Check if user should receive a special 30-day reward
  Future<bool> shouldReceiveMonthlyReward() async {
    final streak = await future;
    return streak == 30;
  }

  /// Refresh streak
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

/// Provider for daily rewards (30-day cycle)
@Riverpod(keepAlive: true)
List<DailyReward> dailyRewards(Ref ref) {
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
      name: 'Day 2 Bonus',
      description: 'Keep it up!',
      iconPath: 'assets/icons/coin.png',
      coinValue: 15,
      day: 2,
    ),
    const DailyReward(
      id: 'day_3',
      name: 'Day 3 Reward',
      description: 'You\'re on fire!',
      iconPath: 'assets/icons/coin.png',
      coinValue: 20,
      day: 3,
    ),
    const DailyReward(
      id: 'day_4',
      name: 'Day 4 Bonus',
      description: 'Amazing streak!',
      iconPath: 'assets/icons/coin.png',
      coinValue: 25,
      day: 4,
    ),
    const DailyReward(
      id: 'day_5',
      name: 'Day 5 Reward',
      description: 'Almost a week!',
      iconPath: 'assets/icons/coin.png',
      coinValue: 30,
      day: 5,
    ),
    const DailyReward(
      id: 'day_6',
      name: 'Day 6 Bonus',
      description: 'One more day!',
      iconPath: 'assets/icons/coin.png',
      coinValue: 35,
      day: 6,
    ),
    const DailyReward(
      id: 'day_7',
      name: 'Weekly Bonus',
      description: 'First week complete!',
      iconPath: 'assets/icons/special_box.png',
      coinValue: 50,
      day: 7,
    ),
    const DailyReward(
      id: 'day_8',
      name: 'Day 8 Reward',
      description: 'Second week begins!',
      iconPath: 'assets/icons/coin.png',
      coinValue: 40,
      day: 8,
    ),
    const DailyReward(
      id: 'day_9',
      name: 'Day 9 Bonus',
      description: 'Keep going strong!',
      iconPath: 'assets/icons/coin.png',
      coinValue: 45,
      day: 9,
    ),
    const DailyReward(
      id: 'day_10',
      name: 'Day 10 Reward',
      description: 'Double digits!',
      iconPath: 'assets/icons/coin.png',
      coinValue: 50,
      day: 10,
    ),
    const DailyReward(
      id: 'day_11',
      name: 'Day 11 Bonus',
      description: 'Unstoppable!',
      iconPath: 'assets/icons/coin.png',
      coinValue: 55,
      day: 11,
    ),
    const DailyReward(
      id: 'day_12',
      name: 'Day 12 Reward',
      description: 'Incredible streak!',
      iconPath: 'assets/icons/coin.png',
      coinValue: 60,
      day: 12,
    ),
    const DailyReward(
      id: 'day_13',
      name: 'Day 13 Bonus',
      description: 'Lucky day!',
      iconPath: 'assets/icons/coin.png',
      coinValue: 65,
      day: 13,
    ),
    const DailyReward(
      id: 'day_14',
      name: 'Two Week Bonus',
      description: 'Two weeks strong!',
      iconPath: 'assets/icons/special_box.png',
      coinValue: 75,
      day: 14,
    ),
    const DailyReward(
      id: 'day_15',
      name: 'Day 15 Reward',
      description: 'Halfway there!',
      iconPath: 'assets/icons/coin.png',
      coinValue: 70,
      day: 15,
    ),
    const DailyReward(
      id: 'day_16',
      name: 'Day 16 Bonus',
      description: 'Amazing dedication!',
      iconPath: 'assets/icons/coin.png',
      coinValue: 75,
      day: 16,
    ),
    const DailyReward(
      id: 'day_17',
      name: 'Day 17 Reward',
      description: 'Keep it up!',
      iconPath: 'assets/icons/coin.png',
      coinValue: 80,
      day: 17,
    ),
    const DailyReward(
      id: 'day_18',
      name: 'Day 18 Bonus',
      description: 'You\'re a champion!',
      iconPath: 'assets/icons/coin.png',
      coinValue: 85,
      day: 18,
    ),
    const DailyReward(
      id: 'day_19',
      name: 'Day 19 Reward',
      description: 'Almost three weeks!',
      iconPath: 'assets/icons/coin.png',
      coinValue: 90,
      day: 19,
    ),
    const DailyReward(
      id: 'day_20',
      name: 'Day 20 Bonus',
      description: 'Twenty days strong!',
      iconPath: 'assets/icons/coin.png',
      coinValue: 95,
      day: 20,
    ),
    const DailyReward(
      id: 'day_21',
      name: 'Three Week Bonus',
      description: 'Three weeks complete!',
      iconPath: 'assets/icons/special_box.png',
      coinValue: 100,
      day: 21,
    ),
    const DailyReward(
      id: 'day_22',
      name: 'Day 22 Reward',
      description: 'Final week begins!',
      iconPath: 'assets/icons/coin.png',
      coinValue: 100,
      day: 22,
    ),
    const DailyReward(
      id: 'day_23',
      name: 'Day 23 Bonus',
      description: 'So close!',
      iconPath: 'assets/icons/coin.png',
      coinValue: 105,
      day: 23,
    ),
    const DailyReward(
      id: 'day_24',
      name: 'Day 24 Reward',
      description: 'Almost there!',
      iconPath: 'assets/icons/coin.png',
      coinValue: 110,
      day: 24,
    ),
    const DailyReward(
      id: 'day_25',
      name: 'Day 25 Bonus',
      description: 'Five more days!',
      iconPath: 'assets/icons/coin.png',
      coinValue: 115,
      day: 25,
    ),
    const DailyReward(
      id: 'day_26',
      name: 'Day 26 Reward',
      description: 'You\'re amazing!',
      iconPath: 'assets/icons/coin.png',
      coinValue: 120,
      day: 26,
    ),
    const DailyReward(
      id: 'day_27',
      name: 'Day 27 Bonus',
      description: 'Three more days!',
      iconPath: 'assets/icons/coin.png',
      coinValue: 125,
      day: 27,
    ),
    const DailyReward(
      id: 'day_28',
      name: 'Day 28 Reward',
      description: 'Almost a month!',
      iconPath: 'assets/icons/coin.png',
      coinValue: 130,
      day: 28,
    ),
    const DailyReward(
      id: 'day_29',
      name: 'Day 29 Bonus',
      description: 'One more day!',
      iconPath: 'assets/icons/coin.png',
      coinValue: 140,
      day: 29,
    ),
    const DailyReward(
      id: 'day_30',
      name: 'Monthly Champion',
      description: 'You did it! Ultimate reward!',
      iconPath: 'assets/icons/special_box.png',
      coinValue: 200,
      day: 30,
    ),
  ];
}

/// Provider for today's reward based on current streak
@Riverpod(keepAlive: true)
Future<DailyReward?> todaysReward(Ref ref) async {
  final streak = await ref.watch(streakNotifierProvider.future);
  final rewards = ref.watch(dailyRewardsProvider);

  if (streak == 0) return null;

  // Get reward for current day (1-30 cycle)
  final dayIndex = ((streak - 1) % 30);
  return rewards[dayIndex];
}

/// Provider to check if user has logged in today
@Riverpod(keepAlive: true)
Future<bool> hasLoggedInToday(Ref ref) async {
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
@Riverpod(keepAlive: true)
Future<List<DateTime>> streakCalendar(Ref ref) async {
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
@Riverpod(keepAlive: true)
Future<bool> isDateInStreak(Ref ref, DateTime date) async {
  final calendar = await ref.watch(streakCalendarProvider.future);
  final checkDate = DateTime(date.year, date.month, date.day);
  return calendar.any((d) => d == checkDate);
}
