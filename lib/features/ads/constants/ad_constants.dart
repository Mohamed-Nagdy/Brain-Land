import 'dart:io';

/// Ad unit IDs for MagicMind app
/// Separate IDs for Android and iOS platforms
class AdConstants {
  AdConstants._();

  // ============ ANDROID AD UNIT IDS ============
  static const String _androidAppId = 'ca-app-pub-4708111807522818~8240508163';
  static const String _androidBannerId =
      'ca-app-pub-4708111807522818/5829967240';
  static const String _androidInterstitialId =
      'ca-app-pub-4708111807522818/2391632728';
  static const String _androidRewardedId =
      'ca-app-pub-4708111807522818/9186650521';
  static const String _androidAppOpenId =
      'ca-app-pub-4708111807522818/4046112288';

  // ============ iOS AD UNIT IDS ============
  static const String _iosAppId = 'ca-app-pub-4708111807522818~1675099815';
  static const String _iosBannerId = 'ca-app-pub-4708111807522818/1284109772';
  static const String _iosInterstitialId =
      'ca-app-pub-4708111807522818/7657946433';
  static const String _iosRewardedId = 'ca-app-pub-4708111807522818/5247405511';
  static const String _iosAppOpenId = 'ca-app-pub-4708111807522818/2621242173';

  // ============ PLATFORM-SPECIFIC GETTERS ============

  /// Get the appropriate App ID for the current platform
  static String get appId {
    if (Platform.isAndroid) return _androidAppId;
    if (Platform.isIOS) return _iosAppId;
    return '';
  }

  /// Get the appropriate Banner Ad ID for the current platform
  static String get bannerId {
    if (Platform.isAndroid) return _androidBannerId;
    if (Platform.isIOS) return _iosBannerId;
    return '';
  }

  /// Get the appropriate Interstitial Ad ID for the current platform
  static String get interstitialId {
    if (Platform.isAndroid) return _androidInterstitialId;
    if (Platform.isIOS) return _iosInterstitialId;
    return '';
  }

  /// Get the appropriate Rewarded Ad ID for the current platform
  static String get rewardedId {
    if (Platform.isAndroid) return _androidRewardedId;
    if (Platform.isIOS) return _iosRewardedId;
    return '';
  }

  /// Get the appropriate App Open Ad ID for the current platform
  static String get appOpenId {
    if (Platform.isAndroid) return _androidAppOpenId;
    if (Platform.isIOS) return _iosAppOpenId;
    return '';
  }

  // ============ AD BEHAVIOR CONSTANTS ============

  /// Number of levels to complete before showing an interstitial ad
  static const int levelsBeforeInterstitial = 3;

  /// Coin reward for watching a rewarded ad
  static const int coinsPerRewardedAd = 100;

  /// Multiplier for double reward feature
  static const int doubleRewardMultiplier = 2;

  /// Minimum time between app open ads (in seconds)
  static const int appOpenAdCooldown = 3600; // 1 hour
}
