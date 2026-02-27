import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants.dart';

// Provides the user settings state
class SettingsNotifier extends Notifier<Map<String, dynamic>> {
  @override
  Map<String, dynamic> build() {
    final box = Hive.box(AppConstants.userBox);
    return {
      'pushNotifications': box.get('pushNotifications', defaultValue: true),
      'themeMode': box.get('themeMode', defaultValue: 'system'),
    };
  }

  void togglePushNotifications(bool value) {
    final box = Hive.box(AppConstants.userBox);
    box.put('pushNotifications', value);
    state = {...state, 'pushNotifications': value};
  }

  void updateThemeMode(String mode) {
    final box = Hive.box(AppConstants.userBox);
    box.put('themeMode', mode);
    state = {...state, 'themeMode': mode};
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, Map<String, dynamic>>(() {
  return SettingsNotifier();
});
