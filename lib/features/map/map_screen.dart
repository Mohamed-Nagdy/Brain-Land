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
import '../parents/parent_gate.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ref.read(settingsProvider).welcomed) {
        ref
            .read(audioProvider)
            .say(
              Line.welcome.name,
              Localizations.localeOf(context).languageCode,
            );
      }
      Ads.instance.start();
    });
  }

  void _open(World w) {
    ref
        .read(settingsProvider.notifier)
        .update((s) => s.copyWith(welcomed: true));
    context.push('/world/${w.slug}');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final progress = ref.watch(progressProvider);
    final welcomed = ref.watch(settingsProvider).welcomed;
    final eastern = ref.watch(settingsProvider).easternDigits;
    final size = MediaQuery.sizeOf(context);
    final tablet = size.shortestSide > 600;
    // Landscape: all four worlds in one row, so none sits below the fold.
    final landscape = size.width > size.height;
    return Scaffold(
      body: SceneBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: landscape ? 1100 : 820,
                    ),
                    child: CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(
                            Space.m,
                            Space.s,
                            Space.m,
                            0,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    l.appTitle,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall
                                        ?.copyWith(color: Palette.ink),
                                  ),
                                ),
                                _Chip(
                                  icon: Ico.starFull,
                                  text: digits(
                                    progress.totalStars,
                                    eastern: eastern,
                                  ),
                                ),
                                const SizedBox(width: Space.s),
                                IconBubble(
                                  Ico.parents,
                                  label: l.parentsArea,
                                  onPressed: () => openParents(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.all(Space.m),
                          sliver: SliverToBoxAdapter(
                            child: MascotSays(
                              mood: welcomed ? Mood.wave : Mood.point,
                              text: l.welcome,
                              mascotSize: tablet ? 140 : 96,
                              replayLabel: l.a11yReplay,
                              onReplay:
                                  ref
                                      .read(audioProvider)
                                      .hasVoice(
                                        Line.welcome.name,
                                        Localizations.localeOf(
                                          context,
                                        ).languageCode,
                                      )
                                  ? () => ref
                                        .read(audioProvider)
                                        .say(
                                          Line.welcome.name,
                                          Localizations.localeOf(
                                            context,
                                          ).languageCode,
                                        )
                                  : null,
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Space.m,
                          ),
                          sliver: SliverGrid.count(
                            crossAxisCount: landscape ? 4 : 2,
                            mainAxisSpacing: Space.m,
                            crossAxisSpacing: Space.m,
                            childAspectRatio: landscape
                                ? .9
                                : (tablet ? 1.05 : .82),
                            children: [
                              for (final w in World.values)
                                _WorldCard(
                                  key: ValueKey('world-${w.slug}'),
                                  world: w,
                                  progress: progress,
                                  eastern: eastern,
                                  onTap: () => _open(w),
                                ),
                            ],
                          ),
                        ),
                        const SliverToBoxAdapter(
                          child: SizedBox(height: Space.l),
                        ),
                      ],
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

class _WorldCard extends StatelessWidget {
  const _WorldCard({
    super.key,
    required this.world,
    required this.progress,
    required this.eastern,
    required this.onTap,
  });

  final World world;
  final Progress progress;
  final bool eastern;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final done = progress.completedIn(world);
    final medals = progress.medalsIn(world);
    final text = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label:
          '${world.title(l)}, ${digits(done, eastern: eastern)} / ${digits(kMissionsPerWorld, eastern: eastern)}',
      excludeSemantics: true,
      child: Material(
        color: Palette.paper,
        borderRadius: Radii.card,
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        shadowColor: const Color(0x552E2240),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: Art(world.scene, fit: BoxFit.cover)),
              Container(
                color: world.color,
                padding: const EdgeInsets.fromLTRB(
                  Space.s,
                  Space.xs,
                  Space.s,
                  Space.s,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      world.title(l),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleLarge?.copyWith(color: Colors.white),
                    ),
                    Row(
                      children: [
                        const GameIcon(Ico.starFull, size: 20),
                        const SizedBox(width: 2),
                        Text(
                          digits(progress.starsIn(world), eastern: eastern),
                          style: text.labelMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        if (medals > 0) ...[
                          Art(world.trophy, width: 22, height: 22),
                          Text(
                            digits(medals, eastern: eastern),
                            style: text.labelMedium?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: Space.xs),
                    ClipRRect(
                      borderRadius: Radii.chip,
                      child: LinearProgressIndicator(
                        value: done / kMissionsPerWorld,
                        minHeight: 8,
                        color: Palette.gold,
                        backgroundColor: Colors.white.withValues(alpha: .35),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${digits(done, eastern: eastern)} / ${digits(kMissionsPerWorld, eastern: eastern)}',
                      textDirection: TextDirection.ltr,
                      style: text.labelMedium?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.text});

  final Ico icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(Space.s, Space.xs, Space.m, Space.xs),
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: Radii.chip,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GameIcon(icon, size: 28),
        const SizedBox(width: Space.xs),
        Text(text, style: Theme.of(context).textTheme.titleMedium),
      ],
    ),
  );
}
