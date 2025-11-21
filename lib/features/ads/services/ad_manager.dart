import 'dart:developer';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../constants/ad_constants.dart';

/// Central manager for all ad operations
/// Singleton pattern to ensure single instance across the app
class AdManager {
  AdManager._();
  static final AdManager instance = AdManager._();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Track level completions for interstitial ad frequency
  int _levelsCompletedSinceLastAd = 0;

  // Track last app open ad time
  DateTime? _lastAppOpenAdTime;

  /// Initialize the AdMob SDK
  /// Should be called once at app startup
  Future<void> initialize() async {
    if (_isInitialized) {
      log('AdManager already initialized');
      return;
    }

    try {
      await MobileAds.instance.initialize();

      // Configure for child-directed treatment (COPPA compliance)
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
          maxAdContentRating: MaxAdContentRating.g,
        ),
      );

      _isInitialized = true;
      log('AdManager initialized successfully');
    } catch (e) {
      log('Failed to initialize AdManager: $e');
      rethrow;
    }
  }

  /// Check if an interstitial ad should be shown
  /// Based on number of levels completed since last ad
  bool shouldShowInterstitialAd() {
    _levelsCompletedSinceLastAd++;

    if (_levelsCompletedSinceLastAd >= AdConstants.levelsBeforeInterstitial) {
      _levelsCompletedSinceLastAd = 0;
      return true;
    }

    return false;
  }

  /// Reset the level counter (e.g., when user fails a level)
  void resetLevelCounter() {
    _levelsCompletedSinceLastAd = 0;
  }

  /// Check if an app open ad should be shown
  /// Based on cooldown period
  bool shouldShowAppOpenAd() {
    if (_lastAppOpenAdTime == null) {
      _lastAppOpenAdTime = DateTime.now();
      return true;
    }

    final timeSinceLastAd = DateTime.now().difference(_lastAppOpenAdTime!);
    if (timeSinceLastAd.inSeconds >= AdConstants.appOpenAdCooldown) {
      _lastAppOpenAdTime = DateTime.now();
      return true;
    }

    return false;
  }

  /// Create AdRequest with child-safe settings
  AdRequest createAdRequest() {
    return const AdRequest(
      keywords: ['kids', 'education', 'learning', 'puzzle', 'games'],
      contentUrl: 'https://magicmind.app',
    );
  }
}
