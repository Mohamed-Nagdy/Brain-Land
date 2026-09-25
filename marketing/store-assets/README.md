# Brain Land by ATHRYZA: store assets (1.1.0)

Generated from code and from real captures of the tested 1.1.0 build. **Nothing has been uploaded to either store** and no live listing was edited. The owner uploads after the console declarations in `../../docs/CHILD_POLICY_REVIEW.md` are confirmed.

## Official requirements (checked 2026-09-25)

| Asset | Requirement | Source |
|---|---|---|
| Play icon | 512×512 32-bit PNG, ≤1024 KB | [Play Console: preview assets](https://support.google.com/googleplay/android-developer/answer/9866151) |
| Play feature graphic | 1024×500 JPEG or 24-bit PNG, no alpha; one per language | same page |
| Play phone screenshots | 2–8, JPEG / 24-bit PNG, no alpha, each side 320–3840 px, long side ≤ 2× short → **1080×1920** | same page |
| Play 10" tablet screenshots | 1080–7680 px, 16:9 or 9:16 → **2560×1600** | same page |
| Play text | Title 30 · Short description 80 · Full description 4000 | [Play Console: store listing](https://support.google.com/googleplay/android-developer/answer/9859152) |
| iPhone screenshots | 6.9" **1320×2868**; 1–10 per locale; PNG/JPEG, no alpha | [App Store Connect: screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/) |
| iPad screenshots | 13" **2064×2752** (the app runs on iPad) | same page |
| App Store icon | 1024×1024 PNG, opaque | [HIG: App icons](https://developer.apple.com/design/human-interface-guidelines/app-icons) |
| App Store text | Name 30 · Subtitle 30 · Promotional text 170 · Description 4000 · Keywords 100 bytes | [App information](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information) |
| Kids rules | Kids Category: no third-party ads/analytics, parental gate for links and purchases (guideline 1.3); outside it, no child-audience wording (5.1.4 applies either way) | [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) |

## Layout

```
source/                  icon-1024.png (App Store, opaque), icon-512.png (Play),
                         feature-graphic-{ar,en}.png (1024×500), cover-1200x630.png (athryza.com share image)
raw/<target>-<locale>/   captures from integration_test/app_test.dart (flutter drive), + raw/runs.json
android/phone/<locale>/          1080×1920 Play phone screenshots (8)
android/tablet-10/<locale>/      2560×1600 Play 10" tablet screenshots (8)
ios/iphone-6.9/<locale>/         1320×2868 App Store iPhone screenshots (10)
ios/ipad-13/<locale>/            2064×2752 App Store iPad screenshots (10)
metadata/listing.json            all listing text, ar + en, both stores, plus category / age suggestions
metadata/captions.json           screenshot captions
metadata/claims-evidence.md      every public claim → code / test evidence
metadata/privacy-disclosures.md  Data safety and App Privacy answers
manifest.json                    every asset: store field, size, locale, device, source capture hash, validation
```

## Reproduce

1. `python tools/make_graphics.py` — icons, feature graphics, cover (resvg + Pillow with libraqm).
2. `tools/capture.sh <device> <android-phone|android-tablet|ios-iphone69|ios-ipad13> <ar|en> "<device description>"` — runs the full-mission integration test on the device (ads off for captures) and copies its screenshots into `raw/`.
3. `python tools/frame.py` — frames the captures and writes `manifest.json`; fails on a wrong size or alpha.
4. `python tools/check_listing.py` — fails if any listing field is over its limit.

Framing only scales each capture and adds a caption above it. Screen content is never edited. The only data on screen is the game's own content and the stars earned during the automated run; there are no names, accounts or personal data in the app.
