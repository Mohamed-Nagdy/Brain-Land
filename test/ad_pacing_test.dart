import 'package:brain_land/ads/ads.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final start = DateTime(2026, 9, 25, 10);

  test('no interstitial in the first minutes or before two missions', () {
    final p = AdPacing(appStart: start);
    expect(p.isDue(start.add(const Duration(minutes: 10))), isFalse);
    p.missionFinished();
    p.missionFinished();
    expect(p.isDue(start.add(const Duration(minutes: 2))), isFalse);
    expect(p.isDue(start.add(const Duration(minutes: 3))), isTrue);
  });

  test('at least three minutes and two missions between interstitials', () {
    final p = AdPacing(appStart: start);
    p
      ..missionFinished()
      ..missionFinished();
    final first = start.add(const Duration(minutes: 5));
    p.shown(first);
    p
      ..missionFinished()
      ..missionFinished();
    expect(p.isDue(first.add(const Duration(minutes: 2))), isFalse);
    expect(p.isDue(first.add(const Duration(minutes: 3))), isTrue);
    p.shown(first.add(const Duration(minutes: 3)));
    p.missionFinished();
    expect(p.isDue(first.add(const Duration(minutes: 30))), isFalse);
  });
}
