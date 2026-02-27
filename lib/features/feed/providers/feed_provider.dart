// lib/features/feed/providers/feed_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/api_client.dart';
import '../../../services/location_service.dart';
import '../../../core/providers/socket_provider.dart';

// ---------------------------------------------------------------------------
// Filter Options
// ---------------------------------------------------------------------------
class FeedFilter {
  const FeedFilter({
    this.sort = 'closest',
    this.kebele = 'All',
    this.search = '',
  });

  final String sort;
  final String kebele;
  final String search;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedFilter &&
          other.sort == sort &&
          other.kebele == kebele &&
          other.search == search);

  @override
  int get hashCode => sort.hashCode ^ kebele.hashCode ^ search.hashCode;

  FeedFilter copyWith({
    String? sort,
    String? kebele,
    String? search,
  }) {
    return FeedFilter(
      sort: sort ?? this.sort,
      kebele: kebele ?? this.kebele,
      search: search ?? this.search,
    );
  }
}

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------
class Issue {
  const Issue({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.photoUrl,
    required this.urgencyScore,
    required this.createdAt,
    this.authorId,
    this.authorName,
    this.authorPhotoUrl,
    this.commentCount = 0,
    this.voterIds = const [],
    this.rawLocation,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final String status;
  final String photoUrl;
  final int urgencyScore;
  final DateTime createdAt;
  // MongoDB _id of the citizen who created this issue (from citizenId._id)
  final String? authorId;
  final String? authorName;
  final String? authorPhotoUrl;
  final int commentCount;
  // List of user IDs who have already voted — used to prevent double-voting
  final List<String> voterIds;

  // The raw JSON location object from backend
  final Map<String, dynamic>? rawLocation;

  // Helpers to safely extract coordinates for 'Closest' sorting
  double? latitude() => double.tryParse(rawLocation?['latitude']?.toString() ?? '');
  double? longitude() => double.tryParse(rawLocation?['longitude']?.toString() ?? '');

  factory Issue.fromJson(Map<String, dynamic> json) {
    // Safely parse an int that may come back as String from some backends
    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    // Safely extract a nested author field from citizenId (backend field name)
    String? citizenField(String key) {
      // Backend uses 'citizenId' (not 'author') as the populated reference
      final citizen = json['citizenId'];
      if (citizen == null) return null;
      if (citizen is Map) return citizen[key]?.toString();
      return null;
    }

    // Extract the MongoDB _id of the author from the citizenId object
    // Falls back to direct string citizenId (un-populated reference)
    String? parseAuthorId() {
      final citizen = json['citizenId'];
      if (citizen == null) return null;
      if (citizen is Map) {
        return citizen['_id']?.toString() ?? citizen['firebaseUid']?.toString();
      }
      // citizenId is a raw ObjectId string (not populated)
      return citizen.toString();
    }

    // Parse the list of voter IDs (backend may call it upvotedBy, voters, votedBy, etc.)
    List<String> parseVoters(dynamic v) {
      if (v == null) return [];
      if (v is List) return v.map((e) => e.toString()).toList();
      return [];
    }

    // Comment count — derive from array length if backend embeds comments array
    int commentCount;
    final commentsRaw = json['comments'];
    if (commentsRaw is List) {
      commentCount = commentsRaw.length;
    } else {
      commentCount = parseInt(json['commentCount'] ?? json['commentsCount']);
    }

    return Issue(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Other',
      status: json['status']?.toString() ?? 'pending',
      photoUrl: json['photoUrl']?.toString() ?? '',
      urgencyScore: parseInt(json['urgencyCount'] ?? json['urgencyScore']),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      authorId: parseAuthorId(),
      // citizenId is the populated author reference in the backend schema
      authorName: citizenField('fullName') ?? citizenField('name'),
      authorPhotoUrl: citizenField('photoUrl'),
      commentCount: commentCount,
      voterIds: parseVoters(
          json['votedUserIds'] ?? json['upvotedBy'] ?? json['voters'] ?? json['votedBy']),
      rawLocation: json['location'] is Map ? json['location'] as Map<String, dynamic> : null,
    );
  }
  Issue copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? status,
    String? photoUrl,
    int? urgencyScore,
    DateTime? createdAt,
    String? authorId,
    String? authorName,
    String? authorPhotoUrl,
    int? commentCount,
    List<String>? voterIds,
    Map<String, dynamic>? rawLocation,
  }) {
    return Issue(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      photoUrl: photoUrl ?? this.photoUrl,
      urgencyScore: urgencyScore ?? this.urgencyScore,
      createdAt: createdAt ?? this.createdAt,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorPhotoUrl: authorPhotoUrl ?? this.authorPhotoUrl,
      commentCount: commentCount ?? this.commentCount,
      voterIds: voterIds ?? this.voterIds,
      rawLocation: rawLocation ?? this.rawLocation, // Preserve raw location mapping during vote updates
    );
  }
}

class Comment {
  const Comment({
    required this.id,
    required this.text,
    required this.authorName,
    required this.createdAt,
    this.isAdmin = false,
    this.adminRoleLabel,
  });

  final String id;
  final String text;
  final String authorName;
  final DateTime createdAt;
  final bool isAdmin;
  final String? adminRoleLabel;

  factory Comment.fromJson(Map<String, dynamic> json) {
    // Backend uses citizenId (same as issues) for the populated commenter
    String extractAuthor(dynamic citizen) {
      if (citizen == null) return 'Anonymous';
      if (citizen is Map) {
        return citizen['fullName']?.toString() ??
            citizen['name']?.toString() ??
            'Anonymous';
      }
      return citizen.toString();
    }

    // Check if the author is an admin based on the role property
    bool checkIsAdmin(dynamic citizen) {
      if (citizen is Map) {
        final role = citizen['role']?.toString();
        return role == 'SECTOR_ADMIN' || role == 'SUPER_ADMIN';
      }
      return false;
    }

    // Determine the admin role label, if any
    String? determineAdminRoleLabel(dynamic citizen) {
      if (citizen is Map) {
        final role = citizen['role']?.toString();
        if (role == 'SUPER_ADMIN') {
          return 'Super Admin';
        } else if (role == 'SECTOR_ADMIN') {
          final dept = citizen['department']?.toString();
          if (dept != null && dept.isNotEmpty) {
            // e.g. "Electricity" -> "Electricity Admin"
            return '$dept Admin';
          }
          return 'Admin';
        }
      }
      return null;
    }

    return Comment(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? json['content']?.toString() ?? '',
      // Backend Comment schema: authorId (populated with fullName, role)
      authorName: extractAuthor(json['authorId'] ?? json['citizenId'] ?? json['author']),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isAdmin: checkIsAdmin(json['authorId'] ?? json['citizenId'] ?? json['author']),
      adminRoleLabel: determineAdminRoleLabel(json['authorId'] ?? json['citizenId'] ?? json['author']),
    );
  }
}

// ---------------------------------------------------------------------------
// Feed Provider (handles filtering & geospatial sorting)
// ---------------------------------------------------------------------------
final feedProvider = AsyncNotifierProviderFamily<FeedNotifier, List<Issue>, FeedFilter>(
  () => FeedNotifier(),
);

class FeedNotifier extends FamilyAsyncNotifier<List<Issue>, FeedFilter> {
  @override
  Future<List<Issue>> build(FeedFilter filter) async {
    // Connect to the socket asynchronously to prevent modifying `socketProvider` during build
    Future.microtask(() => ref.read(socketProvider.notifier).connect());
    
    // Listen to the socket provider securely using Riverpod 2.0 ref.listen
    ref.listen(socketProvider, (previous, socket) {
      if (socket == null) return;
      
      // Clean up old listeners to prevent duplicates
      socket.off('vote_updated');
      socket.off('issue_status_changed');
      socket.off('new_issue');
      socket.off('issue_comment_count_updated');

      socket.on('vote_updated', (data) {
        if (!state.hasValue) return;
        final issueId = data['issueId'] as String;
        final newCount = data['urgencyCount'] as int;

        state = AsyncData(state.value!.map((issue) {
          if (issue.id == issueId) {
            return issue.copyWith(urgencyScore: newCount);
          }
          return issue;
        }).toList());
      });
      
      socket.on('issue_status_changed', (data) {
        if (!state.hasValue) return;
        final issueId = data['issueId'] as String;
        final newStatus = data['status'] as String;

        state = AsyncData(state.value!.map((issue) {
          if (issue.id == issueId) {
            return issue.copyWith(status: newStatus);
          }
          return issue;
        }).toList());
      });

      socket.on('new_issue', (data) {
        if (!state.hasValue) return;
        final newIssue = Issue.fromJson(data as Map<String, dynamic>);
        // Only append if it's not already there (pre-emptively avoiding dupes on fast networks)
        if (!state.value!.any((i) => i.id == newIssue.id)) {
           state = AsyncData([newIssue, ...state.value!]);
        }
      });
      
      socket.on('issue_comment_count_updated', (data) {
        if (!state.hasValue) return;
        final issueId = data['issueId'] as String;
        final newCount = data['commentCount'] as int;

        state = AsyncData(state.value!.map((issue) {
          if (issue.id == issueId) {
            return issue.copyWith(commentCount: newCount);
          }
          return issue;
        }).toList());
      });
    }, fireImmediately: true);

    return _fetchIssues(filter);
  }

  Future<List<Issue>> _fetchIssues(FeedFilter filter) async {
    final Map<String, dynamic> queryParams = {};
    
    // The backend supports 'recent' and 'urgent' natively
    if (filter.sort == 'recent' || filter.sort == 'urgent') {
      queryParams['sort'] = filter.sort;
    } else {
      // 'closest' defaults to 'recent' from backend, then we sort client-side
      queryParams['sort'] = 'recent';
    }

    if (filter.kebele != 'All') {
      queryParams['kebele'] = filter.kebele;
    }

    if (filter.search.isNotEmpty) {
      queryParams['search'] = filter.search;
    }

    final resp = await ApiClient.instance.dio.get(
      '/api/issues',
      queryParameters: queryParams,
    );
    // Handle { data: [...] }, { issues: [...] }, direct arrays, etc.
    final raw = resp.data;
    final List data;
    if (raw is List) {
      data = raw;
    } else if (raw is Map) {
      data = raw['data'] ?? raw['issues'] ?? raw['results'] ?? [];
    } else {
      data = [];
    }
    
    List<Issue> issues = data
        .map((json) => Issue.fromJson(json as Map<String, dynamic>))
        .toList();

    // ── Geospatial Sorting ───────────────────────────────────────────────────
    if (filter.sort == 'closest') {
      try {
        // We use our existing LocationService to cleanly handle permissions.
        final locResult = await ref.read(locationServiceProvider).getCurrentLocation();
        
        // Sort issues by distance to user
        issues.sort((a, b) {
          // If a post lacks valid location data, move it to the end
          final aLat = a.latitude();
          final aLng = a.longitude();
          final bLat = b.latitude();
          final bLng = b.longitude();
          
          if (aLat == null || aLng == null) return 1;
          if (bLat == null || bLng == null) return -1;

          final distA = Geolocator.distanceBetween(locResult.latitude, locResult.longitude, aLat, aLng);
          final distB = Geolocator.distanceBetween(locResult.latitude, locResult.longitude, bLat, bLng);
          return distA.compareTo(distB);
        });
      } catch (_) {
        // If location is denied or fails, fallback to backend's default recent sorting
      }
    }

    return issues;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchIssues(arg));
  }

  Future<void> upvote(String issueId, String currentUserId) async {
    if (!state.hasValue) return;

    // Find the current state of the issue
    final currentIssue = state.value!.firstWhere(
      (i) => i.id == issueId,
      orElse: () => throw Exception('Issue not found'),
    );

    final alreadyVoted = currentIssue.voterIds.contains(currentUserId);

    // Optimistically update UI before backend responds
    state = AsyncData(state.value!.map((issue) {
      if (issue.id != issueId) return issue;
      final newVoterIds = alreadyVoted
          ? issue.voterIds.where((id) => id != currentUserId).toList()
          : [...issue.voterIds, currentUserId];
          
      return issue.copyWith(
        urgencyScore: alreadyVoted
            ? (issue.urgencyScore - 1).clamp(0, 999999)
            : issue.urgencyScore + 1,
        voterIds: newVoterIds,
      );
    }).toList());

    try {
      await ApiClient.instance.dio.post('/api/issues/$issueId/vote');
    } catch (_) {
      // Revert optimistic update on failure by refreshing from server
      refresh();
    }
  }
  Future<void> reportIssue(String issueId, String reason) async {
    try {
      await ApiClient.instance.dio.post(
        '/api/issues/$issueId/report',
        data: {'reason': reason},
      );
    } catch (e) {
      throw Exception('Failed to report issue: $e');
    }
  }
}

// ---------------------------------------------------------------------------
// Single Issue Comments Provider
// ---------------------------------------------------------------------------
final commentsProvider = AsyncNotifierProviderFamily<CommentsNotifier, List<Comment>, String>(
  () => CommentsNotifier(),
);

class CommentsNotifier extends FamilyAsyncNotifier<List<Comment>, String> {
  @override
  Future<List<Comment>> build(String issueId) async {
    // Avoid modifying SocketNotifier during build
    Future.microtask(() => ref.read(socketProvider.notifier).connect());

    ref.listen(socketProvider, (previous, socket) {
      if (socket == null) return;

      void handleNewComment(dynamic data) {
        if (!state.hasValue) return;
        final eventIssueId = data['issueId'] as String;
        if (eventIssueId != issueId) return;

        final newComment = Comment.fromJson(data['comment'] as Map<String, dynamic>);
        
        // Prevent duplicates
        if (!state.value!.any((c) => c.id == newComment.id)) {
           final newList = [...state.value!, newComment];
           newList.sort((a, b) {
             if (a.isAdmin && !b.isAdmin) return -1;
             if (!a.isAdmin && b.isAdmin) return 1;
             return a.createdAt.compareTo(b.createdAt);
           });
           state = AsyncData(newList);
        }
      }

      socket.on('new_comment', handleNewComment);

      ref.onDispose(() {
        socket.off('new_comment', handleNewComment);
      });
    }, fireImmediately: true);

    return _fetchComments(issueId);
  }

  Future<List<Comment>> _fetchComments(String issueId) async {
    final resp = await ApiClient.instance.dio.get('/api/issues/$issueId');
    // Backend may return the issue directly or in a 'data' wrapper
    final raw = resp.data;
    final issueData = raw is Map ? (raw['data'] ?? raw) : raw;
    if (issueData == null) return [];
    
    final commentsList = issueData is Map
        ? (issueData['comments'] ?? issueData['data']?['comments'] ?? [])
        : [];
        
    final parsedComments = (commentsList as List)
        .map((json) => Comment.fromJson(json as Map<String, dynamic>))
        .toList();
        
    // Sort comments so that admin comments appear first, then by chronological order
    parsedComments.sort((a, b) {
      if (a.isAdmin && !b.isAdmin) return -1;
      if (!a.isAdmin && b.isAdmin) return 1;
      return a.createdAt.compareTo(b.createdAt);
    });
    
    return parsedComments;
  }
}
