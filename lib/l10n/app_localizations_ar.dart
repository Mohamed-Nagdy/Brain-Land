// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Brain Land';

  @override
  String get worldMath => 'غابة الأرقام';

  @override
  String get worldLogic => 'جبل الأنماط';

  @override
  String get worldMemory => 'نهر الذاكرة';

  @override
  String get worldShape => 'وادي الأشكال';

  @override
  String missionNumber(String number) {
    return 'المهمة $number';
  }

  @override
  String get instrCount => 'كم عددها؟';

  @override
  String get instrMore => 'أيّ مجموعة أكثر؟';

  @override
  String get instrAdd => 'اجمعها معًا. كم صارت؟';

  @override
  String get instrTakeAway => 'ذهب بعضها. كم بقي؟';

  @override
  String get instrMissing => 'كم ينقص لنملأ الإطار؟';

  @override
  String get instrMissingNumber => 'ما العدد الناقص؟';

  @override
  String get instrSolve => 'حُلّ المسألة!';

  @override
  String get instrPattern => 'ماذا يأتي بعد ذلك؟';

  @override
  String get instrPatternGap => 'ما الناقص؟';

  @override
  String get instrMemory => 'اعثر على البطاقات المتشابهة.';

  @override
  String get instrShape => 'ضع كل شكل في بيته.';

  @override
  String get praise1 => 'أحسنت!';

  @override
  String get praise2 => 'رائع!';

  @override
  String get praise3 => 'تفكير ممتاز!';

  @override
  String get mistakeTryAgain => 'اقتربت! حاول مرة أخرى.';

  @override
  String get mistakeCountAgain => 'عُدّ مرة أخرى، واحدًا واحدًا.';

  @override
  String get mistakeAddedInstead => 'نحن نطرح، لا نجمع.';

  @override
  String get mistakeSubtractedInstead => 'نحن نجمع، لا نطرح.';

  @override
  String get mistakeCompare => 'انظر مرة أخرى: أيّ مجموعة أكبر؟';

  @override
  String get mistakePattern => 'انظر إلى ما يتكرّر.';

  @override
  String get mistakeMemory => 'ليستا متشابهتين. تذكّر مكانهما!';

  @override
  String get mistakeShape => 'هذا البيت لشكل آخر.';

  @override
  String get hintCountTogether => 'لنعدّ معًا.';

  @override
  String get hintRemoveOne => 'أخفيتُ إجابة خاطئة.';

  @override
  String get hintPattern => 'النمط يتكرّر هكذا.';

  @override
  String get hintMemory => 'انظر بسرعة وتذكّر!';

  @override
  String get hintShape => 'هنا مكانه.';

  @override
  String get missionComplete => 'أنجزتَ المهمة!';

  @override
  String get chapterComplete => 'أكملتَ الفصل! ربحتَ وسامًا.';

  @override
  String get next => 'التالي';

  @override
  String get map => 'الخريطة';

  @override
  String get playAgain => 'العب مجددًا';

  @override
  String get breakTitle => 'وقت استراحة قصيرة';

  @override
  String get breakBody => 'تمدّد واشرب قليلًا من الماء، ثم عُد!';

  @override
  String get keepPlaying => 'أكمل اللعب';

  @override
  String get paused => 'توقّف مؤقت';

  @override
  String get resume => 'تابِع';

  @override
  String get welcome => 'مرحبًا! أنا المستكشف. اضغط على عالم لنبدأ!';

  @override
  String get parentsArea => 'للأهل';

  @override
  String get gateTitle => 'للكبار فقط';

  @override
  String gatePrompt(String words) {
    return 'اضغط هذه الأرقام: $words';
  }

  @override
  String get gateWrong => 'ليس صحيحًا. حاول مرة أخرى.';

  @override
  String get soundEffects => 'المؤثرات الصوتية';

  @override
  String get voiceGuide => 'الإرشاد الصوتي';

  @override
  String get reduceMotion => 'تقليل الحركة';

  @override
  String get language => 'اللغة';

  @override
  String get numerals => 'شكل الأرقام';

  @override
  String get resetProgress => 'إعادة ضبط التقدّم';

  @override
  String get resetConfirm => 'سيُمحى كل النجوم والأوسمة على هذا الجهاز.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'امسح';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get aboutGame =>
      'أربعة عوالم من مهام الألغاز القصيرة: العدّ والجمع، والأنماط، والذاكرة، والأشكال. يبدأ كل عالم بفصل من 10 مهام.';

  @override
  String get aboutAdsAndroid =>
      'تعرض هذه النسخة المجانية بعض الإعلانات بين المهام، ولا تعرضها أثناء اللغز أبدًا. تُطلب الإعلانات كإعلانات موجّهة للأطفال: بلا إعلانات مخصّصة وبلا معرّف إعلاني.';

  @override
  String get aboutAdsIos => 'بلا إعلانات، وبلا تتبّع، وبلا حسابات.';

  @override
  String get madeBy => 'من تطوير أثريزا للتكنولوجيا';

  @override
  String versionLabel(String version) {
    return 'الإصدار $version';
  }

  @override
  String get adLabel => 'إعلان';

  @override
  String get a11yHint => 'تلميح';

  @override
  String get a11yPause => 'إيقاف مؤقت';

  @override
  String get a11yReplay => 'استمع مرة أخرى';

  @override
  String get a11yBack => 'رجوع';

  @override
  String get a11yLocked => 'مقفل';

  @override
  String a11yStars(String count) {
    return '$count من 3 نجوم';
  }

  @override
  String get a11yMedal => 'وسام';

  @override
  String get a11yCard => 'بطاقة';

  @override
  String get a11yGroupA => 'المجموعة الأولى';

  @override
  String get a11yGroupB => 'المجموعة الثانية';

  @override
  String get close => 'إغلاق';

  @override
  String chapterNumber(String number) {
    return 'الفصل $number';
  }

  @override
  String get shapeCircle => 'دائرة';

  @override
  String get shapeSquare => 'مربع';

  @override
  String get shapeTriangle => 'مثلث';

  @override
  String get shapeStar => 'نجمة';

  @override
  String get shapeHeart => 'قلب';

  @override
  String get shapeDiamond => 'معيّن';

  @override
  String get shapeHexagon => 'سداسي';

  @override
  String get shapeRectangle => 'مستطيل';
}
