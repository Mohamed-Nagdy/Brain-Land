import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../ads/ads.dart';
import '../../content/worlds.dart';
import '../../core/art.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';
import '../../data/store.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/widgets.dart';

/// A world's chapters, ten missions at a time on a winding trail.
class WorldScreen extends ConsumerStatefulWidget {
  const WorldScreen({super.key, required this.world});

  final World world;

  @override
  ConsumerState<WorldScreen> createState() => _WorldScreenState();
}

class _WorldScreenState extends ConsumerState<WorldScreen> {
  late int _chapter =
      ref.read(progressProvider).nextIn(widget.world) ~/ kMissionsPerChapter;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final w = widget.world;
    final progress = ref.watch(progressProvider);
    final eastern = ref.watch(settingsProvider).easternDigits;
    final reachable = progress.nextIn(w) ~/ kMissionsPerChapter;
    final first = _chapter * kMissionsPerChapter;
    final next = progress.nextIn(w);
    final tablet = MediaQuery.sizeOf(context).shortestSide > 600;
    final node = tablet ? 104.0 : 84.0;

    return Scaffold(
      body: SceneBackground(
        scene: w.scene,
        veil: .75,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(Space.m),
                child: Row(
                  children: [
                    IconBubble(
                      Ico.back,
                      label: l.a11yBack,
                      onPressed: () => context.go('/'),
                    ),
                    const SizedBox(width: Space.s),
                    Expanded(
                      child: Text(
                        w.title(l),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    const GameIcon(Ico.starFull, size: 32),
                    Text(
                      digits(progress.starsIn(w), eastern: eastern),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              _ChapterBar(
                label: l.chapterNumber(digits(_chapter + 1, eastern: eastern)),
                done: progress.chapterDone(w, _chapter),
                trophy: w.trophy,
                onPrevious: _chapter > 0
                    ? () => setState(() => _chapter--)
                    : null,
                onNext: _chapter < reachable && _chapter + 1 < kChapters
                    ? () => setState(() => _chapter++)
                    : null,
                previousLabel: l.a11yBack,
                nextLabel: l.next,
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        vertical: Space.m,
                        horizontal: Space.l,
                      ),
                      itemCount: kMissionsPerChapter,
                      itemBuilder: (context, i) {
                        final n = first + i;
                        final align = const [
                          AlignmentDirectional.centerStart,
                          AlignmentDirectional(-.2, 0),
                          AlignmentDirectional(.4, 0),
                          AlignmentDirectional.centerEnd,
                          AlignmentDirectional(.4, 0),
                          AlignmentDirectional(-.2, 0),
                        ][i % 6];
                        return Align(
                          alignment: align,
                          child: _MissionNode(
                            key: ValueKey('mission-$n'),
                            size: node,
                            label: digits(n + 1, eastern: eastern),
                            stars: progress.of(w)[n],
                            unlocked: progress.isUnlocked(w, n),
                            current: n == next,
                            color: w.color,
                            lockedLabel: l.a11yLocked,
                            starsLabel: l.a11yStars(
                              digits(progress.of(w)[n], eastern: eastern),
                            ),
                            onTap: () => context.push('/play/${w.slug}/$n'),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const BannerSlot(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChapterBar extends StatelessWidget {
  const _ChapterBar({
    required this.label,
    required this.done,
    required this.trophy,
    required this.onPrevious,
    required this.onNext,
    required this.previousLabel,
    required this.nextLabel,
  });

  final String label;
  final bool done;
  final String trophy;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final String previousLabel;
  final String nextLabel;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: Space.m),
    child: Container(
      padding: const EdgeInsets.all(Space.xs),
      decoration: const BoxDecoration(
        color: Palette.paper,
        borderRadius: Radii.card,
      ),
      child: Row(
        children: [
          Opacity(
            opacity: onPrevious == null ? .3 : 1,
            child: IconBubble(
              Ico.back,
              label: previousLabel,
              onPressed: onPrevious ?? () {},
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Art(
                  done ? trophy : 'assets/svg/rewards/sticker_locked.svg',
                  width: 40,
                  height: 40,
                ),
                const SizedBox(width: Space.s),
                Text(label, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),
          Opacity(
            opacity: onNext == null ? .3 : 1,
            child: IconBubble(
              Ico.next,
              label: nextLabel,
              onPressed: onNext ?? () {},
            ),
          ),
        ],
      ),
    ),
  );
}

class _MissionNode extends ConsumerWidget {
  const _MissionNode({
    super.key,
    required this.size,
    required this.label,
    required this.stars,
    required this.unlocked,
    required this.current,
    required this.color,
    required this.lockedLabel,
    required this.starsLabel,
    required this.onTap,
  });

  final double size;
  final String label;
  final int stars;
  final bool unlocked;
  final bool current;
  final Color color;
  final String lockedLabel;
  final String starsLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final circle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: unlocked ? color : const Color(0xFFD9D3E3),
        border: Border.all(
          color: current ? Palette.gold : Colors.white,
          width: current ? 6 : 4,
        ),
        boxShadow: [
          BoxShadow(
            color: Color.lerp(color, Colors.black, .4)!.withValues(alpha: .5),
            offset: const Offset(0, 5),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: unlocked
          ? FittedBox(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  label,
                  style: text.headlineSmall?.copyWith(color: Colors.white),
                ),
              ),
            )
          : GameIcon(Ico.lock, size: size * .5),
    );
    return Semantics(
      button: unlocked,
      label: unlocked ? '$label, $starsLabel' : '$label, $lockedLabel',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Space.xs),
        child: GestureDetector(
          onTap: unlocked ? onTap : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  circle,
                  const SizedBox(height: 2),
                  if (unlocked)
                    StarRow(stars, size: 20)
                  else
                    const SizedBox(height: 20),
                ],
              ),
              if (current) ...[
                const SizedBox(width: Space.xs),
                TweenAnimationBuilder<double>(
                  tween: Tween(
                    begin: reducedMotion(context, ref) ? 1 : .6,
                    end: 1,
                  ),
                  duration: motion(context, ref, 500),
                  curve: Curves.easeOutBack,
                  builder: (context, v, child) =>
                      Transform.scale(scale: v, child: child),
                  child: Transform.flip(
                    flipX: Directionality.of(context) == TextDirection.ltr,
                    child: Mascot(Mood.point, size: size * .9),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
