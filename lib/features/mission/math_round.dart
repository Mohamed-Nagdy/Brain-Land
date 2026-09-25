import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/math_chapter.dart';
import '../../core/art.dart';
import '../../core/audio.dart';
import '../../core/lines.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';
import '../../data/store.dart';
import '../../l10n/app_localizations.dart';
import 'choice.dart';
import 'round.dart';

class MathRound extends ConsumerStatefulWidget {
  const MathRound({
    super.key,
    required this.task,
    required this.hintLevel,
    required this.onEvent,
  });

  final MathTask task;

  /// 1: count together (tasks with objects), then: hide a wrong answer.
  final int hintLevel;
  final RoundListener onEvent;

  static int maxHints(MathTask t) =>
      t.kind == MathKind.equation ||
          t.kind == MathKind.missing ||
          t.kind == MathKind.compare
      ? 1
      : 2;

  static Line hintLine(MathTask t, int level) => level == 1 && maxHints(t) == 2
      ? Line.hintCountTogether
      : Line.hintRemoveOne;

  static Line instruction(MathTask t) => switch (t.kind) {
    MathKind.count => Line.instrCount,
    MathKind.compare => Line.instrMore,
    MathKind.add => Line.instrAdd,
    MathKind.takeAway => Line.instrTakeAway,
    MathKind.fillTen => Line.instrMissing,
    MathKind.equation => Line.instrSolve,
    MathKind.missing => Line.instrMissingNumber,
  };

  @override
  ConsumerState<MathRound> createState() => _MathRoundState();
}

class _MathRoundState extends ConsumerState<MathRound> {
  final _tried = <int>{};
  int? _right;
  int _shakes = 0;
  int? _shaking;

  MathTask get t => widget.task;

  bool get _countTogether =>
      widget.hintLevel >= 1 && MathRound.maxHints(t) == 2;

  /// The wrong option a "hide one" hint removes: the operation mix-up first.
  int? get _hiddenOption {
    final needed = MathRound.maxHints(t);
    if (widget.hintLevel < needed || t.kind == MathKind.compare) return null;
    final wrong = t.options.entries
        .where((e) => e.key != t.answer && !_tried.contains(e.key))
        .toList();
    if (wrong.length < 2) return null;
    int isMixUp(MapEntry<int, MathMistake> e) =>
        e.value == MathMistake.wrongOperation ? 1 : 0;
    wrong.sort((a, b) {
      final mixUp = isMixUp(b) - isMixUp(a);
      return mixUp != 0
          ? mixUp
          : (b.key - t.answer).abs() - (a.key - t.answer).abs();
    });
    return wrong.first.key;
  }

  void _pick(int value) {
    if (_right != null) return;
    final audio = ref.read(audioProvider);
    if (value == t.answer) {
      setState(() => _right = value);
      widget.onEvent(const RoundEvent.solved());
      return;
    }
    audio.play(Sfx.oops);
    setState(() {
      _tried.add(value);
      _shaking = value;
      _shakes++;
    });
    final why = t.kind == MathKind.compare
        ? MathMistake.other
        : t.options[value]!;
    widget.onEvent(
      RoundEvent.mistake(switch (why) {
        _ when t.kind == MathKind.compare => Line.mistakeCompare,
        MathMistake.wrongOperation when t.kind != MathKind.missing =>
          t.subtracts
              ? Line.mistakeAddedInstead
              : Line.mistakeSubtractedInstead,
        MathMistake.offByOne
            when t.kind != MathKind.equation && t.kind != MathKind.missing =>
          Line.mistakeCountAgain,
        _ => Line.mistakeTryAgain,
      }),
    );
  }

  ChoiceState _stateOf(int value) {
    if (_right == value) return ChoiceState.right;
    if (_tried.contains(value)) return ChoiceState.tried;
    if (_hiddenOption == value) return ChoiceState.hidden;
    return ChoiceState.idle;
  }

  @override
  Widget build(BuildContext context) {
    final eastern = ref.watch(settingsProvider).easternDigits;
    String n(int v) => digits(v, eastern: eastern);
    return LayoutBuilder(
      builder: (context, box) {
        final wide = box.maxWidth > 600;
        final tile = wide ? 110.0 : 84.0;
        if (t.kind == MathKind.compare) return _compare(box, n);
        return Column(
          children: [
            Expanded(child: Center(child: _picture(box, n))),
            if (t.kind != MathKind.count && t.kind != MathKind.compare)
              _equation(n, wide),
            const SizedBox(height: Space.m),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: Space.m,
              runSpacing: Space.m,
              children: [
                for (final v in (t.options.keys.toList()..sort()))
                  ChoiceTile(
                    key: ValueKey('choice-$v'),
                    state: _stateOf(v),
                    size: tile,
                    shakes: _shaking == v ? _shakes : 0,
                    semanticLabel: n(v),
                    onTap: () => _pick(v),
                    child: NumberText(n(v), size: tile * .5),
                  ),
              ],
            ),
            const SizedBox(height: Space.m),
          ],
        );
      },
    );
  }

  Widget _equation(String Function(int) n, bool wide) {
    final eastern = ref.read(settingsProvider).easternDigits;
    final (a, op, b) = switch (t.kind) {
      MathKind.takeAway => (t.a, '−', t.b),
      MathKind.fillTen => (t.a, '+', null),
      MathKind.equation => (t.a, t.minus ? '−' : '+', t.b),
      _ => (t.a, '+', t.b),
    };
    final q = eastern ? '؟' : '?';
    final shown = _right != null ? n(_right!) : q;
    final text = t.kind == MathKind.fillTen
        ? '${n(a)} + $shown = ${n(10)}'
        : t.kind == MathKind.missing
        ? '${n(t.a)} + $shown = ${n(t.b)}'
        : '${n(a)} $op ${n(b!)} = $shown';
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Space.l,
        vertical: Space.xs,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: Radii.chip,
      ),
      child: Text(
        text,
        textDirection: eastern ? TextDirection.rtl : TextDirection.ltr,
        style: Theme.of(context).textTheme.displaySmall?.copyWith(
          fontSize: t.kind == MathKind.equation || t.kind == MathKind.missing
              ? (wide ? 72 : 56)
              : 40,
        ),
      ),
    );
  }

  Widget _picture(BoxConstraints box, String Function(int) n) {
    final counter = 'assets/svg/math/${t.counter.name}.svg';
    switch (t.kind) {
      case MathKind.equation:
      case MathKind.missing:
        return const SizedBox.shrink();
      case MathKind.fillTen:
        return _TenFrame(
          filled: t.a,
          counter: counter,
          answer: _right,
          maxWidth: box.maxWidth,
        );
      case MathKind.count:
        return _Counters(
          count: t.a,
          counter: counter,
          maxWidth: box.maxWidth,
          numbered: _countTogether,
          n: n,
        );
      case MathKind.add:
        return Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: Space.s,
          children: [
            _Counters(
              count: t.a,
              counter: counter,
              maxWidth: box.maxWidth * .42,
              numbered: _countTogether,
              n: n,
            ),
            Text('+', style: Theme.of(context).textTheme.displaySmall),
            _Counters(
              count: t.b,
              counter: counter,
              maxWidth: box.maxWidth * .42,
              numbered: _countTogether,
              n: n,
              startAt: t.a + 1,
            ),
          ],
        );
      case MathKind.takeAway:
        return _Counters(
          count: t.a,
          counter: counter,
          maxWidth: box.maxWidth,
          crossedOut: t.b,
          numbered: _countTogether,
          n: n,
        );
      case MathKind.compare:
        return const SizedBox.shrink();
    }
  }

  Widget _compare(BoxConstraints box, String Function(int) n) {
    final l = AppLocalizations.of(context);
    final counter = 'assets/svg/math/${t.counter.name}.svg';
    Widget side(int index, int count, String label) => Expanded(
      child: Padding(
        padding: const EdgeInsets.all(Space.s),
        child: ChoiceTile(
          key: ValueKey('choice-$index'),
          state: _stateOf(index),
          size: box.maxWidth / 2 - Space.l,
          shakes: _shaking == index ? _shakes : 0,
          semanticLabel: label,
          onTap: () => _pick(index),
          child: Padding(
            padding: const EdgeInsets.all(Space.s),
            child: _Counters(
              count: count,
              counter: counter,
              maxWidth: box.maxWidth / 2 - Space.xl,
              numbered: _countTogether,
              n: n,
            ),
          ),
        ),
      ),
    );
    return Center(
      child: Row(
        children: [side(0, t.a, l.a11yGroupA), side(1, t.b, l.a11yGroupB)],
      ),
    );
  }
}

/// Objects laid out in rows of five so amounts can be seen at a glance.
class _Counters extends StatelessWidget {
  const _Counters({
    required this.count,
    required this.counter,
    required this.maxWidth,
    required this.numbered,
    required this.n,
    this.crossedOut = 0,
    this.startAt = 1,
  });

  final int count;
  final String counter;
  final double maxWidth;
  final bool numbered;
  final String Function(int) n;
  final int crossedOut;
  final int startAt;

  @override
  Widget build(BuildContext context) {
    final perRow = count <= 5 ? count : 5;
    final size = (maxWidth / (perRow.clamp(1, 5) + .5)).clamp(28.0, 104.0);
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      runSpacing: 4,
      children: [
        for (var i = 0; i < count; i++)
          SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: i >= count - crossedOut ? .4 : 1,
                  child: Art(counter, width: size, height: size),
                ),
                if (i >= count - crossedOut)
                  GameIcon(Ico.close, size: size * .8),
                if (numbered && i < count - crossedOut)
                  PositionedDirectional(
                    bottom: 0,
                    end: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: const BoxDecoration(
                        color: Palette.purple,
                        borderRadius: Radii.chip,
                      ),
                      child: Text(
                        n(startAt + i),
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// A 2 × 5 frame: filled cells hold objects, empty cells show what is missing.
class _TenFrame extends StatelessWidget {
  const _TenFrame({
    required this.filled,
    required this.counter,
    required this.answer,
    required this.maxWidth,
  });

  final int filled;
  final String counter;
  final int? answer;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final cell = ((maxWidth - Space.xl) / 5).clamp(40.0, 88.0);
    return Container(
      padding: const EdgeInsets.all(Space.s),
      decoration: BoxDecoration(
        color: Palette.sand,
        borderRadius: Radii.chip,
        border: Border.all(color: const Color(0xFFC9AE82), width: 3),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var row = 0; row < 2; row++)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var col = 0; col < 5; col++)
                  Container(
                    width: cell,
                    height: cell,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0x55C9AE82),
                        width: 2,
                      ),
                    ),
                    child: row * 5 + col < filled + (answer ?? 0)
                        ? Opacity(
                            opacity: row * 5 + col < filled ? 1 : .55,
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Art(counter),
                            ),
                          )
                        : null,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
