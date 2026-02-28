import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_en.dart';
import 'app_localizations_om.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('am'),
    Locale('en'),
    Locale('om')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'CityFix Jimma'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Jimma City Civic Reporting'**
  String get appSubtitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailHint;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get emailInvalid;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordRequired;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get noAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Abebe Bekele'**
  String get fullNameHint;

  /// No description provided for @fullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get fullNameRequired;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get alreadyHaveAccount;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @verifiedCitizen.
  ///
  /// In en, this message translates to:
  /// **'Verified Citizen'**
  String get verifiedCitizen;

  /// No description provided for @unverified.
  ///
  /// In en, this message translates to:
  /// **'Unverified'**
  String get unverified;

  /// No description provided for @yourImpact.
  ///
  /// In en, this message translates to:
  /// **'Your Impact'**
  String get yourImpact;

  /// No description provided for @totalReports.
  ///
  /// In en, this message translates to:
  /// **'Total Reports'**
  String get totalReports;

  /// No description provided for @resolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get resolved;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings & Preferences'**
  String get settingsTitle;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @pushEnabled.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications Enabled.'**
  String get pushEnabled;

  /// No description provided for @pushDisabled.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications Disabled.'**
  String get pushDisabled;

  /// No description provided for @appTheme.
  ///
  /// In en, this message translates to:
  /// **'App Theme'**
  String get appTheme;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @helpContent.
  ///
  /// In en, this message translates to:
  /// **'If you need assistance using the CityFix app, please contact the Jimma City municipal office at support@cityfix.com or call 911 for emergencies.'**
  String get helpContent;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @privacyIntro.
  ///
  /// In en, this message translates to:
  /// **'Your privacy is important to us. This policy explains how we handle your data.'**
  String get privacyIntro;

  /// No description provided for @privacyDataCollection.
  ///
  /// In en, this message translates to:
  /// **'1. Data Collection\nWe collect location and photo data strictly for public civic issue reporting, minimizing personal telemetry.'**
  String get privacyDataCollection;

  /// No description provided for @privacyDataSecurity.
  ///
  /// In en, this message translates to:
  /// **'2. Data Security\nWe encrypt your data aligning with standard municipality guidelines.'**
  String get privacyDataSecurity;

  /// No description provided for @privacyNotifications.
  ///
  /// In en, this message translates to:
  /// **'3. Push Notifications\nWe use Firebase Cloud Messaging securely to update you on issue resolutions locally.'**
  String get privacyNotifications;

  /// No description provided for @feedNear.
  ///
  /// In en, this message translates to:
  /// **'Near'**
  String get feedNear;

  /// No description provided for @feedNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get feedNew;

  /// No description provided for @feedUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get feedUrgent;

  /// No description provided for @feedEverywhere.
  ///
  /// In en, this message translates to:
  /// **'Everywhere'**
  String get feedEverywhere;

  /// No description provided for @feedSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search issues...'**
  String get feedSearchHint;

  /// No description provided for @feedNoIssues.
  ///
  /// In en, this message translates to:
  /// **'No issues reported yet.'**
  String get feedNoIssues;

  /// No description provided for @feedBeFirst.
  ///
  /// In en, this message translates to:
  /// **'Be the first to report a problem!'**
  String get feedBeFirst;

  /// No description provided for @feedLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load feed'**
  String get feedLoadError;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up!'**
  String get noNotifications;

  /// No description provided for @upvoted.
  ///
  /// In en, this message translates to:
  /// **'Upvoted ({score})'**
  String upvoted(int score);

  /// No description provided for @upvote.
  ///
  /// In en, this message translates to:
  /// **'Upvote ({score})'**
  String upvote(int score);

  /// No description provided for @reportAnIssue.
  ///
  /// In en, this message translates to:
  /// **'Report an Issue'**
  String get reportAnIssue;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @kebele.
  ///
  /// In en, this message translates to:
  /// **'Kebele (Neighborhood)'**
  String get kebele;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @detailedDescription.
  ///
  /// In en, this message translates to:
  /// **'Detailed Description'**
  String get detailedDescription;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the issue...'**
  String get descriptionHint;

  /// No description provided for @tapToPhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to take a photo'**
  String get tapToPhoto;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @detectLocation.
  ///
  /// In en, this message translates to:
  /// **'Detect Current Location'**
  String get detectLocation;

  /// No description provided for @locationInstruction.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to set a location, or press detect.'**
  String get locationInstruction;

  /// No description provided for @locationPinpointed.
  ///
  /// In en, this message translates to:
  /// **'Location pinpointed'**
  String get locationPinpointed;

  /// No description provided for @locationSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected: {address}'**
  String locationSelected(String address);

  /// No description provided for @locationError.
  ///
  /// In en, this message translates to:
  /// **'Location error: {error}'**
  String locationError(String error);

  /// No description provided for @locationRequired.
  ///
  /// In en, this message translates to:
  /// **'Please detect your location or tap on the map'**
  String get locationRequired;

  /// No description provided for @submitReport.
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get submitReport;

  /// No description provided for @reportSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved to Offline Drafts. Will sync automatically.'**
  String get reportSaved;

  /// No description provided for @reportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Issue reported successfully!'**
  String get reportSuccess;

  /// No description provided for @failedToSubmit.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit: {error}'**
  String failedToSubmit(String error);

  /// No description provided for @fetchingAddress.
  ///
  /// In en, this message translates to:
  /// **'Fetching address...'**
  String get fetchingAddress;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @myReports.
  ///
  /// In en, this message translates to:
  /// **'My Reports'**
  String get myReports;

  /// No description provided for @noReportsYet.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t reported anything yet.'**
  String get noReportsYet;

  /// No description provided for @editReport.
  ///
  /// In en, this message translates to:
  /// **'Edit Report'**
  String get editReport;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @updateMapLocation.
  ///
  /// In en, this message translates to:
  /// **'Update Map Location'**
  String get updateMapLocation;

  /// No description provided for @rateResolution.
  ///
  /// In en, this message translates to:
  /// **'Rate the Resolution'**
  String get rateResolution;

  /// No description provided for @optionalComment.
  ///
  /// In en, this message translates to:
  /// **'Optional comment...'**
  String get optionalComment;

  /// No description provided for @submitFeedback.
  ///
  /// In en, this message translates to:
  /// **'Submit Feedback'**
  String get submitFeedback;

  /// No description provided for @feedbackSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Feedback Submitted!'**
  String get feedbackSubmitted;

  /// No description provided for @failedGeneric.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String failedGeneric(String error);

  /// No description provided for @reportUpdated.
  ///
  /// In en, this message translates to:
  /// **'Report Updated Successfully'**
  String get reportUpdated;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed: {error}'**
  String updateFailed(String error);

  /// No description provided for @reportIssueMenu.
  ///
  /// In en, this message translates to:
  /// **'Report Issue'**
  String get reportIssueMenu;

  /// No description provided for @reportDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Report Issue'**
  String get reportDialogTitle;

  /// No description provided for @reportDialogReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reportDialogReason;

  /// No description provided for @reportDialogHint.
  ///
  /// In en, this message translates to:
  /// **'Why is this issue unnecessary or inappropriate?'**
  String get reportDialogHint;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @reportedForReview.
  ///
  /// In en, this message translates to:
  /// **'Issue reported for review successfully.'**
  String get reportedForReview;

  /// No description provided for @failedToReport.
  ///
  /// In en, this message translates to:
  /// **'Failed to report issue.'**
  String get failedToReport;

  /// No description provided for @anonymousCitizen.
  ///
  /// In en, this message translates to:
  /// **'Anonymous Citizen'**
  String get anonymousCitizen;

  /// No description provided for @notLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Not logged in.'**
  String get notLoggedIn;

  /// No description provided for @navFeed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get navFeed;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navMyReports.
  ///
  /// In en, this message translates to:
  /// **'My Reports'**
  String get navMyReports;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @catWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get catWater;

  /// No description provided for @catWaste.
  ///
  /// In en, this message translates to:
  /// **'Waste'**
  String get catWaste;

  /// No description provided for @catRoad.
  ///
  /// In en, this message translates to:
  /// **'Road'**
  String get catRoad;

  /// No description provided for @catElectricity.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get catElectricity;

  /// No description provided for @catOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get catOther;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statusInProgress;

  /// No description provided for @statusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get statusResolved;

  /// No description provided for @reportDetail.
  ///
  /// In en, this message translates to:
  /// **'Report Detail'**
  String get reportDetail;

  /// No description provided for @communityDiscussion.
  ///
  /// In en, this message translates to:
  /// **'Community Discussion'**
  String get communityDiscussion;

  /// No description provided for @commentsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} comments'**
  String commentsCount(int count);

  /// No description provided for @noCommentsYet.
  ///
  /// In en, this message translates to:
  /// **'No comments yet. Start the conversation!'**
  String get noCommentsYet;

  /// No description provided for @commentHint.
  ///
  /// In en, this message translates to:
  /// **'Add a helpful comment...'**
  String get commentHint;

  /// No description provided for @reportLocation.
  ///
  /// In en, this message translates to:
  /// **'Report Location'**
  String get reportLocation;

  /// No description provided for @offlineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline Mode - Viewing Cached Data'**
  String get offlineMode;

  /// No description provided for @youAreOffline.
  ///
  /// In en, this message translates to:
  /// **'You are offline. Interactions are disabled.'**
  String get youAreOffline;

  /// No description provided for @backOnline.
  ///
  /// In en, this message translates to:
  /// **'Back online. Connectivity restored!'**
  String get backOnline;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdated;

  /// No description provided for @profileUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get profileUpdateFailed;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get enterName;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;
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
      <String>['am', 'en', 'om'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
    case 'en':
      return AppLocalizationsEn();
    case 'om':
      return AppLocalizationsOm();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
