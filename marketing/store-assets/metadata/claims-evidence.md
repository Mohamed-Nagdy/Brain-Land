# Store and website claims → evidence (Brain Land 1.1.0)

Every factual statement in `listing.json`, `captions.json`, the athryza.com page and the marketing drafts maps to code or a test in this repository (branch `feat/brainland-redesign`). Company IDs are in `Company/strategy/inventory/claims.json`.

| Claim | Evidence | Company ID |
|---|---|---|
| Four worlds: Math Forest, Logic Mountain, Memory River, Shape Valley | `lib/content/worlds.dart`; `lib/l10n/app_{en,ar}.arb` (`world*`) | CLM-brain-land-001 |
| Counting, comparing, adding and taking away with objects, ten frame, written sums up to 100 | `lib/content/math_chapter.dart`; `lib/content/missions.dart` (`_MathGen.top` ≤ 100); `test/content_test.dart` "numbers grow" | CLM-brain-land-004 |
| Colour, shape, size and number patterns | `lib/content/logic_chapter.dart`, `missions.dart` (`_LogicGen`) | CLM-brain-land-004 |
| Memory boards from 2 to 8 pairs | `lib/content/memory_chapter.dart`, `missions.dart` (`_memory`); test "boards have 2–8 distinct pairs" | CLM-brain-land-004 |
| Drag or tap shapes home, incl. turned, big and small | `lib/features/mission/shape_round.dart`; `missions.dart` (`_ShapeGen`); test "every piece fits exactly one slot" | CLM-brain-land-004 |
| 10,000 missions per world, chapters of 10, hand-written first chapter, later chapters generated and checked | `lib/content/worlds.dart` (`kChapters = 1000`, `kMissionsPerChapter = 10`); `missions.dart`; `test/content_test.dart` (all 40,000 missions checked) | CLM-brain-land-007 |
| Tip after a mistake, free hints, nobody fails | `lib/features/mission/mission_screen.dart` (`_onEvent`, `_hint`); `round.dart` (`starsFor` ≥ 1) | CLM-brain-land-008 |
| 1–3 stars per mission, a medal per chapter | `round.dart` (`starsFor`); `lib/data/store.dart` (`record`, `chapterDone`); `test/store_test.dart` | CLM-brain-land-003 |
| Break reminder every few missions | `lib/features/mission/done_screen.dart` (`_break`: every 3rd mission) | CLM-brain-land-012 |
| Arabic and English, RTL/LTR, 123 or ١٢٣ digits | `lib/l10n/`; `lib/app.dart` (locale); `lib/core/motion.dart` (`digits`); `test/project_rules_test.dart` (string parity); iPad Arabic run | CLM-brain-land-009 |
| Voiced lines | `assets/audio/voice/{en,ar}/`; `lib/core/audio.dart`; `assets/audio/voice/check-{en,ar}.json` | CLM-brain-land-013 |
| Settings and links behind a grown-up check; no accounts; progress on device | `lib/features/parents/parent_gate.dart`, `parents_screen.dart`; `test/parent_gate_test.dart`; `lib/data/store.dart` | CLM-brain-land-010 |
| Sound, voice and reduced-motion settings | `lib/features/parents/parents_screen.dart`; `lib/core/motion.dart` | CLM-brain-land-010 |
| iOS: no ads, analytics or tracking | `ios/Podfile` + `ios/AdsStub/`; `ios/Podfile.lock`; `ios/Runner/Info.plist`; `test/project_rules_test.dart` | CLM-brain-land-011 |
| Android: child-directed ads between missions only, never during a puzzle, no advertising ID | `lib/ads/ads.dart` (`AgeRestrictedTreatment.child`, `AdPacing`, banner only on map/world); `AndroidManifest.xml` (`AD_ID` removed); `test/ad_pacing_test.dart` | CLM-brain-land-011 |
| Original artwork, sounds and content | `assets/PROVENANCE.md`, `assets/svg/README.md`, `tools/audio/` | — |
| Available on Google Play and the App Store | `Company/strategy/inventory/destinations.json` (`brain-land.play`, `brain-land.ios`) | CLM-brain-land-006 |

Not claimed anywhere: learning outcomes, "brain development", IQ, age-specific results, ratings, download counts, awards, "no ads" for Android.
