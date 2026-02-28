import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../feed/providers/feed_provider.dart';
import '../../../core/api_client.dart';
import '../../../core/constants.dart';

class MyReportsNotifier extends AutoDisposeAsyncNotifier<List<Issue>> {
  @override
  Future<List<Issue>> build() async {
    return _fetchMyReports();
  }

  Future<List<Issue>> _fetchMyReports() async {
    // Use the dedicated /api/issues/mine endpoint which is auth-guarded and
    // filters by citizenId: req.user._id on the backend — guaranteed to be
    // only the current user's issues.
    var data;
    try {
      final resp = await ApiClient.instance.dio.get('/api/issues/mine');

      // Backend returns a direct array from getMyIssues
      final raw = resp.data;
      if (raw is List) {
        data = raw;
      } else if (raw is Map) {
        data = raw['data'] ?? raw['issues'] ?? raw['results'] ?? [];
      } else {
        data = [];
      }

      // Cache the raw data for offline use
      final box = Hive.box(AppConstants.feedBox);
      await box.put('my_reports', jsonEncode(data));
    } catch (e) {
      // If network fails, try loading from cache
      final box = Hive.box(AppConstants.feedBox);
      final cachedJson = box.get('my_reports') as String?;
      
      if (cachedJson != null) {
        data = jsonDecode(cachedJson) as List;
      } else {
        // Rethrow if no cache available
        rethrow;
      }
    }

    return (data as List)
        .map<Issue>((json) => Issue.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchMyReports());
  }

  Future<void> submitFeedback(String issueId, double rating, String text) async {
    await ApiClient.instance.dio.post(
      '/api/issues/$issueId/feedback',
      data: {
        'rating': rating,
        'comment': text,
      },
    );
    // Refresh list to update badge/status if needed
    ref.invalidateSelf();
  }

  Future<void> updateIssue(
    String issueId,
    String description,
    String category,
    String kebele,
    Issue oldIssue,
  ) async {
    // We must send the whole location object back or the backend will overwrite it
    // with just the new Kebele, erasing the GPS coordinates.
    final payload = {
      'description': description,
      'category': category,
      'location': {
        'latitude': oldIssue.latitude(),
        'longitude': oldIssue.longitude(),
        'address': oldIssue.rawLocation?['address'] ?? '',
        'kebele': kebele,
      },
    };

    await ApiClient.instance.dio.put('/api/issues/$issueId', data: payload);

    // Refresh the local my reports list
    ref.invalidateSelf();
    // Also invalidate the main feed so the public sees the update immediately
    ref.invalidate(feedProvider(const FeedFilter()));
  }
}

final myReportsProvider =
    AutoDisposeAsyncNotifierProvider<MyReportsNotifier, List<Issue>>(
  () => MyReportsNotifier(),
);
