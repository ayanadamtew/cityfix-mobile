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

  Future<bool> submit({
    required String description,
    required String category,
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
