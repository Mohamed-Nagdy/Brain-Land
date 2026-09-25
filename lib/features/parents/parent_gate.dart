import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/art.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';
import '../../data/store.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/widgets.dart';

/// Opens the parents' area after the grown-up check.
Future<void> openParents(BuildContext context) async {
  if (await passParentGate(context) && context.mounted) {
    context.push('/parents');
  }
}

/// Grown-up check: three numbers written as words must be tapped in order.
/// Young children who can't read yet can't pass it by trial and error.
Future<bool> passParentGate(BuildContext context, {Random? random}) async =>
    await showDialog<bool>(
      context: context,
      builder: (_) => ParentGate(random: random),
    ) ??
    false;

class ParentGate extends ConsumerStatefulWidget {
  const ParentGate({super.key, this.random});

  final Random? random;

  @override
  ConsumerState<ParentGate> createState() => _ParentGateState();
}

class _ParentGateState extends ConsumerState<ParentGate> {
  late final Random _random = widget.random ?? Random();
  late List<int> _code = _newCode();
  final _entered = <int>[];
  bool _wrong = false;

  List<int> _newCode() =>
      ([...List.generate(9, (i) => i + 1)]..shuffle(_random)).take(3).toList();

  static const _en = [
    'zero',
    'one',
    'two',
    'three',
    'four',
    'five',
    'six',
    'seven',
    'eight',
    'nine',
  ];
  static const _ar = [
    'صفر',
    'واحد',
    'اثنان',
    'ثلاثة',
    'أربعة',
    'خمسة',
    'ستة',
    'سبعة',
    'ثمانية',
    'تسعة',
  ];

  void _press(int d) {
    setState(() {
      _entered.add(d);
      _wrong = false;
    });
    if (_entered.length < _code.length) return;
    if (_entered.join() == _code.join()) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        _wrong = true;
        _entered.clear();
        _code = _newCode();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final words = Localizations.localeOf(context).languageCode == 'ar'
        ? _ar
        : _en;
    final eastern = ref.watch(settingsProvider).easternDigits;
    final text = Theme.of(context).textTheme;
    return Dialog(
      backgroundColor: Palette.paper,
      shape: const RoundedRectangleBorder(borderRadius: Radii.card),
      child: Padding(
        padding: const EdgeInsets.all(Space.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const GameIcon(Ico.parents, size: 44),
                const SizedBox(width: Space.s),
                Expanded(child: Text(l.gateTitle, style: text.headlineSmall)),
                IconBubble(
                  Ico.close,
                  label: l.close,
                  size: 48,
                  onPressed: () => Navigator.pop(context, false),
                ),
              ],
            ),
            const SizedBox(height: Space.m),
            Text(
              l.gatePrompt(
                _code.map((d) => words[d]).join(words == _ar ? '، ' : ', '),
              ),
              style: text.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 28,
              child: _wrong
                  ? Text(
                      l.gateWrong,
                      style: text.bodyMedium?.copyWith(color: Palette.oops),
                    )
                  : null,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < 3; i++)
                  Container(
                    width: 18,
                    height: 18,
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < _entered.length
                          ? Palette.purple
                          : Colors.transparent,
                      border: Border.all(color: Palette.purple, width: 2),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: Space.m),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Wrap(
                spacing: Space.s,
                runSpacing: Space.s,
                alignment: WrapAlignment.center,
                children: [
                  for (final d in [1, 2, 3, 4, 5, 6, 7, 8, 9, 0])
                    SizedBox(
                      width: 64,
                      height: 56,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: const RoundedRectangleBorder(
                            borderRadius: Radii.chip,
                          ),
                          side: const BorderSide(
                            color: Palette.purpleLight,
                            width: 2,
                          ),
                        ),
                        onPressed: () => _press(d),
                        child: Text(
                          digits(d, eastern: eastern),
                          style: text.titleLarge,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
