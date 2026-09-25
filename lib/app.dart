import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'content/worlds.dart';
import 'core/theme.dart';
import 'data/store.dart';
import 'features/map/map_screen.dart';
import 'features/mission/done_screen.dart';
import 'features/mission/mission_screen.dart';
import 'features/parents/parents_screen.dart';
import 'features/world/world_screen.dart';
import 'l10n/app_localizations.dart';

/// Keep in step with `version:` in pubspec.yaml (checked by a test).
const kAppVersion = '1.1.0';

/// The Brain Land privacy policy on the ATHRYZA website.
String privacyUrl(String languageCode) =>
    'https://athryza.com/$languageCode/privacy#brain-land';

World? _world(GoRouterState s) =>
    World.values.where((w) => w.slug == s.pathParameters['world']).firstOrNull;
int? _mission(GoRouterState s) {
  final n = int.tryParse(s.pathParameters['mission'] ?? '');
  return n != null && n >= 0 && n < kMissionsPerWorld ? n : null;
}

GoRouter buildRouter() => GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, _) => const MapScreen()),
    GoRoute(
      path: '/world/:world',
      redirect: (_, s) => _world(s) == null ? '/' : null,
      builder: (_, s) => WorldScreen(world: _world(s)!),
    ),
    GoRoute(
      path: '/play/:world/:mission',
      redirect: (context, s) {
        final w = _world(s), n = _mission(s);
        if (w == null || n == null) return '/';
        final container = ProviderScope.containerOf(context);
        return container.read(progressProvider).isUnlocked(w, n)
            ? null
            : '/world/${w.slug}';
      },
      builder: (_, s) => MissionScreen(
        key: ValueKey(s.uri.toString()),
        world: _world(s)!,
        mission: _mission(s)!,
      ),
    ),
    GoRoute(
      path: '/done/:world/:mission',
      redirect: (_, s) => _world(s) == null || _mission(s) == null ? '/' : null,
      builder: (_, s) => DoneScreen(
        world: _world(s)!,
        mission: _mission(s)!,
        stars: (int.tryParse(s.uri.queryParameters['stars'] ?? '') ?? 1).clamp(
          1,
          3,
        ),
        medal: s.uri.queryParameters['medal'] == 'true',
      ),
    ),
    GoRoute(path: '/parents', builder: (_, _) => const ParentsScreen()),
  ],
  errorBuilder: (_, _) => const MapScreen(),
);

class BrainLandApp extends ConsumerStatefulWidget {
  const BrainLandApp({super.key});

  @override
  ConsumerState<BrainLandApp> createState() => _BrainLandAppState();
}

class _BrainLandAppState extends ConsumerState<BrainLandApp> {
  final _router = buildRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final code = ref.watch(settingsProvider.select((s) => s.languageCode));
    return MaterialApp.router(
      title: 'Brain Land',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      routerConfig: _router,
      // Large tablets: lay the game out at phone-like density, then scale it up,
      // so every piece keeps the same presence as on a phone.
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        final scale = mq.size.shortestSide >= 700 ? 1.4 : 1.0;
        if (scale == 1) return child!;
        final size = mq.size / scale;
        return FittedBox(
          child: SizedBox.fromSize(
            size: size,
            child: MediaQuery(
              data: mq.copyWith(
                size: size,
                padding: mq.padding / scale,
                viewPadding: mq.viewPadding / scale,
                viewInsets: mq.viewInsets / scale,
              ),
              child: child!,
            ),
          ),
        );
      },
      locale: code == null ? null : Locale(code),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      // Arabic first: English only when the device asks for it.
      localeResolutionCallback: (device, _) => device?.languageCode == 'en'
          ? const Locale('en')
          : const Locale('ar'),
    );
  }
}
