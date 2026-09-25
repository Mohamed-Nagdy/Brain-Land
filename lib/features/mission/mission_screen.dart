import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../ads/ads.dart';
import '../../content/missions.dart';
import '../../content/worlds.dart';
import '../../core/art.dart';
import '../../core/audio.dart';
import '../../core/lines.dart';
import '../../core/theme.dart';
import '../../data/store.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/widgets.dart';
import 'math_round.dart';
import 'memory_round.dart';
import 'pattern_round.dart';
import 'round.dart';
import 'shape_round.dart';

/// One mission: a few short items, a mascot who explains and encourages,
/// free hints, and stars at the end. Nobody fails; mistakes only cost stars.
class MissionScreen extends ConsumerStatefulWidget {
  const MissionScreen({super.key, required this.world, required this.mission});

  final World world;
  final int mission;

  @override
  ConsumerState<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends ConsumerState<MissionScreen>
    with WidgetsBindingObserver {
  int _item = 0;
  int _mistakes = 0;
  int _hints = 0;
  late Line _line;
  Mood _mood = Mood.idle;
  bool _advancing = false;
  Timer? _timer;

  World get w => widget.world;
  int get n => widget.mission;

  late final _math = w == World.math ? mathMission(n) : null;
  late final _logic = w == World.logic ? logicMission(n) : null;
  late final _memory = w == World.memory ? memoryMission(n) : null;
  late final _shape = w == World.shape ? shapeMission(n) : null;

  int get _items => switch (w) {
    World.math => _math!.length,
    World.logic => _logic!.length,
    World.memory => 1,
    World.shape => _shape!.length,
  };

  int get _allowance => w == World.memory ? _memory!.mistakeAllowance : 1;

  int get _maxHints => switch (w) {
    World.math => MathRound.maxHints(_math![_item]),
    World.logic => 1,
    World.memory => MemoryRound.maxHints,
    World.shape => ShapeRound.maxHints,
  };

  Line get _instruction => switch (w) {
    World.math => MathRound.instruction(_math![_item]),
    World.logic => PatternRound.instruction(_logic![_item]),
    World.memory => Line.instrMemory,
    World.shape => Line.instrShape,
  };

  Line _hintLine(int level) => switch (w) {
    World.math => MathRound.hintLine(_math![_item], level),
    World.logic => Line.hintPattern,
    World.memory => Line.hintMemory,
    World.shape => Line.hintShape,
  };

  String get _lang => Localizations.localeOf(context).languageCode;

  void _say(Line line) => ref.read(audioProvider).say(line.name, _lang);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _line = _instruction;
    WidgetsBinding.instance.addPostFrameCallback((_) => _say(_line));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) ref.read(audioProvider).stopVoice();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  void _onEvent(RoundEvent e) {
    final audio = ref.read(audioProvider);
    switch (e.kind) {
      case RoundEventKind.progress:
        setState(() => _mood = Mood.happy);
      case RoundEventKind.mistake:
        setState(() {
          _mistakes++;
          _mood = Mood.oops;
          _line = e.line!;
        });
        _say(_line);
      case RoundEventKind.solved:
        audio.play(Sfx.correct);
        final praise = Line.praise[(_item + n) % Line.praise.length];
        setState(() {
          _mood = Mood.cheer;
          _line = praise;
          _advancing = true;
        });
        _say(praise);
        final reduced =
            MediaQuery.disableAnimationsOf(context) ||
            ref.read(settingsProvider).reduceMotion;
        _timer = Timer(Duration(milliseconds: reduced ? 700 : 1300), _advance);
    }
  }

  void _advance() {
    if (!mounted) return;
    if (_item + 1 < _items) {
      setState(() {
        _item++;
        _hints = 0;
        _mood = Mood.idle;
        _line = _instruction;
        _advancing = false;
      });
      _say(_line);
      return;
    }
    final stars = starsFor(_mistakes, _allowance);
    final medal = ref.read(progressProvider.notifier).record(w, n, stars);
    ref.read(sessionProvider.notifier).missionFinished();
    Ads.instance.pacing.missionFinished();
    ref.read(audioProvider).play(Sfx.complete);
    context.pushReplacement('/done/${w.slug}/$n?stars=$stars&medal=$medal');
  }

  void _hint() {
    if (_advancing || _hints >= _maxHints) return;
    setState(() {
      _hints++;
      _mood = Mood.point;
      _line = _hintLine(_hints);
    });
    _say(_line);
  }

  Future<void> _pause() async {
    ref.read(audioProvider).stopVoice();
    final l = AppLocalizations.of(context);
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Palette.paper,
        shape: const RoundedRectangleBorder(borderRadius: Radii.card),
        child: Padding(
          padding: const EdgeInsets.all(Space.l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Mascot(Mood.idle, size: 120),
              Text(l.paused, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: Space.m),
              GameButton(
                label: l.resume,
                icon: Ico.play,
                color: Palette.good,
                onPressed: () => Navigator.pop(context, false),
              ),
              const SizedBox(height: Space.s),
              GameButton(
                label: l.map,
                icon: Ico.home,
                color: Palette.indigo,
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        ),
      ),
    );
    if (leave == true && mounted) context.go('/world/${w.slug}');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final key = ValueKey('$n/$_item');
    final round = switch (w) {
      World.math => MathRound(
        key: key,
        task: _math![_item],
        hintLevel: _hints,
        onEvent: _onEvent,
      ),
      World.logic => PatternRound(
        key: key,
        task: _logic![_item],
        hintLevel: _hints,
        onEvent: _onEvent,
      ),
      World.memory => MemoryRound(
        key: key,
        task: _memory!,
        hintLevel: _hints,
        onEvent: _onEvent,
      ),
      World.shape => ShapeRound(
        key: key,
        task: _shape![_item],
        hintLevel: _hints,
        onEvent: _onEvent,
      ),
    };
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _pause();
      },
      child: Scaffold(
        body: SceneBackground(
          scene: w.scene,
          veil: .84,
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Space.m),
                  child: Column(
                    children: [
                      const SizedBox(height: Space.s),
                      Row(
                        children: [
                          IconBubble(
                            Ico.pause,
                            label: l.a11yPause,
                            onPressed: _pause,
                          ),
                          Expanded(
                            child: _ItemDots(
                              count: _items,
                              done: _item,
                              color: w.color,
                            ),
                          ),
                          Opacity(
                            opacity: _hints < _maxHints && !_advancing
                                ? 1
                                : .35,
                            child: IconBubble(
                              Ico.hint,
                              label: l.a11yHint,
                              onPressed: _hint,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Space.s),
                      MascotSays(
                        mood: _mood,
                        text: _line.text(l),
                        mascotSize:
                            MediaQuery.sizeOf(context).shortestSide > 600
                            ? 130
                            : 88,
                        replayLabel: l.a11yReplay,
                        onReplay:
                            ref.read(audioProvider).hasVoice(_line.name, _lang)
                            ? () => _say(_line)
                            : null,
                      ),
                      Expanded(child: round),
                    ],
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

class _ItemDots extends StatelessWidget {
  const _ItemDots({
    required this.count,
    required this.done,
    required this.color,
  });

  final int count;
  final int done;
  final Color color;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          Container(
            width: i == done ? 28 : 14,
            height: 14,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: i <= done ? color : Colors.white,
              borderRadius: Radii.chip,
              border: Border.all(color: color, width: 2),
            ),
          ),
      ],
    ),
  );
}
