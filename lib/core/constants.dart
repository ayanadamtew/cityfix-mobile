// lib/core/constants.dart
class AppConstants {
  AppConstants._();

  // ---------------------------------------------------------------------------
  // API
  // ---------------------------------------------------------------------------
  static const String baseUrl = 'http://10.202.97.125:5000'; // Set to physical host IP
  // static const String baseUrl = 'https://cityfix-backend-4jz2.onrender.com';
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

  static const Map<String, List<String>> subcategories = {
    'Water': [
      'Pipe Leakage',
      'Water Supply Interruption',
      'Drainage Blockage',
      'Sewer Overflow',
      'Broken Water Pipe',
      'Low Water Pressure',
    ],
    'Road': [
      'Pothole',
      'Road Crack',
      'Road Blockage',
      'Damaged Sidewalk',
      'Broken Traffic Sign',
      'Flooded Road',
    ],
    'Electricity': [
      'Street Light Failure',
      'Power Outage',
      'Exposed Wire',
      'Damaged Electric Pole',
      'Transformer Issue',
      'Electrical Hazard',
    ],
    'Waste': [
      'Uncollected Garbage',
      'Overflowing Bin',
      'Illegal Dumping',
      'Blocked Waste Channel',
      'Dead Animal Removal',
      'Recycling Issue',
    ],
  };

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
  static const String statusWaitingConfirmation = 'waiting confirmation';
  static const String statusResolved = 'resolved';
}
