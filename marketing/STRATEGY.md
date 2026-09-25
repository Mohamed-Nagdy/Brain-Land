# Brain Land marketing — strategy (1.1.0 update)

**Status: BLOCKED FROM PUBLICATION.** Every post in `posts/` is a finished draft. None may be published, scheduled or boosted until the children's-app gate in `../docs/CHILD_POLICY_REVIEW.md` is cleared: the owner must confirm the Google Play target audience, Families ads declaration and Data safety form, and the App Store age rating / App Privacy answers for 1.1.0, and 1.1.0 must be live on both stores. The Company calendar keeps Brain Land on its PRODUCT GROWTH hold until then.

## Who we talk to

Parents and carers of children about 4–9, Arabic first (Egypt, Saudi Arabia, the Gulf), English second. **Never children.** No posts written to a child, no child-directed ad targeting, no kids' influencers, no contests for children.

## What we say (only what the tested 1.1.0 build does)

| Pillar | Message | Evidence |
|---|---|---|
| Four worlds | Counting and sums, patterns, memory matching and shape sorting, each in its own world | `lib/content/worlds.dart`, `lib/features/mission/*_round.dart` |
| Kind to mistakes | A tip after a mistake, free hints any time, nobody fails | `lib/features/mission/mission_screen.dart`, `round.dart` (`starsFor`) |
| Lots to play | 10,000 missions per world; hand-made first chapter; later chapters generated and checked | `lib/content/missions.dart`, `test/content_test.dart` |
| Arabic first | Arabic and English, RTL/LTR, 123 or ١٢٣ digits, voice guide | `lib/l10n/`, `assets/audio/voice/` |
| Grown-ups in charge | Settings and links behind a grown-up check; no accounts; progress on the device; break reminder | `lib/features/parents/`, `lib/data/store.dart` |
| Ads, honestly | iOS: no ads or tracking. Android: a few child-directed ads between missions, never during a puzzle | `lib/ads/ads.dart`, `ios/AdsStub/` |

Never say: "learn", "smarter", "brain development", "IQ", "educational results", "teacher approved", "best", "#1", "safe for kids" as a guarantee, "no ads" on Android, "ad-free" without the platform. Numbers only as above (4 worlds, 10,000 missions per world, 1–3 stars, 10 missions per chapter).

## Where it goes

Every call to action goes to the Brain Land page on athryza.com (which links to both stores), in the post's language, with UTM tags per `Company/analytics/utm-conventions.md` (`pg_<product>_<yyyymm>`; 202610 is the earliest month the hold could clear):
`https://athryza.com/{ar|en}/work/brain-land?utm_source=<platform>&utm_medium=social&utm_campaign=pg_brainland_202610&utm_content=<post-id>`

## Set

`posts/CALENDAR.md` lists the drafts. Masters are `creative/posts.jobs.json` (stills, rendered with `Company/tools/render.mjs`) and `creative/reel.comp.json` (video, `Company/tools/render-video.mjs`); footage and captures come only from the tested build (`../marketing-captures/2026-09-25/`, `store-assets/raw/`).
