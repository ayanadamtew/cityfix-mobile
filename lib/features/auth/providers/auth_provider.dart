// lib/features/auth/providers/auth_provider.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart';
import '../../../core/api_client.dart';
import '../../../core/push_notification_service.dart';

// ---------------------------------------------------------------------------
// Current user stream provider
// ---------------------------------------------------------------------------
final authStateProvider = StreamProvider<User?>(
  (ref) => FirebaseAuth.instance.authStateChanges(),
);

// ---------------------------------------------------------------------------
// Logged-in user profile from backend (synced after Firebase login)
// ---------------------------------------------------------------------------
class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    this.email,
    this.phoneNumber,
    this.photoUrl,
  });

  final String id;
  final String name;
  final String? email;
  final String? phoneNumber;
  final String? photoUrl;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final u = json['user'] as Map<String, dynamic>? ?? json;
    return UserProfile(
      id: u['_id'] as String? ?? u['id'] as String? ?? '',
      name: u['fullName'] as String? ?? u['name'] as String? ?? '',
      email: u['email'] as String?,
      phoneNumber: u['phoneNumber'] as String?,
      photoUrl: u['photoUrl'] as String?,
    );
  }
}

class AuthNotifier extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() async {
    if (FirebaseAuth.instance.currentUser != null) {
      return _syncWithBackend();
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Email / Password login
  // ---------------------------------------------------------------------------
  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return _syncWithBackend();
    });
  }

  // ---------------------------------------------------------------------------
  // Register new account (email + password)
  // ---------------------------------------------------------------------------
  Future<void> register(String name, String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await FirebaseAuth.instance.currentUser?.updateDisplayName(name);
      return _syncWithBackend(name: name);
    });
  }

  // ---------------------------------------------------------------------------
  // Phone / Password login (using dummy email workaround)
  // ---------------------------------------------------------------------------
  Future<void> loginWithPhone(String phone, String password) async {
    final dummyEmail = '$phone@cityfix.local';
    await login(dummyEmail, password);
  }

  // ---------------------------------------------------------------------------
  // Register with Phone (using dummy email workaround)
  // ---------------------------------------------------------------------------
  Future<void> registerWithPhone(String name, String phone, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final dummyEmail = '$phone@cityfix.local';
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: dummyEmail, password: password);
      await FirebaseAuth.instance.currentUser?.updateDisplayName(name);
      return _syncWithBackend(name: name, providedPhone: phone);
    });
  }

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    state = const AsyncData(null);
  }

  // ---------------------------------------------------------------------------
  // Sync Firebase user → backend MongoDB
  // ---------------------------------------------------------------------------
  Future<UserProfile?> _syncWithBackend({String? name, String? providedPhone}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final token = await user.getIdToken();
    try {
      final realEmail = (user.email != null && !user.email!.endsWith('@cityfix.local')) ? user.email : null;
      
      final resp = await ApiClient.instance.dio.post(
        '/api/auth/register',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: {
          'fullName': name ?? user.displayName ?? providedPhone ?? user.phoneNumber ?? user.email?.split('@').first ?? 'User',
          'role': 'CITIZEN',
          if (realEmail != null) 'email': realEmail,
          if (providedPhone != null || user.phoneNumber != null) 'phoneNumber': providedPhone ?? user.phoneNumber,
          'firebaseUid': user.uid,
        },
      );

      // Ensure the newly authenticated Mongo session has the device's FCM token
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await PushNotificationService.syncTokenWithBackend(fcmToken);
      }

      return UserProfile.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (_) {
      return UserProfile(
        id: user.uid,
        name: user.displayName ?? user.phoneNumber ?? '',
        email: user.email,
        phoneNumber: user.phoneNumber,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Update Profile (Name)
  // ---------------------------------------------------------------------------
  Future<void> updateProfile(String newName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await user.updateDisplayName(newName);

      final token = await user.getIdToken();
      final resp = await ApiClient.instance.dio.put(
        '/api/auth/profile',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: {
          'fullName': newName,
        },
      );

      return UserProfile.fromJson(resp.data as Map<String, dynamic>);
    });
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, UserProfile?>(() => AuthNotifier());
