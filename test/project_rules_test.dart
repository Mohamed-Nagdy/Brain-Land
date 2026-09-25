import 'dart:convert';
import 'dart:io';

import 'package:brain_land/app.dart';
import 'package:brain_land/core/lines.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final dartFiles = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart') && !f.path.contains('/l10n/'));

  test('no stock icons or emoji anywhere in the app (custom SVG only)', () {
    final emoji = RegExp(
      r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}\u{2B50}\u{1F000}-\u{1F2FF}]',
      unicode: true,
    );
    for (final f in dartFiles) {
      final src = f.readAsStringSync();
      expect(
        src.contains('Icons.'),
        isFalse,
        reason: '${f.path} uses Material Icons',
      );
      expect(
        src.contains('CupertinoIcons'),
        isFalse,
        reason: '${f.path} uses Cupertino icons',
      );
      expect(emoji.hasMatch(src), isFalse, reason: '${f.path} contains emoji');
    }
  });

  test('every art file the code references exists', () {
    final paths = <String>{};
    final literal = RegExp(r"assets/svg/[a-z_/]+\.svg");
    for (final f in dartFiles) {
      paths.addAll(
        literal.allMatches(f.readAsStringSync()).map((m) => m.group(0)!),
      );
    }
    for (final p in paths) {
      expect(File(p).existsSync(), isTrue, reason: 'missing $p');
    }
  });

  test('Arabic and English have the same strings', () {
    Map<String, dynamic> load(String l) =>
        jsonDecode(File('lib/l10n/app_$l.arb').readAsStringSync())
            as Map<String, dynamic>;
    Set<String> keys(Map<String, dynamic> m) =>
        m.keys.where((k) => !k.startsWith('@')).toSet();
    final en = load('en'), ar = load('ar');
    expect(keys(ar), keys(en));
    for (final k in keys(en)) {
      expect((ar[k] as String).trim(), isNotEmpty, reason: k);
    }
    for (final line in Line.values) {
      expect(
        en.containsKey(line.name),
        isTrue,
        reason: 'Line.${line.name} has no string',
      );
    }
  });

  test('app version matches pubspec', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(
      RegExp(
        r'^version: (\S+)\+',
        multiLine: true,
      ).firstMatch(pubspec)!.group(1),
      kAppVersion,
    );
  });

  test('no Firebase, tracking or messaging SDKs', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    for (final sdk in [
      'firebase',
      'app_tracking_transparency',
      'google_fonts',
      'share_plus',
    ]) {
      expect(pubspec.contains(sdk), isFalse, reason: sdk);
    }
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    expect(manifest.contains('android.permission.POST_NOTIFICATIONS'), isFalse);
    expect(manifest.contains('permission.AD_ID" tools:node="remove"'), isTrue);
    final plist = File('ios/Runner/Info.plist').readAsStringSync();
    expect(plist.contains('NSUserTrackingUsageDescription'), isFalse);
    expect(plist.contains('GADApplicationIdentifier'), isFalse);
  });
}
