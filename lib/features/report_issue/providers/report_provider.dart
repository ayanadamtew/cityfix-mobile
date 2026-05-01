// lib/features/report_issue/providers/report_provider.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import '../../../core/api_client.dart';
import '../../../core/constants.dart';
import '../../../services/cloudinary_service.dart';
import '../../feed/providers/feed_provider.dart';

class ReportNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Check for nearby duplicate reports before submission.
  /// Returns the JSON response: { isDuplicate: bool, nearbyReports: [...] }
  Future<Map<String, dynamic>> checkDuplicate({
    required double latitude,
    required double longitude,
    required String category,
  }) async {
    try {
      final res = await ApiClient.instance.dio.get(
        '/api/issues/check-duplicate',
        queryParameters: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'category': category,
        },
      );
      return Map<String, dynamic>.from(res.data);
    } on DioException catch (e) {
      // Only skip silently for true connectivity issues
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return {'isDuplicate': false, 'nearbyReports': []};
      }
      // For server errors (404, 500, etc.), still allow submission
      // but log for debugging
      // ignore: avoid_print
      print('[CityFix] checkDuplicate failed: ${e.response?.statusCode} ${e.message}');
      return {'isDuplicate': false, 'nearbyReports': []};
    }
  }

  Future<bool> submit({
    required String description,
    required String category,
    required String? subcategory,
    required double latitude,
    required double longitude,
    required String address,
    required String kebele,
    required String? localPhotoPath,
  }) async {
    state = const AsyncLoading();
    bool isOfflineSaved = false;
    
    state = await AsyncValue.guard(() async {
      // 1. Check connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOffline = connectivityResult.every((r) =>
          r == ConnectivityResult.none);

      if (isOffline) {
        // Save to Drafts
        final box = Hive.box(AppConstants.offlineDraftsBox);
        final draftId = DateTime.now().millisecondsSinceEpoch.toString();
        final payload = {
          'id': draftId,
          'description': description,
          'category': category,
          'subcategory': subcategory,
          'latitude': latitude,
          'longitude': longitude,
          'address': address,
          'kebele': kebele,
          'localPhotoPath': localPhotoPath,
          'draftedAt': DateTime.now().toIso8601String(),
        };
        await box.put(draftId, jsonEncode(payload));
        isOfflineSaved = true; // offline saved
      } else {
        // Submit online
        String? photoUrl;
        if (localPhotoPath != null) {
          photoUrl = await ref.read(cloudinaryServiceProvider).uploadImage(localPhotoPath);
        }

        final payload = {
          'category': category,
          if (subcategory != null) 'subcategory': subcategory,
          'description': description,
          'location': {
            'latitude': latitude,
            'longitude': longitude,
            'address': address,
            'kebele': kebele,
          },
          if (photoUrl != null) 'photoUrl': photoUrl,
        };

        try {
          await ApiClient.instance.dio.post('/api/issues', data: payload);
          // Refresh feed
          ref.invalidate(feedProvider(const FeedFilter()));
          isOfflineSaved = false; // submitted online
        } on DioException catch (e) {
          throw Exception(e.response?.data['error'] ?? e.message);
        }
      }
    });

    if (state.hasError) throw state.error!;
    return isOfflineSaved;
  }
}

final reportProvider =
    AutoDisposeAsyncNotifierProvider<ReportNotifier, void>(() => ReportNotifier());
