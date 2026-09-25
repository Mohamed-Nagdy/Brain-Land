# Brain Land — children's-app policy and monetization review

Checked: **2026-09-25**. Build reviewed: **1.1.0 (2)**, branch `feat/brainland-redesign`.
Quotes come from the official pages below; re-read them before quoting in store or legal copy.

## Decision

| Platform | Monetization in 1.1.0 | Why |
|---|---|---|
| Android (Google Play) | AdMob only, child-directed: `ageRestrictedTreatment: child`, `maxAdContentRating: G`, `nonPersonalizedAds: true`. One labelled banner on the map and world screens; one interstitial at a mission break, at most every 3 minutes and every 2 missions, never in the first 3 minutes. No rewarded, app-open or in-puzzle ads. | Play Families policy allows ads from Families Self-Certified SDKs (AdMob ≥ 19.0.0/20.6.0) with no personalization, not on launch, closable, one placement per page. |
| iOS (App Store) | **No ads, no analytics, no tracking.** The ads plugin is replaced by a no-op stub pod (`ios/AdsStub`), so the Google Mobile Ads SDK is not in the binary. | Guideline 5.1.4: "Apps intended primarily for kids should not include third-party analytics or third-party advertising." This applies inside or outside the Kids Category. AdMob does not publish Kids-Category human-review practices (1.3 exception). |

Removed in 1.1.0 (all platforms): app-open ads, rewarded "+100 coins" ads, ad-gated hints (hints are free), interstitials after every level, App Tracking Transparency prompt and IDFA/AAID reads, Firebase Analytics, Firebase Cloud Messaging and the launch notification prompt, `AD_ID` permission (now `tools:node="remove"`), `POST_NOTIFICATIONS`, the stray `magicmind.app` ad `contentUrl`, `google_fonts` runtime font downloads (font is bundled).

First launch now opens straight onto the map: no system dialogs (verified on iOS 26 Simulator and Android emulator, see `docs/TEST_EVIDENCE.md`).

## Evidence in code

- `lib/ads/ads.dart` — the only ads code; `Ads.supported` is Android-only; child request configuration; `AdPacing` (tested in `test/ad_pacing_test.dart`).
- `android/app/src/main/AndroidManifest.xml` — `INTERNET` only; `AD_ID` removed.
- `ios/Podfile` + `ios/AdsStub/` — iOS links no ads SDK (`ios/Podfile.lock` lists no Google-Mobile-Ads, Firebase or GoogleUtilities pods).
- `ios/Runner/Info.plist` — no `NSUserTrackingUsageDescription`, `GADApplicationIdentifier` or `SKAdNetworkItems`.
- `test/project_rules_test.dart` — fails if Firebase/ATT/tracking packages, the notification permission, or the ATT string come back.

## Sources (checked 2026-09-25)

- Google Play Families policy: https://support.google.com/googleplay/android-developer/answer/9893335 — "Only use Google Play Families Self-Certified Ads SDKs"; no "interest-based advertising … or remarketing"; prohibits "Interstitial … advertising displayed immediately upon app launch", ads "not closeable after 5 seconds", "more than one banner"; "Apps solely targeted to children should not request AD_ID permission".
- Families data practices: https://support.google.com/googleplay/android-developer/answer/11043825
- Families Self-Certified Ads SDK list: https://support.google.com/googleplay/android-developer/answer/12955712 — "Google AdMob … play-services-ads 19.0.0 or later".
- AdMob and Families: https://support.google.com/admob/answer/6223431 ; child treatment: https://support.google.com/admob/answer/6219315 (TFCD/TFUA deprecated → Tag for age treatment; child treatment disables personalized ads, remarketing, third-party ad vendors and AAID/IDFA).
- AdMob Flutter targeting: https://developers.google.com/admob/flutter/targeting
- Play store listing assets: https://support.google.com/googleplay/android-developer/answer/9866151
- App Store Review Guidelines 1.3 and 5.1.4: https://developer.apple.com/app-store/review/guidelines/
- Apple kids apps: https://developer.apple.com/app-store/kids-apps/
- Apple age ratings: https://developer.apple.com/help/app-store-connect/reference/app-information/age-ratings-values-and-definitions/
- Apple App Privacy details: https://developer.apple.com/app-store/app-privacy-details/
- App Store screenshot specs: https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/
- FTC COPPA amendments (compliance date 22 April 2026): https://www.federalregister.gov/documents/2025/04/22/2025-05904/childrens-online-privacy-protection-rule

## Console declarations — NOT VERIFIED (blocker)

No Play Console or App Store Connect access was available in this session. Until the owner confirms these, **the Company PRODUCT GROWTH hold stays in place** and the new build should not be submitted.

Google Play Console (for 1.1.0):
1. Target audience and content: choose the child age groups (recommended: 5 and under, 6–8). This puts the app under the Families policy.
2. Ads declaration: "Yes, contains ads".
3. Data safety: data shared/collected by the AdMob SDK under child treatment (see `marketing/store-assets/metadata/privacy-disclosures.md`); no data collected by the app itself; no account; data not encrypted in transit claims only as documented by Google.
4. Privacy policy URL: must describe the app (the company page `athryza.com/en/privacy` covers only the website). See Phase 6 report.
5. AdMob console: mark the app as directed to children, set max ad content rating G, and set the interstitial unit to **display ads only / skippable** so every interstitial is closable within 5 seconds.

App Store Connect (for 1.1.0):
1. Age rating questionnaire: no ads, no tracking → 4+. Answer the Advertising question "No".
2. App Privacy: "Data Not Collected".
3. Category: Education or Games › Educational. Kids Category is now possible (no third-party ads/analytics); choosing it adds the Kids rules on parental gates (the app already gates its only external link and all settings).
4. Remove the old ATT/advertising answers from 1.0.

## Remaining risks

- The v1.0 builds live on both stores still contain every removed behaviour until 1.1.0 is released.
- Store listings may still describe 1.0 features (coins, 1000 unlocked levels, avatars); the new metadata package replaces them.
- The Android upload keystore and its passwords were committed to this public repository (`android/key.properties`, `android/app/upload-keystore.jks`). They are untracked on this branch, but history still contains them: request an upload-key reset in Play Console and keep the new key out of Git.
