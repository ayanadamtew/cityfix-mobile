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
    };
  }

  void togglePushNotifications(bool value) {
    final box = Hive.box(AppConstants.userBox);
    box.put('pushNotifications', value);
    state = {...state, 'pushNotifications': value};
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, Map<String, dynamic>>(() {
  return SettingsNotifier();
});
