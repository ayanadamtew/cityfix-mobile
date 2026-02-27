// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Oromo (`om`).
class AppLocalizationsOm extends AppLocalizations {
  AppLocalizationsOm([String locale = 'om']) : super(locale);

  @override
  String get appTitle => 'CityFix Jimmaa';

  @override
  String get appSubtitle => 'Gabaasa Rakkoo Magaalaa Jimmaa';

  @override
  String get login => 'Seeni';

  @override
  String get email => 'Imeelii';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get password => 'Jecha Icciitii';

  @override
  String get emailRequired => 'Imeelii barbaachisaadha';

  @override
  String get emailInvalid => 'Imeelii sirrii galchi';

  @override
  String get passwordRequired => 'Jecha icciitii xumura 6 ol ta\'uu qaba';

  @override
  String get noAccount => 'Herrega hin qabduu? Galmaa\'i';

  @override
  String get createAccount => 'Herrega Uumi';

  @override
  String get fullName => 'Maqaa Guutuu';

  @override
  String get fullNameHint => 'Abebe Gammachuu';

  @override
  String get fullNameRequired => 'Maqaan barbaachisaadha';

  @override
  String get alreadyHaveAccount => 'Herrega qabdaa? Seeni';

  @override
  String get profile => 'Profaayilii';

  @override
  String get verifiedCitizen => 'Lammii Mirkaneeffame';

  @override
  String get unverified => 'Hin mirkaaneeffamne';

  @override
  String get yourImpact => 'Dhiibbaa Keessan';

  @override
  String get totalReports => 'Gabaasa Waliigalaa';

  @override
  String get resolved => 'Furmaata Argate';

  @override
  String get settingsTitle => 'Qindaa\'inoota fi Filannoowwan';

  @override
  String get pushNotifications => 'Beeksisa Erguu';

  @override
  String get pushEnabled => 'Beeksisi Erguu Naqamee jira.';

  @override
  String get pushDisabled => 'Beeksisi Erguu Hanamee jira.';

  @override
  String get appTheme => 'Mana Taphichaa';

  @override
  String get systemDefault => 'Sirna Durtii';

  @override
  String get lightMode => 'Ifa Haalaa';

  @override
  String get darkMode => 'Darkness Haalaa';

  @override
  String get language => 'Afaan';

  @override
  String get privacyPolicy => 'Imaammata Icciitii';

  @override
  String get helpSupport => 'Gargaarsa fi Deeggarsa';

  @override
  String get helpContent =>
      'App CityFix fayyadamuu keessatti gargaarsa yoo barbaadde, support@cityfix.com quunnamuu ykn hatattama 911 bilbili.';

  @override
  String get close => 'Cufi';

  @override
  String get signOut => 'Ba\'i';

  @override
  String get privacyIntro =>
      'Icciitiin keessan nu biratti barbaachisaadha. Imaammanni kun deetaa keessan akkamitti to\'annuu ibsa.';

  @override
  String get privacyDataCollection =>
      '1. Walitti Qabiinsa Deetaa\nRakkolee hawaasaa gaabasuuf qofa bakka jireenyaa fi suuraa walitti qabna.';

  @override
  String get privacyDataSecurity =>
      '2. Nageenyaa Deetaa\nDeetaa keessan seera magaalaatiin walsimsiisee eenye.';

  @override
  String get privacyNotifications =>
      '3. Beeksisa Erguu\nFurmaata rakkoo isinitti beeksifuuf Firebase Cloud Messaging fayyadamna.';

  @override
  String get feedNear => 'Dhiyoo';

  @override
  String get feedNew => 'Haaraa';

  @override
  String get feedUrgent => 'Ariifataa';

  @override
  String get feedEverywhere => 'Bakka Hundatti';

  @override
  String get feedSearchHint => 'Rakkoolee barbaadi...';

  @override
  String get feedNoIssues => 'Hanga ammaatti rakkoo gabaafame hin jiru.';

  @override
  String get feedBeFirst => 'Rakkoo gabaasuu jalqabaa ta\'i!';

  @override
  String get feedLoadError => 'Dubbisaa fe\'uu hin danda\'amne';

  @override
  String get notifications => 'Beeksisaalee';

  @override
  String get clearAll => 'Hunda Kaa\'i';

  @override
  String get noNotifications => 'Hundi sirriitti ga\'e!';

  @override
  String upvoted(int score) {
    return 'Sagalee Kennite ($score)';
  }

  @override
  String upvote(int score) {
    return 'Sagalee Kenni ($score)';
  }

  @override
  String get reportAnIssue => 'Rakkoo Gabaasi';

  @override
  String get category => 'Gosa';

  @override
  String get kebele => 'Ganda (Naannoo)';

  @override
  String get description => 'Ibsa';

  @override
  String get detailedDescription => 'Ibsa Guutuu';

  @override
  String get descriptionHint => 'Rakkoo ibsi...';

  @override
  String get tapToPhoto => 'Suuraa kaachuuf tuqi';

  @override
  String get location => 'Bakka';

  @override
  String get detectLocation => 'Bakka Ammaa Barbaadi';

  @override
  String get locationInstruction =>
      'Bakka kaa\'uuf kaartaa irratti tuqi, ykn barbaadi tuqi.';

  @override
  String get locationPinpointed => 'Bakki kaa\'ame jira';

  @override
  String locationSelected(String address) {
    return 'Filatame: $address';
  }

  @override
  String locationError(String error) {
    return 'Dogoggora bakka: $error';
  }

  @override
  String get locationRequired => 'Bakka barbaaduu ykn kaartaa irratti tuqi';

  @override
  String get submitReport => 'Gabaasa Ergii';

  @override
  String get reportSaved =>
      'Qabiyyee Offline keessatti kuufame. Ofumaan ni eeguudha.';

  @override
  String get reportSuccess => 'Rakkoon milkaa\'inaan gabaafame!';

  @override
  String failedToSubmit(String error) {
    return 'Erguu hin danda\'amne: $error';
  }

  @override
  String get fetchingAddress => 'Teessoo argachaa...';

  @override
  String get required => 'Barbaachisaadha';

  @override
  String get myReports => 'Gabaasawwan Koo';

  @override
  String get noReportsYet => 'Hanga ammaatti wantuma gabaaste hin jiru.';

  @override
  String get editReport => 'Gabaasa Gulaali';

  @override
  String get saveChanges => 'Jijjiirraa Kuusi';

  @override
  String get updateMapLocation => 'Bakka Kaartaa Haaromsi';

  @override
  String get rateResolution => 'Furmaata Madaali';

  @override
  String get optionalComment => 'Yaada dabalataa (dirqama miti)...';

  @override
  String get submitFeedback => 'Yaada Ergii';

  @override
  String get feedbackSubmitted => 'Yaadi ergame!';

  @override
  String failedGeneric(String error) {
    return 'Hin milkoofne: $error';
  }

  @override
  String get reportUpdated => 'Gabaasni milkaa\'inaan haaromfame';

  @override
  String updateFailed(String error) {
    return 'Haaromsuu hin milkoofne: $error';
  }

  @override
  String get reportIssueMenu => 'Rakkoo Gabaasi';

  @override
  String get reportDialogTitle => 'Rakkoo Gabaasi';

  @override
  String get reportDialogReason => 'Sababa';

  @override
  String get reportDialogHint => 'Maaliif rakkoon kun barbaachisaa miti?';

  @override
  String get cancel => 'Dhiisi';

  @override
  String get submit => 'Ergii';

  @override
  String get reportedForReview => 'Rakkoon sakatta\'uuf gabaafame.';

  @override
  String get failedToReport => 'Rakkoo gabaasuu hin danda\'amne.';

  @override
  String get anonymousCitizen => 'Lammii Maqaa Hin Qabnee';

  @override
  String get notLoggedIn => 'Hin seenamne.';

  @override
  String get navFeed => 'Oduu';

  @override
  String get navMyReports => 'Gabaasawwan Koo';

  @override
  String get navProfile => 'Profaayilii';

  @override
  String get catWater => 'Bishaan';

  @override
  String get catWaste => 'Xurii';

  @override
  String get catRoad => 'Daandii';

  @override
  String get catElectricity => 'Ibsaa';

  @override
  String get catOther => 'Kan biroo';

  @override
  String get statusPending => 'Eegataa';

  @override
  String get statusInProgress => 'Hojiirra';

  @override
  String get statusResolved => 'Furmaata Argate';

  @override
  String get reportDetail => 'Bal\'ina Gabaasaa';

  @override
  String get communityDiscussion => 'Mari Hawaasaa';

  @override
  String commentsCount(int count) {
    return 'Yaada $count';
  }

  @override
  String get noCommentsYet =>
      'Hanga ammaatti yaadni kenname hin jiru. Marii jalqabaa ta\'i!';

  @override
  String get commentHint => 'Yaada gargaaru dabali...';

  @override
  String get reportLocation => 'Bakka Gabaasaa';
}
