import 'dart:developer';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../constants/ad_constants.dart';
import 'ad_manager.dart';

/// Service for managing interstitial ads
/// Shows full-screen ads at natural break points
class InterstitialAdService {
  InterstitialAd? _interstitialAd;
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  /// Load an interstitial ad
  Future<void> loadAd() async {
    if (!AdManager.instance.isInitialized) {
      log('AdManager not initialized, cannot load interstitial ad');
      return;
    }

    // Dispose existing ad if any
    await dispose();

    await InterstitialAd.load(
      adUnitId: AdConstants.interstitialId,
      request: AdManager.instance.createAdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          log('Interstitial ad loaded');
          _interstitialAd = ad;
          _isLoaded = true;

          // Set full screen content callback
          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
                onAdShowedFullScreenContent: (ad) {
                  log('Interstitial ad showed full screen content');
                },
                onAdDismissedFullScreenContent: (ad) {
                  log('Interstitial ad dismissed');
                  dispose();
                  // Preload next ad
                  loadAd();
                },
                onAdFailedToShowFullScreenContent: (ad, error) {
                  log('Interstitial ad failed to show: $error');
                  dispose();
                },
              );
        },
        onAdFailedToLoad: (error) {
          log('Interstitial ad failed to load: $error');
          _isLoaded = false;
        },
      ),
    );
  }

  /// Show the interstitial ad if loaded
  Future<bool> show() async {
    if (!_isLoaded || _interstitialAd == null) {
      log('Interstitial ad not ready to show');
      return false;
    }

    await _interstitialAd!.show();
    return true;
  }

  /// Dispose the interstitial ad
  Future<void> dispose() async {
    await _interstitialAd?.dispose();
    _interstitialAd = null;
    _isLoaded = false;
  }
}
