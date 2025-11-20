import 'dart:developer';
import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Service for managing Google Mobile Ads
///
/// Handles banner ads and interstitial ads with child-safe filtering
class AdsService {
  static AdsService? _instance;
  static AdsService get instance => _instance ??= AdsService._();

  AdsService._();

  bool _isInitialized = false;
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  // Test ad unit IDs (replace with real IDs in production)
  static const String _testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  // Production ad unit IDs (to be configured)
  static const String _androidBannerAdUnitId =
      'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String _iosBannerAdUnitId =
      'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String _androidInterstitialAdUnitId =
      'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String _iosInterstitialAdUnitId =
      'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  /// Initialize the Mobile Ads SDK
  Future<void> initialize() async {
    if (_isInitialized) return;

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
    } catch (e) {
      log('Failed to initialize ads: $e');
    }
  }

  /// Get the appropriate banner ad unit ID for the platform
  String get _bannerAdUnitId {
    if (Platform.isAndroid) {
      return _androidBannerAdUnitId;
    } else if (Platform.isIOS) {
      return _iosBannerAdUnitId;
    }
    return _testBannerAdUnitId;
  }

  /// Get the appropriate interstitial ad unit ID for the platform
  String get _interstitialAdUnitId {
    if (Platform.isAndroid) {
      return _androidInterstitialAdUnitId;
    } else if (Platform.isIOS) {
      return _iosInterstitialAdUnitId;
    }
    return _testInterstitialAdUnitId;
  }

  /// Load a banner ad
  ///
  /// Returns the loaded BannerAd or null if loading fails
  Future<BannerAd?> loadBannerAd() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      _bannerAd = BannerAd(
        adUnitId: _bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            log('Banner ad loaded');
          },
          onAdFailedToLoad: (ad, error) {
            log('Banner ad failed to load: $error');
            ad.dispose();
            _bannerAd = null;
          },
        ),
      );

      await _bannerAd!.load();
      return _bannerAd;
    } catch (e) {
      log('Error loading banner ad: $e');
      return null;
    }
  }

  /// Dispose of the current banner ad
  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
  }

  /// Load an interstitial ad
  ///
  /// Loads the ad in the background, ready to be shown later
  Future<void> loadInterstitialAd() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await InterstitialAd.load(
        adUnitId: _interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _isInterstitialAdReady = true;

            // Set up full screen content callback
            _interstitialAd!.fullScreenContentCallback =
                FullScreenContentCallback(
                  onAdShowedFullScreenContent: (ad) {
                    log('Interstitial ad showed full screen');
                  },
                  onAdDismissedFullScreenContent: (ad) {
                    log('Interstitial ad dismissed');
                    ad.dispose();
                    _interstitialAd = null;
                    _isInterstitialAdReady = false;
                    // Preload next ad
                    loadInterstitialAd();
                  },
                  onAdFailedToShowFullScreenContent: (ad, error) {
                    log('Interstitial ad failed to show: $error');
                    ad.dispose();
                    _interstitialAd = null;
                    _isInterstitialAdReady = false;
                  },
                );
          },
          onAdFailedToLoad: (error) {
            log('Interstitial ad failed to load: $error');
            _isInterstitialAdReady = false;
          },
        ),
      );
    } catch (e) {
      log('Error loading interstitial ad: $e');
      _isInterstitialAdReady = false;
    }
  }

  /// Show the loaded interstitial ad
  ///
  /// Returns true if the ad was shown, false otherwise
  Future<bool> showInterstitialAd() async {
    if (!_isInterstitialAdReady || _interstitialAd == null) {
      log('Interstitial ad not ready');
      return false;
    }

    try {
      await _interstitialAd!.show();
      return true;
    } catch (e) {
      log('Error showing interstitial ad: $e');
      return false;
    }
  }

  /// Check if an interstitial ad is ready to be shown
  bool get isInterstitialAdReady => _isInterstitialAdReady;

  /// Get the current banner ad
  BannerAd? get bannerAd => _bannerAd;

  /// Dispose of all ads and cleanup
  void dispose() {
    disposeBannerAd();
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialAdReady = false;
  }
}
