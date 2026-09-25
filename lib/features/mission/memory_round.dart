import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/memory_chapter.dart';
import '../../core/art.dart';
import '../../core/audio.dart';
import '../../core/lines.dart';
import '../../core/motion.dart';
import '../../l10n/app_localizations.dart';
import 'round.dart';

class MemoryRound extends ConsumerStatefulWidget {
  const MemoryRound({
    super.key,
    required this.task,
    required this.hintLevel,
    required this.onEvent,
    this.random,
  });

  final MemoryTask task;

  /// Each hint shows the hidden cards for a moment.
  final int hintLevel;
  final RoundListener onEvent;

  /// Card order; tests pass a seeded generator.
  final Random? random;

  static const maxHints = 2;

  @override
  ConsumerState<MemoryRound> createState() => _MemoryRoundState();
}

class _MemoryRoundState extends ConsumerState<MemoryRound> {
  late final List<String> _cards = [...widget.task.faces, ...widget.task.faces]
    ..shuffle(widget.random ?? Random());
  final _matched = <int>{};
  final _open = <int>[];
  bool _peeking = false;
  bool _busy = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.task.peekSeconds > 0) {
      _peek(Duration(seconds: widget.task.peekSeconds));
    }
  }

  @override
  void didUpdateWidget(MemoryRound old) {
    super.didUpdateWidget(old);
    if (widget.hintLevel > old.hintLevel) {
      _peek(const Duration(milliseconds: 1500));
    }
  }

  void _peek(Duration d) {
    _timer?.cancel();
    setState(() => _peeking = true);
    _timer = Timer(d, () {
      if (mounted) setState(() => _peeking = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tap(int i) {
    if (_busy || _peeking || _matched.contains(i) || _open.contains(i)) return;
    final audio = ref.read(audioProvider)..play(Sfx.flip);
    setState(() => _open.add(i));
    if (_open.length < 2) return;
    final [a, b] = _open;
    if (_cards[a] == _cards[b]) {
      setState(() {
        _matched.addAll(_open);
        _open.clear();
      });
      if (_matched.length == _cards.length) {
        widget.onEvent(const RoundEvent.solved());
      } else {
        audio.play(Sfx.correct);
        widget.onEvent(const RoundEvent.progress());
      }
      return;
    }
    _busy = true;
    widget.onEvent(const RoundEvent.mistake(Line.mistakeMemory));
    _timer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _open.clear();
        _busy = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final count = _cards.length;
    final columns = count <= 4
        ? 2
        : count <= 6
        ? 3
        : 4;
    final rows = (count / columns).ceil();
    return LayoutBuilder(
      builder: (context, box) {
        const gap = 10.0;
        final byWidth = (box.maxWidth - gap * (columns + 1)) / columns;
        final byHeight = ((box.maxHeight - gap * (rows + 1)) / rows) * .8;
        final width = min(min(byWidth, byHeight), 150.0);
        return Center(
          child: Wrap(
            spacing: gap,
            runSpacing: gap,
            alignment: WrapAlignment.center,
            children: [
              for (var i = 0; i < count; i++)
                SizedBox(
                  width: width,
                  height: width / .8,
                  child: _Card(
                    key: ValueKey('card-$i-${_cards[i]}'),
                    face: _cards[i],
                    up: _peeking || _matched.contains(i) || _open.contains(i),
                    matched: _matched.contains(i),
                    label: l.a11yCard,
                    onTap: () => _tap(i),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Card extends ConsumerWidget {
  const _Card({
    super.key,
    required this.face,
    required this.up,
    required this.matched,
    required this.label,
    required this.onTap,
  });

  final String face;
  final bool up;
  final bool matched;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final side = up
        ? Art('assets/svg/memory/$face.svg', key: const ValueKey('up'))
        : const Art('assets/svg/memory/card_back.svg', key: ValueKey('down'));
    return Semantics(
      button: !up,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedOpacity(
          duration: motion(context, ref, 250),
          opacity: matched ? .75 : 1,
          child: AnimatedSwitcher(
            duration: motion(context, ref, 220),
            transitionBuilder: (child, anim) => AnimatedBuilder(
              animation: anim,
              builder: (context, _) => Transform(
                alignment: Alignment.center,
                transform: Matrix4.diagonal3Values(anim.value, 1, 1),
                child: child,
              ),
            ),
            child: side,
          ),
        ),
      ),
    );
  }
}
