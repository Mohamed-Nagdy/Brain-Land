import 'dart:math';

import 'package:brain_land/data/store.dart';
import 'package:brain_land/features/parents/parent_gate.dart';
import 'package:brain_land/l10n/app_localizations.dart';
import 'package:brain_land/ui/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'helpers.dart';

const _words = [
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

void main() {
  late Box<dynamic> store;
  setUp(() async => store = await openTestStore());
  tearDown(() => Hive.close());

  Future<Future<bool>> openGate(WidgetTester tester) async {
    late Future<bool> result;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [storeProvider.overrideWithValue(store)],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () =>
                  result = passParentGate(context, random: Random(7)),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return result;
  }

  List<int> promptedCode(WidgetTester tester) {
    final prompt = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .firstWhere((t) => t.startsWith('Tap these numbers'));
    return prompt
        .split(':')
        .last
        .split(',')
        .map((w) => _words.indexOf(w.trim()))
        .toList();
  }

  testWidgets('the gate opens only for the numbers written as words', (
    tester,
  ) async {
    final result = await openGate(tester);
    final code = promptedCode(tester);
    expect(code, hasLength(3));
    expect(code.every((d) => d > 0), isTrue);

    // A wrong sequence is rejected and a new challenge appears.
    for (final d in [code[1], code[0], code[2]]) {
      await tester.tap(find.widgetWithText(OutlinedButton, '$d'));
    }
    await tester.pumpAndSettle();
    expect(find.text('Not quite. Try again.'), findsOneWidget);

    for (final d in promptedCode(tester)) {
      await tester.tap(find.widgetWithText(OutlinedButton, '$d'));
    }
    await tester.pumpAndSettle();
    expect(await result, isTrue);
  });

  testWidgets('closing the gate does not open the parents area', (
    tester,
  ) async {
    final result = await openGate(tester);
    await tester.tap(find.byType(IconBubble));
    await tester.pumpAndSettle();
    expect(await result, isFalse);
  });
}
