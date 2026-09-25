// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Brain Land';

  @override
  String get worldMath => 'Math Forest';

  @override
  String get worldLogic => 'Logic Mountain';

  @override
  String get worldMemory => 'Memory River';

  @override
  String get worldShape => 'Shape Valley';

  @override
  String missionNumber(String number) {
    return 'Mission $number';
  }

  @override
  String get instrCount => 'How many do you see?';

  @override
  String get instrMore => 'Which group has more?';

  @override
  String get instrAdd => 'Put them together. How many?';

  @override
  String get instrTakeAway => 'Some go away. How many are left?';

  @override
  String get instrMissing => 'How many more to fill the frame?';

  @override
  String get instrMissingNumber => 'What number is missing?';

  @override
  String get instrSolve => 'Solve it!';

  @override
  String get instrPattern => 'What comes next?';

  @override
  String get instrPatternGap => 'What is missing?';

  @override
  String get instrMemory => 'Find the matching pairs.';

  @override
  String get instrShape => 'Put each shape in its home.';

  @override
  String get praise1 => 'Great job!';

  @override
  String get praise2 => 'You got it!';

  @override
  String get praise3 => 'Super thinking!';

  @override
  String get mistakeTryAgain => 'Almost! Try again.';

  @override
  String get mistakeCountAgain => 'Count again, one by one.';

  @override
  String get mistakeAddedInstead => 'We are taking away, not adding.';

  @override
  String get mistakeSubtractedInstead => 'We are adding, not taking away.';

  @override
  String get mistakeCompare => 'Look again: which group is bigger?';

  @override
  String get mistakePattern => 'Look at what repeats.';

  @override
  String get mistakeMemory => 'Not a pair. Remember where they are!';

  @override
  String get mistakeShape => 'That home is for another shape.';

  @override
  String get hintCountTogether => 'Let\'s count together.';

  @override
  String get hintRemoveOne => 'I hid one wrong answer.';

  @override
  String get hintPattern => 'The pattern repeats like this.';

  @override
  String get hintMemory => 'Peek! Remember them.';

  @override
  String get hintShape => 'Here is where it goes.';

  @override
  String get missionComplete => 'Mission complete!';

  @override
  String get chapterComplete => 'Chapter complete! You earned a medal.';

  @override
  String get next => 'Next';

  @override
  String get map => 'Map';

  @override
  String get playAgain => 'Play again';

  @override
  String get breakTitle => 'Time for a little break';

  @override
  String get breakBody => 'Stretch, drink some water, then come back!';

  @override
  String get keepPlaying => 'Keep playing';

  @override
  String get paused => 'Paused';

  @override
  String get resume => 'Continue';

  @override
  String get welcome => 'Hi! I\'m the brain explorer. Tap a world to start!';

  @override
  String get parentsArea => 'For parents';

  @override
  String get gateTitle => 'Grown-ups only';

  @override
  String gatePrompt(String words) {
    return 'Tap these numbers: $words';
  }

  @override
  String get gateWrong => 'Not quite. Try again.';

  @override
  String get soundEffects => 'Sound effects';

  @override
  String get voiceGuide => 'Voice guide';

  @override
  String get reduceMotion => 'Reduce motion';

  @override
  String get language => 'Language';

  @override
  String get numerals => 'Number style';

  @override
  String get resetProgress => 'Reset progress';

  @override
  String get resetConfirm => 'This erases all stars and medals on this device.';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Erase';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get aboutGame =>
      'Four worlds of short puzzle missions: counting and adding, patterns, memory and shapes. Each world starts with a 10-mission chapter.';

  @override
  String get aboutAdsAndroid =>
      'This free version shows a few ads between missions, never during a puzzle. Ads are requested as child-directed: no personalized ads and no advertising ID.';

  @override
  String get aboutAdsIos => 'No ads, no tracking and no accounts.';

  @override
  String get madeBy => 'Made by ATHRYZA Technologies';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get adLabel => 'Ad';

  @override
  String get a11yHint => 'Hint';

  @override
  String get a11yPause => 'Pause';

  @override
  String get a11yReplay => 'Hear it again';

  @override
  String get a11yBack => 'Back';

  @override
  String get a11yLocked => 'Locked';

  @override
  String a11yStars(String count) {
    return '$count of 3 stars';
  }

  @override
  String get a11yMedal => 'Medal';

  @override
  String get a11yCard => 'Card';

  @override
  String get a11yGroupA => 'First group';

  @override
  String get a11yGroupB => 'Second group';

  @override
  String get close => 'Close';

  @override
  String chapterNumber(String number) {
    return 'Chapter $number';
  }

  @override
  String get shapeCircle => 'circle';

  @override
  String get shapeSquare => 'square';

  @override
  String get shapeTriangle => 'triangle';

  @override
  String get shapeStar => 'star';

  @override
  String get shapeHeart => 'heart';

  @override
  String get shapeDiamond => 'diamond';

  @override
  String get shapeHexagon => 'hexagon';

  @override
  String get shapeRectangle => 'rectangle';
}
