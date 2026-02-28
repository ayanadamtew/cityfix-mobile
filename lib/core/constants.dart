// lib/core/constants.dart
class AppConstants {
  AppConstants._();

  // ---------------------------------------------------------------------------
  // API
  // ---------------------------------------------------------------------------
  static const String baseUrl = 'http://10.22.75.125:5000'; // Set to physical host IP
  // Change to your deployed backend URL before production.

  // ---------------------------------------------------------------------------
  // Hive box names
  // ---------------------------------------------------------------------------
  static const String offlineDraftsBox = 'offline_drafts';
  static const String userBox = 'user_box';
  static const String notificationsBox = 'notifications_box';
  static const String feedBox = 'feed_box';

  // ---------------------------------------------------------------------------
  // Issue categories
  // ---------------------------------------------------------------------------
  static const List<String> categories = [
    'Water',
    'Waste',
    'Road',
    'Electricity',
  ];

  // ---------------------------------------------------------------------------
  // Jimma City Kebeles (17 Urban Kebeles)
  // ---------------------------------------------------------------------------
  static const List<String> jimmaKebeles = [
    'Awetu Mendera',
    'Bachi Bore',
    'Bosa Addis Ketema',
    'Bosa Kito',
    'Ginjo',
    'Ginjo Guduru',
    'Haramata',
    'Haramata Mentina',
    'Hirenjo Obat',
    'Jiren',
    'Kochi',
    'Kofe',
    'Mendera Kochir',
    'Mantalina',
    'Sito',
    'Tule',
    'Seto Semero',
  ];

  // ---------------------------------------------------------------------------
  // Status strings (matching backend enum values)
  // ---------------------------------------------------------------------------
  static const String statusPending = 'pending';
  static const String statusInProgress = 'in_progress';
  static const String statusResolved = 'resolved';
}
