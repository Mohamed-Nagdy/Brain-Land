# Brain Land 1.1.0 — Data safety (Google Play) and App Privacy (App Store): draft answers

Prepared 2026-09-25 from the 1.1.0 code. **The owner must enter these in the consoles**; nothing has been submitted. Privacy policy URL for both stores: `https://athryza.com/en/privacy#brain-land` (Arabic: `/ar/privacy#brain-land`).

## What the app itself does

- No accounts, no sign-in, no forms, no personal information asked for.
- Stars, progress and settings are stored only on the device (Hive box `brainland_v2`); reset in the parents' area or deleting the app erases them.
- No analytics, crash reporting, push notifications or tracking SDKs (Firebase, ATT and FCM were removed; `test/project_rules_test.dart` guards this).
- The only link out (privacy policy) sits behind the grown-up check.

## Google Play — Data safety (Android includes the Google Mobile Ads SDK)

Source: Google's own disclosure guidance for the SDK, https://developers.google.com/admob/android/privacy/play-data-disclosure (checked 2026-09-25): the SDK automatically collects IP address, product interactions, diagnostics and device identifiers "for advertising, analytics, and fraud prevention purposes", shared with Google, encrypted in transit (TLS).

Brain Land's configuration changes what applies:
- `AD_ID` permission is removed (`tools:node="remove"`), and every request carries child treatment (`AgeRestrictedTreatment.child`), under which AdMob does not send the advertising ID (https://support.google.com/admob/answer/6219315).

| Question | Answer |
|---|---|
| Does the app collect or share user data? | Yes (through the Google Mobile Ads SDK) |
| Encrypted in transit? | Yes |
| Can users request deletion? | Nothing is held by ATHRYZA; on-device data is deleted with the app or with "Reset progress" |
| Location → Approximate location | Collected and shared (IP address) · Advertising, fraud prevention · Not optional |
| App activity → App interactions | Collected and shared · Advertising, analytics · Not optional |
| App info and performance → Diagnostics | Collected and shared · Analytics · Not optional |
| Device or other IDs | Collected and shared: **app set ID** only (advertising ID is not collected — permission removed, child treatment) · Advertising, fraud prevention · Not optional |
| Personal info, financial, health, messages, photos, audio, files, calendar, contacts, web history | Not collected |

Also in Play Console: Target audience = ages 5 & under and 6–8 (Families policy applies); Ads = "Yes, my app contains ads"; Families self-certified ads SDK = Google AdMob (play-services-ads 25.4.0 via google_mobile_ads 9.1.0).

Owner check before submitting: compare these answers with the current guidance page and with AdMob's "Families" page (https://support.google.com/admob/answer/6223431); set the AdMob app to child-directed and the interstitial unit to display-only/skippable.

## App Store — App Privacy (iOS has no ads SDK)

The iOS build links no ads, analytics or tracking SDK (`ios/AdsStub/` stands in for the ads plugin; `ios/Podfile.lock` lists no Google-Mobile-Ads, Firebase or GoogleUtilities pods).

| Question | Answer |
|---|---|
| Do you or your third-party partners collect data from this app? | **No — Data Not Collected** |
| Tracking (ATT) | No tracking; no ATT prompt; `NSUserTrackingUsageDescription` removed |
| Age rating: Advertising | No |
| Age rating: Parental controls | Yes — settings and links behind a grown-up check |
