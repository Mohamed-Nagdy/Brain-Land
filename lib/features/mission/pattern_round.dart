import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/logic_chapter.dart';
import '../../content/token.dart';
import '../../core/art.dart';
import '../../core/audio.dart';
import '../../core/lines.dart';
import '../../core/names.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';
import '../../data/store.dart';
import '../../l10n/app_localizations.dart';
import 'choice.dart';
import 'round.dart';

class PatternRound extends ConsumerStatefulWidget {
  const PatternRound({
    super.key,
    required this.task,
    required this.hintLevel,
    required this.onEvent,
  });

  final PatternTask task;

  /// 1: outline the repeating part (or show the number step).
  final int hintLevel;
  final RoundListener onEvent;

  static Line instruction(PatternTask t) =>
      t.gap == t.cells.length - 1 ? Line.instrPattern : Line.instrPatternGap;

  @override
  ConsumerState<PatternRound> createState() => _PatternRoundState();
}

class _PatternRoundState extends ConsumerState<PatternRound> {
  final _tried = <int>{};
  bool _solved = false;
  int _shakes = 0;
  int? _shaking;

  PatternTask get t => widget.task;

  void _pick(int i) {
    if (_solved) return;
    if (t.choices[i] == t.answer) {
      setState(() => _solved = true);
      widget.onEvent(const RoundEvent.solved());
      return;
    }
    ref.read(audioProvider).play(Sfx.oops);
    setState(() {
      _tried.add(i);
      _shaking = i;
      _shakes++;
    });
    widget.onEvent(const RoundEvent.mistake(Line.mistakePattern));
  }

  @override
  Widget build(BuildContext context) {
    final eastern = ref.watch(settingsProvider).easternDigits;
    return LayoutBuilder(
      builder: (context, box) {
        final cells = t.cells.length;
        // Container padding plus, per cell, its margin and the hint border.
        final cell = ((box.maxWidth - Space.m - Space.s) / cells - 12).clamp(
          20.0,
          96.0,
        );
        final choice = box.maxWidth > 600 ? 120.0 : 92.0;
        final hint = widget.hintLevel > 0;
        return Column(
          children: [
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(Space.s),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .9),
                    borderRadius: Radii.card,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < cells; i++)
                        _Cell(
                          size: cell,
                          highlighted: hint && !t.isNumbers && i < t.unit.abs(),
                          step: hint && t.isNumbers && i > 0 ? t.unit : null,
                          eastern: eastern,
                          child: t.cells[i] == null
                              ? (_solved
                                    ? _tokenView(t.answer, cell, eastern)
                                    : _Gap(size: cell))
                              : _tokenView(t.cells[i]!, cell, eastern),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: Space.m,
              children: [
                for (var i = 0; i < t.choices.length; i++)
                  ChoiceTile(
                    key: ValueKey('choice-$i'),
                    state: _solved && t.choices[i] == t.answer
                        ? ChoiceState.right
                        : _tried.contains(i)
                        ? ChoiceState.tried
                        : ChoiceState.idle,
                    size: choice,
                    shakes: _shaking == i ? _shakes : 0,
                    semanticLabel: _describe(t.choices[i], eastern),
                    onTap: () => _pick(i),
                    child: _tokenView(t.choices[i], choice * .8, eastern),
                  ),
              ],
            ),
            const SizedBox(height: Space.l),
          ],
        );
      },
    );
  }

  String _describe(Token token, bool eastern) => token.isNumber
      ? digits(token.number!, eastern: eastern)
      : shapeName(token.shape, AppLocalizations.of(context));
}

Widget _tokenView(Token token, double size, bool eastern) => token.isNumber
    ? SizedBox.square(
        dimension: size,
        child: Center(
          child: NumberText(
            digits(token.number!, eastern: eastern),
            size: size * .55,
          ),
        ),
      )
    : TokenArt(token, size: size);

class _Cell extends StatelessWidget {
  const _Cell({
    required this.size,
    required this.child,
    required this.highlighted,
    required this.step,
    required this.eastern,
  });

  final double size;
  final Widget child;
  final bool highlighted;
  final int? step;
  final bool eastern;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: highlighted ? const Color(0xFFFFF0C2) : Colors.transparent,
          borderRadius: Radii.chip,
          border: Border.all(
            color: highlighted ? Palette.gold : Colors.transparent,
            width: 3,
          ),
        ),
        child: child,
      ),
      SizedBox(
        height: 24,
        child: step == null
            ? null
            : Text(
                '${step! > 0 ? '+' : '−'}${digits(step!.abs(), eastern: eastern)}',
                textDirection: TextDirection.ltr,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: Palette.purple),
              ),
      ),
    ],
  );
}

class _Gap extends StatelessWidget {
  const _Gap({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: const Color(0xFFF3EEFF),
      borderRadius: Radii.chip,
      border: Border.all(color: Palette.purpleLight, width: 3),
    ),
    alignment: Alignment.center,
    child: Text(
      '?',
      style: Theme.of(
        context,
      ).textTheme.headlineMedium?.copyWith(color: Palette.purple),
    ),
  );
}
