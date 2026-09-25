import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Brain Land'**
  String get appTitle;

  /// No description provided for @worldMath.
  ///
  /// In en, this message translates to:
  /// **'Math Forest'**
  String get worldMath;

  /// No description provided for @worldLogic.
  ///
  /// In en, this message translates to:
  /// **'Logic Mountain'**
  String get worldLogic;

  /// No description provided for @worldMemory.
  ///
  /// In en, this message translates to:
  /// **'Memory River'**
  String get worldMemory;

  /// No description provided for @worldShape.
  ///
  /// In en, this message translates to:
  /// **'Shape Valley'**
  String get worldShape;

  /// No description provided for @missionNumber.
  ///
  /// In en, this message translates to:
  /// **'Mission {number}'**
  String missionNumber(String number);

  /// No description provided for @instrCount.
  ///
  /// In en, this message translates to:
  /// **'How many do you see?'**
  String get instrCount;

  /// No description provided for @instrMore.
  ///
  /// In en, this message translates to:
  /// **'Which group has more?'**
  String get instrMore;

  /// No description provided for @instrAdd.
  ///
  /// In en, this message translates to:
  /// **'Put them together. How many?'**
  String get instrAdd;

  /// No description provided for @instrTakeAway.
  ///
  /// In en, this message translates to:
  /// **'Some go away. How many are left?'**
  String get instrTakeAway;

  /// No description provided for @instrMissing.
  ///
  /// In en, this message translates to:
  /// **'How many more to fill the frame?'**
  String get instrMissing;

  /// No description provided for @instrMissingNumber.
  ///
  /// In en, this message translates to:
  /// **'What number is missing?'**
  String get instrMissingNumber;

  /// No description provided for @instrSolve.
  ///
  /// In en, this message translates to:
  /// **'Solve it!'**
  String get instrSolve;

  /// No description provided for @instrPattern.
  ///
  /// In en, this message translates to:
  /// **'What comes next?'**
  String get instrPattern;

  /// No description provided for @instrPatternGap.
  ///
  /// In en, this message translates to:
  /// **'What is missing?'**
  String get instrPatternGap;

  /// No description provided for @instrMemory.
  ///
  /// In en, this message translates to:
  /// **'Find the matching pairs.'**
  String get instrMemory;

  /// No description provided for @instrShape.
  ///
  /// In en, this message translates to:
  /// **'Put each shape in its home.'**
  String get instrShape;

  /// No description provided for @praise1.
  ///
  /// In en, this message translates to:
  /// **'Great job!'**
  String get praise1;

  /// No description provided for @praise2.
  ///
  /// In en, this message translates to:
  /// **'You got it!'**
  String get praise2;

  /// No description provided for @praise3.
  ///
  /// In en, this message translates to:
  /// **'Super thinking!'**
  String get praise3;

  /// No description provided for @mistakeTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Almost! Try again.'**
  String get mistakeTryAgain;

  /// No description provided for @mistakeCountAgain.
  ///
  /// In en, this message translates to:
  /// **'Count again, one by one.'**
  String get mistakeCountAgain;

  /// No description provided for @mistakeAddedInstead.
  ///
  /// In en, this message translates to:
  /// **'We are taking away, not adding.'**
  String get mistakeAddedInstead;

  /// No description provided for @mistakeSubtractedInstead.
  ///
  /// In en, this message translates to:
  /// **'We are adding, not taking away.'**
  String get mistakeSubtractedInstead;

  /// No description provided for @mistakeCompare.
  ///
  /// In en, this message translates to:
  /// **'Look again: which group is bigger?'**
  String get mistakeCompare;

  /// No description provided for @mistakePattern.
  ///
  /// In en, this message translates to:
  /// **'Look at what repeats.'**
  String get mistakePattern;

  /// No description provided for @mistakeMemory.
  ///
  /// In en, this message translates to:
  /// **'Not a pair. Remember where they are!'**
  String get mistakeMemory;

  /// No description provided for @mistakeShape.
  ///
  /// In en, this message translates to:
  /// **'That home is for another shape.'**
  String get mistakeShape;

  /// No description provided for @hintCountTogether.
  ///
  /// In en, this message translates to:
  /// **'Let\'s count together.'**
  String get hintCountTogether;

  /// No description provided for @hintRemoveOne.
  ///
  /// In en, this message translates to:
  /// **'I hid one wrong answer.'**
  String get hintRemoveOne;

  /// No description provided for @hintPattern.
  ///
  /// In en, this message translates to:
  /// **'The pattern repeats like this.'**
  String get hintPattern;

  /// No description provided for @hintMemory.
  ///
  /// In en, this message translates to:
  /// **'Peek! Remember them.'**
  String get hintMemory;

  /// No description provided for @hintShape.
  ///
  /// In en, this message translates to:
  /// **'Here is where it goes.'**
  String get hintShape;

  /// No description provided for @missionComplete.
  ///
  /// In en, this message translates to:
  /// **'Mission complete!'**
  String get missionComplete;

  /// No description provided for @chapterComplete.
  ///
  /// In en, this message translates to:
  /// **'Chapter complete! You earned a medal.'**
  String get chapterComplete;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get playAgain;

  /// No description provided for @breakTitle.
  ///
  /// In en, this message translates to:
  /// **'Time for a little break'**
  String get breakTitle;

  /// No description provided for @breakBody.
  ///
  /// In en, this message translates to:
  /// **'Stretch, drink some water, then come back!'**
  String get breakBody;

  /// No description provided for @keepPlaying.
  ///
  /// In en, this message translates to:
  /// **'Keep playing'**
  String get keepPlaying;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get resume;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Hi! I\'m the brain explorer. Tap a world to start!'**
  String get welcome;

  /// No description provided for @parentsArea.
  ///
  /// In en, this message translates to:
  /// **'For parents'**
  String get parentsArea;

  /// No description provided for @gateTitle.
  ///
  /// In en, this message translates to:
  /// **'Grown-ups only'**
  String get gateTitle;

  /// No description provided for @gatePrompt.
  ///
  /// In en, this message translates to:
  /// **'Tap these numbers: {words}'**
  String gatePrompt(String words);

  /// No description provided for @gateWrong.
  ///
  /// In en, this message translates to:
  /// **'Not quite. Try again.'**
  String get gateWrong;

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get soundEffects;

  /// No description provided for @voiceGuide.
  ///
  /// In en, this message translates to:
  /// **'Voice guide'**
  String get voiceGuide;

  /// No description provided for @reduceMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get reduceMotion;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @numerals.
  ///
  /// In en, this message translates to:
  /// **'Number style'**
  String get numerals;

  /// No description provided for @resetProgress.
  ///
  /// In en, this message translates to:
  /// **'Reset progress'**
  String get resetProgress;

  /// No description provided for @resetConfirm.
  ///
  /// In en, this message translates to:
  /// **'This erases all stars and medals on this device.'**
  String get resetConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Erase'**
  String get confirm;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @aboutGame.
  ///
  /// In en, this message translates to:
  /// **'Four worlds of short puzzle missions: counting and adding, patterns, memory and shapes. Each world starts with a 10-mission chapter.'**
  String get aboutGame;

  /// No description provided for @aboutAdsAndroid.
  ///
  /// In en, this message translates to:
  /// **'This free version shows a few ads between missions, never during a puzzle. Ads are requested as child-directed: no personalized ads and no advertising ID.'**
  String get aboutAdsAndroid;

  /// No description provided for @aboutAdsIos.
  ///
  /// In en, this message translates to:
  /// **'No ads, no tracking and no accounts.'**
  String get aboutAdsIos;

  /// No description provided for @madeBy.
  ///
  /// In en, this message translates to:
  /// **'Made by ATHRYZA Technologies'**
  String get madeBy;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionLabel(String version);

  /// No description provided for @adLabel.
  ///
  /// In en, this message translates to:
  /// **'Ad'**
  String get adLabel;

  /// No description provided for @a11yHint.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get a11yHint;

  /// No description provided for @a11yPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get a11yPause;

  /// No description provided for @a11yReplay.
  ///
  /// In en, this message translates to:
  /// **'Hear it again'**
  String get a11yReplay;

  /// No description provided for @a11yBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get a11yBack;

  /// No description provided for @a11yLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get a11yLocked;

  /// No description provided for @a11yStars.
  ///
  /// In en, this message translates to:
  /// **'{count} of 3 stars'**
  String a11yStars(String count);

  /// No description provided for @a11yMedal.
  ///
  /// In en, this message translates to:
  /// **'Medal'**
  String get a11yMedal;

  /// No description provided for @a11yCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get a11yCard;

  /// No description provided for @a11yGroupA.
  ///
  /// In en, this message translates to:
  /// **'First group'**
  String get a11yGroupA;

  /// No description provided for @a11yGroupB.
  ///
  /// In en, this message translates to:
  /// **'Second group'**
  String get a11yGroupB;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @chapterNumber.
  ///
  /// In en, this message translates to:
  /// **'Chapter {number}'**
  String chapterNumber(String number);

  /// No description provided for @shapeCircle.
  ///
  /// In en, this message translates to:
  /// **'circle'**
  String get shapeCircle;

  /// No description provided for @shapeSquare.
  ///
  /// In en, this message translates to:
  /// **'square'**
  String get shapeSquare;

  /// No description provided for @shapeTriangle.
  ///
  /// In en, this message translates to:
  /// **'triangle'**
  String get shapeTriangle;

  /// No description provided for @shapeStar.
  ///
  /// In en, this message translates to:
  /// **'star'**
  String get shapeStar;

  /// No description provided for @shapeHeart.
  ///
  /// In en, this message translates to:
  /// **'heart'**
  String get shapeHeart;

  /// No description provided for @shapeDiamond.
  ///
  /// In en, this message translates to:
  /// **'diamond'**
  String get shapeDiamond;

  /// No description provided for @shapeHexagon.
  ///
  /// In en, this message translates to:
  /// **'hexagon'**
  String get shapeHexagon;

  /// No description provided for @shapeRectangle.
  ///
  /// In en, this message translates to:
  /// **'rectangle'**
  String get shapeRectangle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
