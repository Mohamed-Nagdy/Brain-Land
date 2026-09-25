import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/theme.dart';
import '../l10n/app_localizations.dart';

/// Ads run on Android and iOS as child-directed AdMob requests
/// (`AgeRestrictedTreatment.child`, rating G, non-personalized, no advertising
/// ID and no tracking prompt).
///
/// Placements: one banner on the map and world screens, and an occasional
/// interstitial when a player leaves a finished mission. Never on launch,
/// never during a puzzle, never tied to hints or progress.
class Ads {
  Ads._();

  static final instance = Ads._();

  /// `--dart-define=BRAINLAND_NO_ADS=true` builds without ads (automated capture runs).
  static const _off = bool.fromEnvironment('BRAINLAND_NO_ADS');

  static bool get supported =>
      !_off && !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  // Google's public test units outside release builds, so testing never serves live ads.
  static String get _bannerUnit => !kReleaseMode
      ? (Platform.isIOS
            ? 'ca-app-pub-3940256099942544/2934735716'
            : 'ca-app-pub-3940256099942544/6300978111')
      : (Platform.isIOS
            ? 'ca-app-pub-4708111807522818/1284109772'
            : 'ca-app-pub-4708111807522818/5829967240');
  static String get _interstitialUnit => !kReleaseMode
      ? (Platform.isIOS
            ? 'ca-app-pub-3940256099942544/4411468910'
            : 'ca-app-pub-3940256099942544/1033173712')
      : (Platform.isIOS
            ? 'ca-app-pub-4708111807522818/7657946433'
            : 'ca-app-pub-4708111807522818/2391632728');

  static const _request = AdRequest(nonPersonalizedAds: true);

  final pacing = AdPacing();
  InterstitialAd? _interstitial;
  bool _started = false;
  final _ready = Completer<void>();

  /// Completes once the SDK is initialized with the child-directed configuration.
  Future<void> get ready => _ready.future;

  /// Called once the first screen is up, never before it.
  Future<void> start() async {
    if (!supported || _started) return;
    _started = true;
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        ageRestrictedTreatment: AgeRestrictedTreatment.child,
        maxAdContentRating: MaxAdContentRating.g,
      ),
    );
    await MobileAds.instance.initialize();
    _ready.complete();
    _loadInterstitial();
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: _interstitialUnit,
      request: _request,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (_) => _interstitial = null,
      ),
    );
  }

  /// Shows an interstitial if one is ready and the pacing allows it,
  /// and completes when the player is back in the game.
  Future<void> atMissionBreak() async {
    final ad = _interstitial;
    if (!supported || ad == null || !pacing.isDue(DateTime.now())) return;
    final closed = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        closed.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        closed.complete();
      },
    );
    _interstitial = null;
    pacing.shown(DateTime.now());
    await ad.show();
    await closed.future;
    _loadInterstitial();
  }
}

/// When an interstitial may appear: after at least two finished missions
/// since the last one, three minutes apart, and not in the first minutes of play.
class AdPacing {
  AdPacing({DateTime? appStart}) : _appStart = appStart ?? DateTime.now();

  static const missionsBetween = 2;
  static const minGap = Duration(minutes: 3);
  static const quietStart = Duration(minutes: 3);

  final DateTime _appStart;
  DateTime? _last;
  int _missions = 0;

  void missionFinished() => _missions++;

  bool isDue(DateTime now) =>
      _missions >= missionsBetween &&
      now.difference(_appStart) >= quietStart &&
      (_last == null || now.difference(_last!) >= minGap);

  void shown(DateTime now) {
    _last = now;
    _missions = 0;
  }
}

/// A single labelled banner at the bottom of menu screens.
class BannerSlot extends StatefulWidget {
  const BannerSlot({super.key});

  @override
  State<BannerSlot> createState() => _BannerSlotState();
}

class _BannerSlotState extends State<BannerSlot> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (Ads.supported) Ads.instance.ready.then((_) => _load());
  }

  void _load() {
    if (!mounted) return;
    _ad = BannerAd(
      adUnitId: Ads._bannerUnit,
      size: AdSize.banner,
      request: Ads._request,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, _) => ad.dispose(),
      ),
    )..load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (ad == null || !_loaded) return const SizedBox.shrink();
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.of(context).adLabel,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: Palette.inkSoft),
          ),
          SizedBox(
            width: ad.size.width.toDouble(),
            height: ad.size.height.toDouble(),
            child: AdWidget(ad: ad),
          ),
        ],
      ),
    );
  }
}
