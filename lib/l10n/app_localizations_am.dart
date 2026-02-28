// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Amharic (`am`).
class AppLocalizationsAm extends AppLocalizations {
  AppLocalizationsAm([String locale = 'am']) : super(locale);

  @override
  String get appTitle => 'ሲቲፊክስ ጅማ';

  @override
  String get appSubtitle => 'የጅማ ከተማ የዜጎች ጉዳይ ሪፖርት';

  @override
  String get login => 'ግባ';

  @override
  String get email => 'ኢሜይል';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get password => 'የይለፍ ቃል';

  @override
  String get emailRequired => 'ኢሜይል ያስፈልጋል';

  @override
  String get emailInvalid => 'ትክክለኛ ኢሜይል ያስገቡ';

  @override
  String get passwordRequired => 'የይለፍ ቃል ቢያንስ 6 ቁምፊዎች መሆን አለበት';

  @override
  String get noAccount => 'መለያ የለዎትም? ይመዝገቡ';

  @override
  String get createAccount => 'መለያ ይፍጠሩ';

  @override
  String get fullName => 'ሙሉ ስም';

  @override
  String get fullNameHint => 'ተስፋዬ ለማ';

  @override
  String get fullNameRequired => 'ስም ያስፈልጋል';

  @override
  String get alreadyHaveAccount => 'መለያ አለዎት? ግባ';

  @override
  String get profile => 'መገለጫ';

  @override
  String get verifiedCitizen => 'የተረጋገጠ ዜጋ';

  @override
  String get unverified => 'ያልተረጋገጠ';

  @override
  String get yourImpact => 'የእርስዎ አስተዋጽኦ';

  @override
  String get totalReports => 'ጠቅላላ ሪፖርቶች';

  @override
  String get resolved => 'የተፈቱ';

  @override
  String get settingsTitle => 'ቅንብሮች እና ምርጫዎች';

  @override
  String get pushNotifications => 'የግፊት ማሳወቂያዎች';

  @override
  String get pushEnabled => 'የግፊት ማሳወቂያዎች ነቅተዋል።';

  @override
  String get pushDisabled => 'የግፊት ማሳወቂያዎች ጠፍተዋል።';

  @override
  String get appTheme => 'የመተግበሪያ ገጽታ';

  @override
  String get systemDefault => 'የስርዓት ነባሪ';

  @override
  String get lightMode => 'ብርሃን ሁነታ';

  @override
  String get darkMode => 'ጨለማ ሁነታ';

  @override
  String get language => 'ቋንቋ';

  @override
  String get privacyPolicy => 'የግለኝነት ፖሊሲ';

  @override
  String get helpSupport => 'እርዳታ እና ድጋፍ';

  @override
  String get helpContent =>
      'የሲቲፊክስ መተግበሪያን ለመጠቀም እርዳታ ከፈለጉ፣ support@cityfix.com ወይም ለድንገተኛ ሁኔታዎች 911 ይደውሉ።';

  @override
  String get close => 'ዝጋ';

  @override
  String get signOut => 'ውጣ';

  @override
  String get privacyIntro =>
      'የእርስዎ ግለኝነት ለእኛ ጠቃሚ ነው። ይህ ፖሊሲ ውሂብዎን እንዴት እንደምናስተናግድ ያብራራል።';

  @override
  String get privacyDataCollection =>
      '1. የውሂብ ስብስብ\nለሕዝባዊ ዜጋ ጉዳይ ሪፖርት ብቻ የቦታ እና የፎቶ ውሂብ እንሰበስባለን።';

  @override
  String get privacyDataSecurity =>
      '2. የውሂብ ደህንነት\nውሂብዎን ከደረጃ ደረጃ ደህንነት ደንቦች ጋር ተስማምቶ ምሰጠናል።';

  @override
  String get privacyNotifications =>
      '3. የግፊት ማሳወቂያዎች\nስለ ጉዳይ ውሳኔዎች ለማሳወቅ Firebase Cloud Messaging እንጠቀማለን።';

  @override
  String get feedNear => 'ቅርብ';

  @override
  String get feedNew => 'አዲስ';

  @override
  String get feedUrgent => 'አስቸኳይ';

  @override
  String get feedEverywhere => 'በሁሉም ቦታ';

  @override
  String get feedSearchHint => 'ጉዳዮችን ፈልግ...';

  @override
  String get feedNoIssues => 'እስካሁን ምንም ጉዳይ አልተዘገበም።';

  @override
  String get feedBeFirst => 'ችግር ለመዘገብ ቀዳሚ ይሁኑ!';

  @override
  String get feedLoadError => 'ዜናን መጫን አልተቻለም';

  @override
  String get notifications => 'ማሳወቂያዎች';

  @override
  String get clearAll => 'ሁሉንም አጽዳ';

  @override
  String get noNotifications => 'ሁሉም ጠርቷል!';

  @override
  String upvoted(int score) {
    return 'ድምጽ ሰጥቷል ($score)';
  }

  @override
  String upvote(int score) {
    return 'ድምጽ ስጥ ($score)';
  }

  @override
  String get reportAnIssue => 'ጉዳይ ሪፖርት አድርግ';

  @override
  String get category => 'ምድብ';

  @override
  String get kebele => 'ቀበሌ (አካባቢ)';

  @override
  String get description => 'መግለጫ';

  @override
  String get detailedDescription => 'ዝርዝር መግለጫ';

  @override
  String get descriptionHint => 'ጉዳዩን ይግለጹ...';

  @override
  String get tapToPhoto => 'ፎቶ ለማንሳት ነካ ያድርጉ';

  @override
  String get location => 'ቦታ';

  @override
  String get detectLocation => 'ወቅታዊ ቦታን ፈልግ';

  @override
  String get locationInstruction => 'ቦታ ለማቀናበር ካርታ ላይ ነካ ያድርጉ፣ ወይም ፈልግ ይጫኑ።';

  @override
  String get locationPinpointed => 'ቦታ ተቀምጧል';

  @override
  String locationSelected(String address) {
    return 'የተመረጠ: $address';
  }

  @override
  String locationError(String error) {
    return 'የቦታ ስህተት: $error';
  }

  @override
  String get locationRequired => 'ቦታዎን ፈልጉ ወይም ካርታ ላይ ነካ ያድርጉ';

  @override
  String get submitReport => 'ሪፖርት ላክ';

  @override
  String get reportSaved => 'ኦፍላይን ረቂቆች ውስጥ ተቀምጧል። ራሱ ሲሳካ ተመሳስሏል።';

  @override
  String get reportSuccess => 'ጉዳዩ በተሳካ ሁኔታ ተዘግቧል!';

  @override
  String failedToSubmit(String error) {
    return 'መላክ አልተሳካም: $error';
  }

  @override
  String get fetchingAddress => 'አድራሻ እየፈለጉ...';

  @override
  String get required => 'ያስፈልጋል';

  @override
  String get myReports => 'ሪፖርቶቼ';

  @override
  String get noReportsYet => 'እስካሁን ምንም አልዘገቡም።';

  @override
  String get editReport => 'ሪፖርት አስተካክል';

  @override
  String get saveChanges => 'ለውጦቹን ያስቀምጡ';

  @override
  String get updateMapLocation => 'የካርታ ቦታን አዘምን';

  @override
  String get rateResolution => 'መፍትሄውን ዋጋ ስጥ';

  @override
  String get optionalComment => 'ተጨማሪ አስተያየት (አስፈላጊ ካልሆነ ይዘለሉ)...';

  @override
  String get submitFeedback => 'አስተያየት ላክ';

  @override
  String get feedbackSubmitted => 'አስተያየቱ ተልኳል!';

  @override
  String failedGeneric(String error) {
    return 'አልተሳካም: $error';
  }

  @override
  String get reportUpdated => 'ሪፖርቱ በተሳካ ሁኔታ ተዘምኗል';

  @override
  String updateFailed(String error) {
    return 'ዝማኔ አልተሳካም: $error';
  }

  @override
  String get reportIssueMenu => 'ጉዳዩን ሪፖርት አድርግ';

  @override
  String get reportDialogTitle => 'ጉዳዩን ሪፖርት አድርግ';

  @override
  String get reportDialogReason => 'ምክንያት';

  @override
  String get reportDialogHint => 'ይህ ጉዳይ ለምን አግባብ አይደለም?';

  @override
  String get cancel => 'ሰርዝ';

  @override
  String get submit => 'ላክ';

  @override
  String get reportedForReview => 'ጉዳዩ ለግምገማ ተዘግቧል።';

  @override
  String get failedToReport => 'ጉዳዩን ሪፖርት ማድረግ አልተሳካም።';

  @override
  String get anonymousCitizen => 'ስም-አልባ ዜጋ';

  @override
  String get notLoggedIn => 'አልገቡም።';

  @override
  String get navFeed => 'ዜና';

  @override
  String get navSearch => 'ፈልግ';

  @override
  String get navMyReports => 'ሪፖርቶቼ';

  @override
  String get navProfile => 'መገለጫ';

  @override
  String get catWater => 'ውሃ';

  @override
  String get catWaste => 'ቆሻሻ';

  @override
  String get catRoad => 'መንገድ';

  @override
  String get catElectricity => 'መብራት';

  @override
  String get catOther => 'ሌላ';

  @override
  String get statusPending => 'በመጠባበቅ ላይ';

  @override
  String get statusInProgress => 'በሂደት ላይ';

  @override
  String get statusResolved => 'ተፈቷል';

  @override
  String get reportDetail => 'የሪፖርት ዝርዝር';

  @override
  String get communityDiscussion => 'የማህበረሰብ ውይይት';

  @override
  String commentsCount(int count) {
    return '$count አስተያየቶች';
  }

  @override
  String get noCommentsYet => 'እስካሁን ምንም አስተያየት የለም። ውይይቱን ይጀምሩ!';

  @override
  String get commentHint => 'ጠቃሚ አስተያየት ያክሉ...';

  @override
  String get reportLocation => 'የሪፖርት ቦታ';

  @override
  String get offlineMode => 'ኦፍላይን ሁነታ - የተቀመጠ ውሂብ በማሳየት ላይ';

  @override
  String get youAreOffline => 'ኦፍላይን ነዎት። ተግባራት ተሰናክለዋል።';

  @override
  String get backOnline => 'ተመልሰዋል! ኢንተርኔት ተያይዟል።';
}
