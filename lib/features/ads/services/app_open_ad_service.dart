import 'dart:developer';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../constants/ad_constants.dart';
import 'ad_manager.dart';

/// Service for managing app open ads
/// Shows full-screen ads when app is opened/resumed
class AppOpenAdService {
  AppOpenAd? _appOpenAd;
  bool _isLoaded = false;
  bool _isShowing = false;

  bool get isLoaded => _isLoaded;

  /// Load an app open ad
  Future<void> loadAd() async {
    if (!AdManager.instance.isInitialized) {
      log('AdManager not initialized, cannot load app open ad');
      return;
    }

    // Dispose existing ad if any
    await dispose();

    await AppOpenAd.load(
      adUnitId: AdConstants.appOpenId,
      request: AdManager.instance.createAdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          log('App open ad loaded');
          _appOpenAd = ad;
          _isLoaded = true;

          // Set full screen content callback
          _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              log('App open ad showed full screen content');
              _isShowing = true;
            },
            onAdDismissedFullScreenContent: (ad) {
              log('App open ad dismissed');
              _isShowing = false;
              dispose();
              // Preload next ad
              loadAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              log('App open ad failed to show: $error');
              _isShowing = false;
              dispose();
            },
          );
        },
        onAdFailedToLoad: (error) {
          log('App open ad failed to load: $error');
          _isLoaded = false;
        },
      ),
    );
  }

  /// Show the app open ad if loaded and cooldown allows
  Future<bool> showIfAvailable() async {
    // Don't show if already showing
    if (_isShowing) {
      return false;
    }

    // Check cooldown
    if (!AdManager.instance.shouldShowAppOpenAd()) {
      log('App open ad on cooldown');
      return false;
    }

    if (!_isLoaded || _appOpenAd == null) {
      log('App open ad not ready to show');
      // Try to load for next time
      loadAd();
      return false;
    }

    await _appOpenAd!.show();
    return true;
  }

  /// Dispose the app open ad
  Future<void> dispose() async {
    await _appOpenAd?.dispose();
    _appOpenAd = null;
    _isLoaded = false;
  }
}
