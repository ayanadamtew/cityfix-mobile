// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CityFix Jimma';

  @override
  String get appSubtitle => 'Jimma City Civic Reporting';

  @override
  String get login => 'Login';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get password => 'Password';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Enter a valid email';

  @override
  String get passwordRequired => 'Password must be at least 6 characters';

  @override
  String get noAccount => 'Don\'t have an account? Register';

  @override
  String get createAccount => 'Create Account';

  @override
  String get fullName => 'Full Name';

  @override
  String get fullNameHint => 'Abebe Bekele';

  @override
  String get fullNameRequired => 'Name is required';

  @override
  String get alreadyHaveAccount => 'Already have an account? Login';

  @override
  String get profile => 'Profile';

  @override
  String get verifiedCitizen => 'Verified Citizen';

  @override
  String get unverified => 'Unverified';

  @override
  String get yourImpact => 'Your Impact';

  @override
  String get totalReports => 'Total Reports';

  @override
  String get resolved => 'Resolved';

  @override
  String get settingsTitle => 'Settings & Preferences';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get pushEnabled => 'Push Notifications Enabled.';

  @override
  String get pushDisabled => 'Push Notifications Disabled.';

  @override
  String get appTheme => 'App Theme';

  @override
  String get systemDefault => 'System Default';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get helpContent =>
      'If you need assistance using the CityFix app, please contact the Jimma City municipal office at support@cityfix.com or call 911 for emergencies.';

  @override
  String get close => 'Close';

  @override
  String get signOut => 'Sign Out';

  @override
  String get privacyIntro =>
      'Your privacy is important to us. This policy explains how we handle your data.';

  @override
  String get privacyDataCollection =>
      '1. Data Collection\nWe collect location and photo data strictly for public civic issue reporting, minimizing personal telemetry.';

  @override
  String get privacyDataSecurity =>
      '2. Data Security\nWe encrypt your data aligning with standard municipality guidelines.';

  @override
  String get privacyNotifications =>
      '3. Push Notifications\nWe use Firebase Cloud Messaging securely to update you on issue resolutions locally.';

  @override
  String get feedNear => 'Near';

  @override
  String get feedNew => 'New';

  @override
  String get feedUrgent => 'Urgent';

  @override
  String get feedEverywhere => 'Everywhere';

  @override
  String get feedSearchHint => 'Search issues...';

  @override
  String get feedNoIssues => 'No issues reported yet.';

  @override
  String get feedBeFirst => 'Be the first to report a problem!';

  @override
  String get feedLoadError => 'Unable to load feed';

  @override
  String get notifications => 'Notifications';

  @override
  String get clearAll => 'Clear All';

  @override
  String get noNotifications => 'You\'re all caught up!';

  @override
  String upvoted(int score) {
    return 'Upvoted ($score)';
  }

  @override
  String upvote(int score) {
    return 'Upvote ($score)';
  }

  @override
  String get reportAnIssue => 'Report an Issue';

  @override
  String get category => 'Category';

  @override
  String get kebele => 'Kebele (Neighborhood)';

  @override
  String get description => 'Description';

  @override
  String get detailedDescription => 'Detailed Description';

  @override
  String get descriptionHint => 'Describe the issue...';

  @override
  String get tapToPhoto => 'Tap to take a photo';

  @override
  String get location => 'Location';

  @override
  String get detectLocation => 'Detect Current Location';

  @override
  String get locationInstruction =>
      'Tap the map to set a location, or press detect.';

  @override
  String get locationPinpointed => 'Location pinpointed';

  @override
  String locationSelected(String address) {
    return 'Selected: $address';
  }

  @override
  String locationError(String error) {
    return 'Location error: $error';
  }

  @override
  String get locationRequired =>
      'Please detect your location or tap on the map';

  @override
  String get submitReport => 'Submit Report';

  @override
  String get reportSaved => 'Saved to Offline Drafts. Will sync automatically.';

  @override
  String get reportSuccess => 'Issue reported successfully!';

  @override
  String failedToSubmit(String error) {
    return 'Failed to submit: $error';
  }

  @override
  String get fetchingAddress => 'Fetching address...';

  @override
  String get required => 'Required';

  @override
  String get myReports => 'My Reports';

  @override
  String get noReportsYet => 'You haven\'t reported anything yet.';

  @override
  String get editReport => 'Edit Report';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get updateMapLocation => 'Update Map Location';

  @override
  String get rateResolution => 'Rate the Resolution';

  @override
  String get optionalComment => 'Optional comment...';

  @override
  String get submitFeedback => 'Submit Feedback';

  @override
  String get feedbackSubmitted => 'Feedback Submitted!';

  @override
  String failedGeneric(String error) {
    return 'Failed: $error';
  }

  @override
  String get reportUpdated => 'Report Updated Successfully';

  @override
  String updateFailed(String error) {
    return 'Update failed: $error';
  }

  @override
  String get reportIssueMenu => 'Report Issue';

  @override
  String get reportDialogTitle => 'Report Issue';

  @override
  String get reportDialogReason => 'Reason';

  @override
  String get reportDialogHint =>
      'Why is this issue unnecessary or inappropriate?';

  @override
  String get cancel => 'Cancel';

  @override
  String get submit => 'Submit';

  @override
  String get reportedForReview => 'Issue reported for review successfully.';

  @override
  String get failedToReport => 'Failed to report issue.';

  @override
  String get anonymousCitizen => 'Anonymous Citizen';

  @override
  String get notLoggedIn => 'Not logged in.';

  @override
  String get navFeed => 'Feed';

  @override
  String get navSearch => 'Search';

  @override
  String get navMyReports => 'My Reports';

  @override
  String get navProfile => 'Profile';

  @override
  String get catWater => 'Water';

  @override
  String get catWaste => 'Waste';

  @override
  String get catRoad => 'Road';

  @override
  String get catElectricity => 'Electricity';

  @override
  String get catOther => 'Other';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusInProgress => 'In Progress';

  @override
  String get statusResolved => 'Resolved';

  @override
  String get reportDetail => 'Report Detail';

  @override
  String get communityDiscussion => 'Community Discussion';

  @override
  String commentsCount(int count) {
    return '$count comments';
  }

  @override
  String get noCommentsYet => 'No comments yet. Start the conversation!';

  @override
  String get commentHint => 'Add a helpful comment...';

  @override
  String get reportLocation => 'Report Location';

  @override
  String get offlineMode => 'Offline Mode - Viewing Cached Data';

  @override
  String get youAreOffline => 'You are offline. Interactions are disabled.';

  @override
  String get backOnline => 'Back online. Connectivity restored!';
}
