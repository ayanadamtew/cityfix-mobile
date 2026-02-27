// lib/features/my_reports/providers/my_reports_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../feed/providers/feed_provider.dart';
import '../../../core/api_client.dart';

class MyReportsNotifier extends AutoDisposeAsyncNotifier<List<Issue>> {
  @override
  Future<List<Issue>> build() async {
    return _fetchMyReports();
  }

  Future<List<Issue>> _fetchMyReports() async {
    // Use the dedicated /api/issues/mine endpoint which is auth-guarded and
    // filters by citizenId: req.user._id on the backend — guaranteed to be
    // only the current user's issues.
    final resp = await ApiClient.instance.dio.get('/api/issues/mine');

    // Backend returns a direct array from getMyIssues
    final raw = resp.data;
    final List data;
    if (raw is List) {
      data = raw;
    } else if (raw is Map) {
      data = raw['data'] ?? raw['issues'] ?? raw['results'] ?? [];
    } else {
      data = [];
    }

    return data
        .map((json) => Issue.fromJson(json as Map<String, dynamic>))
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
