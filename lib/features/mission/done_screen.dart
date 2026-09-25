import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../ads/ads.dart';
import '../../content/worlds.dart';
import '../../core/art.dart';
import '../../core/audio.dart';
import '../../core/lines.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';
import '../../data/store.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/widgets.dart';

/// Mission result: stars, a medal when a chapter is finished, and every
/// third mission a gentle suggestion to take a break.
class DoneScreen extends ConsumerStatefulWidget {
  const DoneScreen({
    super.key,
    required this.world,
    required this.mission,
    required this.stars,
    required this.medal,
  });

  final World world;
  final int mission;
  final int stars;
  final bool medal;

  @override
  ConsumerState<DoneScreen> createState() => _DoneScreenState();
}

class _DoneScreenState extends ConsumerState<DoneScreen> {
  late final bool _break = ref.read(sessionProvider) % 3 == 0;
  bool _leaving = false;

  Line get _headline => widget.medal
      ? Line.chapterComplete
      : (_break ? Line.breakTitle : Line.missionComplete);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lang = Localizations.localeOf(context).languageCode;
      final audio = ref.read(audioProvider);
      audio.say(
        (_break && !widget.medal ? Line.breakBody : _headline).name,
        lang,
      );
      if (widget.stars == 3) audio.play(Sfx.star);
    });
  }

  Future<void> _go(String location) async {
    if (_leaving) return;
    _leaving = true;
    ref.read(audioProvider).stopVoice();
    await Ads.instance.atMissionBreak();
    if (mounted) context.go(location);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final w = widget.world;
    final hasNext = widget.mission + 1 < kMissionsPerWorld;
    final tablet = MediaQuery.sizeOf(context).shortestSide > 600;
    final eastern = ref.watch(settingsProvider).easternDigits;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _go('/world/${w.slug}');
      },
      child: Scaffold(
        body: SceneBackground(
          scene: w.scene,
          veil: .7,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Space.l),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Container(
                    padding: const EdgeInsets.all(Space.l),
                    decoration: const BoxDecoration(
                      color: Palette.paper,
                      borderRadius: Radii.card,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x332E2240),
                          blurRadius: 24,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${w.title(l)} · ${l.missionNumber(digits(widget.mission + 1, eastern: eastern))}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: Space.s),
                        Text(
                          _headline.text(l),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: Space.m),
                        _StarsIn(
                          count: widget.stars,
                          size: tablet ? 72 : 56,
                          label: l.a11yStars(
                            digits(widget.stars, eastern: eastern),
                          ),
                        ),
                        const SizedBox(height: Space.m),
                        if (widget.medal)
                          Semantics(
                            label: l.a11yMedal,
                            child: Art(w.trophy, width: tablet ? 180 : 140),
                          )
                        else
                          Mascot(
                            _break ? Mood.sleep : Mood.cheer,
                            size: tablet ? 200 : 150,
                          ),
                        if (_break && !widget.medal) ...[
                          const SizedBox(height: Space.s),
                          Text(
                            l.breakBody,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                        const SizedBox(height: Space.l),
                        if (hasNext)
                          GameButton(
                            label: _break ? l.keepPlaying : l.next,
                            icon: Ico.next,
                            color: Palette.good,
                            onPressed: () =>
                                _go('/play/${w.slug}/${widget.mission + 1}'),
                          ),
                        const SizedBox(height: Space.s),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: Space.s,
                          runSpacing: Space.s,
                          children: [
                            GameButton(
                              key: const ValueKey('done-map'),
                              label: l.map,
                              icon: Ico.home,
                              color: Palette.indigo,
                              onPressed: () => _go('/world/${w.slug}'),
                            ),
                            GameButton(
                              label: l.playAgain,
                              icon: Ico.retry,
                              color: Palette.purpleLight,
                              onPressed: () =>
                                  _go('/play/${w.slug}/${widget.mission}'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Stars pop in one after another (all at once under reduced motion).
class _StarsIn extends ConsumerWidget {
  const _StarsIn({
    required this.count,
    required this.size,
    required this.label,
  });

  final int count;
  final double size;
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reduced = reducedMotion(context, ref);
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: reduced ? 1 : 0, end: 1),
              duration: reduced
                  ? Duration.zero
                  : Duration(milliseconds: 350 + i * 250),
              curve: Curves.elasticOut,
              builder: (context, v, child) =>
                  Transform.scale(scale: v, child: child),
              child: GameIcon(
                i < count ? Ico.starFull : Ico.starEmpty,
                size: size,
              ),
            ),
        ],
      ),
    );
  }
}
