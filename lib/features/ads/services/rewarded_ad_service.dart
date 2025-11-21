import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../constants/ad_constants.dart';
import 'ad_manager.dart';

/// Callback for rewarded ad completion
typedef RewardCallback = void Function(int rewardAmount);

/// Service for managing rewarded ads
/// Users watch these ads to earn coins or other rewards
class RewardedAdService {
  RewardedAd? _rewardedAd;
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  /// Load a rewarded ad
  Future<void> loadAd() async {
    if (!AdManager.instance.isInitialized) {
      log('AdManager not initialized, cannot load rewarded ad');
      return;
    }

    // Dispose existing ad if any
    await dispose();

    await RewardedAd.load(
      adUnitId: AdConstants.rewardedId,
      request: AdManager.instance.createAdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          log('Rewarded ad loaded');
          _rewardedAd = ad;
          _isLoaded = true;
        },
        onAdFailedToLoad: (error) {
          log('Rewarded ad failed to load: $error');
          _isLoaded = false;
        },
      ),
    );
  }

  /// Show the rewarded ad and call the callback when user earns reward
  Future<bool> show({
    required RewardCallback onRewarded,
    VoidCallback? onAdDismissed,
  }) async {
    if (!_isLoaded || _rewardedAd == null) {
      log('Rewarded ad not ready to show');
      return false;
    }

    bool rewardEarned = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        log('Rewarded ad showed full screen content');
      },
      onAdDismissedFullScreenContent: (ad) {
        log('Rewarded ad dismissed. Reward earned: $rewardEarned');
        dispose();
        // Preload next ad
        loadAd();
        onAdDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        log('Rewarded ad failed to show: $error');
        dispose();
        onAdDismissed?.call();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        log('User earned reward: ${reward.amount} ${reward.type}');
        rewardEarned = true;
        // Call the reward callback with the coin amount
        onRewarded(AdConstants.coinsPerRewardedAd);
      },
    );

    return true;
  }

  /// Dispose the rewarded ad
  Future<void> dispose() async {
    await _rewardedAd?.dispose();
    _rewardedAd = null;
    _isLoaded = false;
  }
}
