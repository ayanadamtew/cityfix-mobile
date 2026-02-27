// lib/features/auth/providers/auth_provider.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/api_client.dart';

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
    required this.email,
    this.photoUrl,
  });

  final String id;
  final String name;
  final String email;
  final String? photoUrl;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final u = json['user'] as Map<String, dynamic>? ?? json;
    return UserProfile(
      id: u['_id'] as String? ?? u['id'] as String? ?? '',
      name: u['name'] as String? ?? '',
      email: u['email'] as String? ?? '',
      photoUrl: u['photoUrl'] as String?,
    );
  }
}

class AuthNotifier extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() async {
    // If the user already has a Firebase session (e.g. from a previous launch),
    // sync with the backend immediately to retrieve their Mongo _id
    // This is required so voting and matching logic uses _id, not Firebase UID.
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
  // Register new account
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
  // Logout
  // ---------------------------------------------------------------------------
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    state = const AsyncData(null);
  }

  // ---------------------------------------------------------------------------
  // Sync Firebase user → backend MongoDB
  // ---------------------------------------------------------------------------
  Future<UserProfile?> _syncWithBackend({String? name}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final token = await user.getIdToken();
    try {
      final resp = await ApiClient.instance.dio.post(
        '/api/auth/register',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: {
          'fullName': name ?? user.displayName ?? user.email?.split('@').first,
          'role': 'CITIZEN',
          'email': user.email,
          'firebaseUid': user.uid,
        },
      );
      return UserProfile.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (_) {
      // Tolerate backend errors (e.g., user already registered)
      return UserProfile(
        id: user.uid,
        name: user.displayName ?? '',
        email: user.email ?? '',
      );
    }
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, UserProfile?>(() => AuthNotifier());
