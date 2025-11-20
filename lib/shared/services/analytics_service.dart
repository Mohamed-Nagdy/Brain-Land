import 'package:firebase_analytics/firebase_analytics.dart';

/// Service for Firebase Analytics tracking
class AnalyticsService {
  static AnalyticsService? _instance;
  static AnalyticsService get instance => _instance ??= AnalyticsService._();

  AnalyticsService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Log a custom event
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (e) {
      // Silent failure for analytics - in production, use proper logging
      // ignore: avoid_print
      print('Analytics error: $e');
    }
  }

  /// Log level start event
  Future<void> logLevelStart({
    required String zoneId,
    required String levelId,
    required int difficulty,
  }) async {
    await logEvent(
      name: 'level_start',
      parameters: {
        'zone_id': zoneId,
        'level_id': levelId,
        'difficulty': difficulty,
      },
    );
  }

  /// Log level completion event
  Future<void> logLevelComplete({
    required String zoneId,
    required String levelId,
    required int stars,
    required double accuracy,
    required int timeTaken,
  }) async {
    await logEvent(
      name: 'level_complete',
      parameters: {
        'zone_id': zoneId,
        'level_id': levelId,
        'stars': stars,
        'accuracy': accuracy,
        'time_taken': timeTaken,
      },
    );
  }

  /// Log reward opening event
  Future<void> logRewardOpened({
    required String rewardType,
    required String rewardId,
  }) async {
    await logEvent(
      name: 'reward_opened',
      parameters: {'reward_type': rewardType, 'reward_id': rewardId},
    );
  }

  /// Log avatar customization event
  Future<void> logAvatarCustomization({
    required String itemType,
    required String itemId,
  }) async {
    await logEvent(
      name: 'avatar_customization',
      parameters: {'item_type': itemType, 'item_id': itemId},
    );
  }

  /// Log daily login event
  Future<void> logDailyLogin({required int streakCount}) async {
    await logEvent(
      name: 'daily_login',
      parameters: {'streak_count': streakCount},
    );
  }

  /// Set user properties
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (e) {
      // ignore: avoid_print
      print('Analytics error: $e');
    }
  }

  /// Set current screen
  Future<void> setCurrentScreen({required String screenName}) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
    } catch (e) {
      // ignore: avoid_print
      print('Analytics error: $e');
    }
  }
}
