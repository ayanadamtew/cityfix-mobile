// lib/services/offline_sync_service.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../core/api_client.dart';
import '../core/constants.dart';
import 'cloudinary_service.dart';

class OfflineSyncService {
  final CloudinaryService _cloudinaryService = CloudinaryService();

  OfflineSyncService() {
    _initListener();
  }

  bool _isSyncing = false;

  void _initListener() {
    Connectivity().onConnectivityChanged.listen((results) {
      final hasInternet = results.any((r) =>
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.ethernet);
          
      if (hasInternet && !_isSyncing) {
        syncDrafts();
      }
    });
  }

  Future<void> syncDrafts() async {
    _isSyncing = true;
    try {
      final box = Hive.box(AppConstants.offlineDraftsBox);
      final keys = box.keys.toList();

      for (var key in keys) {
        final draftStr = box.get(key) as String?;
        if (draftStr == null) continue;

        final draft = jsonDecode(draftStr) as Map<String, dynamic>;
        
        // 1. Upload photo if exists
        String? photoUrl;
        final localPhotoPath = draft['localPhotoPath'] as String?;
        
        if (localPhotoPath != null && localPhotoPath.isNotEmpty) {
          final file = File(localPhotoPath);
          if (await file.exists()) {
            photoUrl = await _cloudinaryService.uploadImage(localPhotoPath);
          }
        }

        // 2. Post to API
        final payload = {
          'title': draft['title'],
          'description': draft['description'],
          'category': draft['category'],
          'location': {
            'type': 'Point',
            'coordinates': [draft['longitude'], draft['latitude']]
          },
          'address': draft['address'],
          'photoUrl': photoUrl,
        };

        try {
          await ApiClient.instance.dio.post('/api/issues', data: payload);
          // Success! Delete draft
          await box.delete(key);
        } on DioException catch (e) {
          // If it's a 4xx error (validation), delete it to prevent infinite loops.
          // If it's 5xx or network err, keep it for next retry.
          if (e.response != null && e.response!.statusCode! >= 400 && e.response!.statusCode! < 500) {
            await box.delete(key);
          }
        }
      }
    } catch (_) {
    } finally {
      _isSyncing = false;
    }
  }

  // Allow manual triggering
  Future<void> triggerSync() => syncDrafts();
}

// Ensure it starts listening as soon as instantiated
final offlineSyncServiceProvider = Provider<OfflineSyncService>((ref) {
  return OfflineSyncService();
});
