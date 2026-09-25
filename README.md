# Brain Land

A puzzle adventure for young children by **ATHRYZA Technologies**. A brain explorer guides players through four worlds (Math Forest, Logic Mountain, Memory River and Shape Valley) in short missions, with tips after mistakes, free hints and stars. Arabic first, with English.

- Android `com.mohamednagdy.brainland` · iOS `com.mohamednagdy.brainlands` · version in `pubspec.yaml`.
- Web page: https://athryza.com/en/work/brain-land · privacy: https://athryza.com/en/privacy#brain-land

## Layout

| Path | What |
|---|---|
| `lib/content/` | Worlds, the hand-written first chapters (`*_chapter.dart`) and the seeded generators for the other 999 chapters per world (`missions.dart`) |
| `lib/features/` | `map`, `world` (chapter path), `mission` (the round widgets, results and breaks), `parents` (grown-up check and settings) |
| `lib/core/` | Theme tokens, art (`art.dart`: every picture is a custom SVG), audio, voice lines, motion helpers |
| `lib/data/` | Settings and progress in one Hive box; one-time import of 1.0 progress |
| `lib/ads/` | Child-directed AdMob on Android and iOS: labelled banner on menus, paced interstitial between missions |
| `assets/svg/` | Original artwork (see `assets/PROVENANCE.md`) |
| `assets/audio/` | Synthesized sound effects (`tools/audio/make_sfx.sh`) and the voice guide (`tools/audio/make_voice.py`, `check_voice.py`) |
| `docs/` | `CHILD_POLICY_REVIEW.md` (store policy decisions and console checklist), `TEST_EVIDENCE.md` |
| `marketing/` | `store-assets/` (store package and tools), strategy and claims. Social posts live in the Company marketing system |

## Develop

```sh
flutter pub get
flutter gen-l10n
flutter analyze
flutter test                     # rules, 40,000-mission content checks, storage, migration, ads pacing, gate
flutter drive --driver test_driver/integration_test.dart --target integration_test/app_test.dart \
  -d <device> --dart-define=LANG=ar --dart-define=BRAINLAND_NO_ADS=true   # full mission in every world
```

Rules the tests enforce: no emoji or stock icon sets anywhere in `lib/` (custom SVG only), Arabic and English strings in step, no Firebase / tracking SDKs, no notification or tracking permissions.

Release signing reads `android/key.properties` (never committed).
