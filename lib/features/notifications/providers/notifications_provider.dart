import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants.dart';

// Very simple data model for local historic notifications
class LocalNotification {
  final String title;
  final String body;
  final DateTime timestamp;
  final String? issueId;

  LocalNotification({
    required this.title,
    required this.body,
    required this.timestamp,
    this.issueId,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'issueId': issueId,
    };
  }

  factory LocalNotification.fromMap(Map<String, dynamic> map) {
    return LocalNotification(
      title: map['title'] ?? 'Notification',
      body: map['body'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      issueId: map['issueId'],
    );
  }
  
  String toJson() => json.encode(toMap());
  factory LocalNotification.fromJson(String source) => LocalNotification.fromMap(json.decode(source));
}

class NotificationsNotifier extends Notifier<List<LocalNotification>> {
  @override
  List<LocalNotification> build() {
    return _loadFromDisk();
  }

  List<LocalNotification> _loadFromDisk() {
    final box = Hive.box(AppConstants.notificationsBox);
    final rawList = box.get('history', defaultValue: <dynamic>[]) as List<dynamic>;
    
    return rawList.map((dynamic item) => LocalNotification.fromJson(item as String)).toList();
  }

  void addNotification(LocalNotification notification) {
    state = [notification, ...state];
    _saveToDisk();
  }
  
  void clearHistory() {
    state = [];
    _saveToDisk();
  }

  void _saveToDisk() {
    final box = Hive.box(AppConstants.notificationsBox);
    final stringList = state.map((n) => n.toJson()).toList();
    box.put('history', stringList);
  }
}

final notificationsProvider = NotifierProvider<NotificationsNotifier, List<LocalNotification>>(() {
  return NotificationsNotifier();
});
