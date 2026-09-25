# Brain Land 1.1.0 (2) — test evidence (2026-09-25)

Toolchain: Flutter 3.44.8 (stable), Xcode 27.0, macOS 27.0, iOS Simulator runtime iOS 27.0 (24A434), Android emulator images API 36 (Android 16). Branch `feat/brainland-redesign`.

## Automated

| Check | Result |
|---|---|
| `flutter analyze` | No issues |
| `flutter test` (25 tests) | All pass: 40,000-mission content checks (answers, choices, repetition, shape bijection, difficulty growth), progress persistence / restart / medals / reset, 1.0 → 1.1 progress import, ad pacing, parental gate, project rules (no stock icons or emoji, AR/EN string parity, no Firebase / ATT / notification permission, Privacy Sandbox permissions removed, version in sync) |
| Voice round trip (`tools/audio/check_voice.py`) | English 32/32 ≥ 0.75 (Whisper small); Arabic 18/32 ≥ 0.9 (Whisper medium), the other 14 lines ship as text only |

## Full mission in every world on devices (`integration_test/app_test.dart`)

The run plays mission 1 of Math Forest, Logic Mountain, Memory River and Shape Valley, with a wrong answer, a hint, pause and continue, backgrounding and resuming, completion (stars saved), the break reminder, the chapter path, an app restart that must restore every world's stars, and the parental gate.

| Device | Locale | Result |
|---|---|---|
| iPhone 17 simulator, iOS 27.0 | en | pass |
| iPhone 18 Pro Max simulator, iOS 27.0 (1320×2868) | en, ar | pass, pass |
| iPad Pro 13-inch (M5) simulator, iOS 27.0 (2064×2752) | ar, en | pass, pass |
| Android emulator BrainLand_Phone, API 36 (1080×1920, 420 dpi) | en | pass |
| Android emulator, Arabic / tablet | ar | **not completed**: Gradle inside `flutter drive` hung twice and the emulators were shut down by another session; retry is scripted (`marketing/store-assets/tools/capture.sh` builds first) |

Capture runs are built with `BRAINLAND_NO_ADS=true`, so no ad appears in any store or marketing image.

## Manual checks

- First launch (clean install, iOS and Android): straight to the map, no system prompts. v1.0 showed the notification prompt first (`evidence/baseline-1.0-ios-launch-prompt.png`) and 187★ / 425 coins on a fresh map (`evidence/baseline-1.0-android-map.png`).
- Ads with test units (normal debug builds): labelled banner loads on the map on iOS and Android, no ATT prompt (`evidence/internal-ads-check-{ios,android}.png`, internal only).
- Layout reviewed from the captures: Arabic RTL and English LTR on iPhone 6.9" and iPad 13"; pattern-row overflow on iPhone fixed; tablet scaling and a four-column landscape map added after review.

## Builds

| Build | Result |
|---|---|
| `flutter build ios --release --no-codesign` | Runner.app 27.9 MB |
| `flutter build appbundle --release` | app-release.aab 60.6 MB, signed with the local upload key — **reset that key before uploading** (it was public on GitHub) |
| Merged release manifest (Android) | INTERNET, ACCESS_NETWORK_STATE, WAKE_LOCK, FOREGROUND_SERVICE (library defaults) only; no AD_ID, no ACCESS_ADSERVICES_*, no POST_NOTIFICATIONS |

## Not verified here

- The upgrade from the live 1.0 store build on a real device (covered by `test/legacy_import_test.dart` with 1.0's exact byte format).
- Physical devices, TalkBack / VoiceOver passes, and a native Arabic speaker's review of text and voice.
- Store console declarations (see `CHILD_POLICY_REVIEW.md`).
