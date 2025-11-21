import 'dart:developer';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../constants/ad_constants.dart';
import 'ad_manager.dart';

/// Service for managing banner ads
class BannerAdService {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  BannerAd? get bannerAd => _bannerAd;

  /// Load a banner ad
  Future<void> loadAd() async {
    if (!AdManager.instance.isInitialized) {
      log('AdManager not initialized, cannot load banner ad');
      return;
    }

    // Dispose existing ad if any
    await dispose();

    _bannerAd = BannerAd(
      adUnitId: AdConstants.bannerId,
      size: AdSize.banner,
      request: AdManager.instance.createAdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          log('Banner ad loaded');
          _isLoaded = true;
        },
        onAdFailedToLoad: (ad, error) {
          log('Banner ad failed to load: $error');
          _isLoaded = false;
          ad.dispose();
        },
        onAdOpened: (ad) {
          log('Banner ad opened');
        },
        onAdClosed: (ad) {
          log('Banner ad closed');
        },
      ),
    );

    await _bannerAd!.load();
  }

  /// Dispose the banner ad
  Future<void> dispose() async {
    await _bannerAd?.dispose();
    _bannerAd = null;
    _isLoaded = false;
  }
}
