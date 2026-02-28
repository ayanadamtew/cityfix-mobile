// lib/features/feed/screens/report_detail_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cityfix_mobile/l10n/app_localizations.dart';
import 'package:cityfix_mobile/shared/l10n_extensions.dart';
import '../providers/feed_provider.dart';
import '../../../core/api_client.dart';
import '../../../shared/issue_status_badge.dart';
import '../../../shared/custom_toast.dart';
import '../../../core/providers/connectivity_provider.dart';

class ReportDetailScreen extends ConsumerStatefulWidget {
  const ReportDetailScreen({super.key, required this.issueId});

  final String issueId;

  @override
  ConsumerState<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends ConsumerState<ReportDetailScreen> {
  final _commentCtrl = TextEditingController();
  bool _isPosting = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _postComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() => _isPosting = true);
    try {
      await ApiClient.instance.dio.post(
        '/api/issues/${widget.issueId}/comments',
        data: {'text': text},
      );
      _commentCtrl.clear();
      ref.invalidate(commentsProvider(widget.issueId));
      // Also invalidate feed provider to update comment count if needed
      // Though socket should handle it, invalidating ensures consistency
    } catch (e) {
      if (mounted) {
        ToastService.showError(context, 'Failed to post comment: $e');
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'water': return const Color(0xFF2196F3);
      case 'waste': return const Color(0xFF4CAF50);
      case 'road': return const Color(0xFFF57C00);
      case 'electricity': return const Color(0xFFFFC107);
      default: return const Color(0xFF9E9E9E);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'water': return Icons.water_drop_outlined;
      case 'waste': return Icons.delete_outline;
      case 'road': return Icons.add_road;
      case 'electricity': return Icons.bolt_outlined;
      default: return Icons.report_problem_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final isOffline = ref.watch(isOfflineProvider);
    final commentsAsync = ref.watch(commentsProvider(widget.issueId));

    // Listen for connectivity changes to show "Back Online" feedback
    ref.listen(isOfflineProvider, (previous, current) {
      if (previous == true && current == false) {
        ToastService.showSuccess(context, l.backOnline);
        ref.refresh(commentsProvider(widget.issueId).future);
        ref.refresh(feedProvider(const FeedFilter()).future);
      }
    });
    
    // We try to find the issue in the feed provider first
    final feedState = ref.watch(feedProvider(const FeedFilter()));
    final issue = feedState.when(
      data: (issues) => issues.where((i) => i.id == widget.issueId).firstOrNull,
      loading: () => null,
      error: (_, __) => null,
    );

    if (issue == null && !feedState.isLoading) {
       // If not in feed, we could fetch it individually, but for now we'll show a loader
       // or handle the case where it's truly not found if we had a dedicated single issue provider.
       return Scaffold(
         appBar: AppBar(title: Text(l.reportDetail)),
         body: const Center(child: CircularProgressIndicator()),
       );
    }

    if (issue == null) {
      return Scaffold(
         appBar: AppBar(title: Text(l.reportDetail)),
         body: const Center(child: CircularProgressIndicator()),
      );
    }

    final catColor = _getCategoryColor(issue.category);
    final catIcon = _getCategoryIcon(issue.category);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.refresh(commentsProvider(widget.issueId).future);
                // Also refresh the main feed to get updated issue status if it changed
                await ref.refresh(feedProvider(const FeedFilter()).future);
              },
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                // ── App Bar with Hero Image ─────────────────────────────
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  stretch: true,
                  backgroundColor: theme.colorScheme.surface,
                  leading: const BackButton(),
                  flexibleSpace: FlexibleSpaceBar(
                    stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (issue.photoUrl.isNotEmpty)
                          Hero(
                            tag: 'issue_image_${issue.id}',
                            child: CachedNetworkImage(
                              imageUrl: issue.photoUrl,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          Container(
                            color: catColor.withValues(alpha: 0.1),
                            child: Icon(catIcon, size: 80, color: catColor.withValues(alpha: 0.5)),
                          ),
                        // Gradient Overlay
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.4),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.6),
                                ],
                                stops: const [0, 0.4, 1],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Report Content ──────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status and Category
                        Row(
                          children: [
                            IssueStatusBadge(status: issue.status),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: catColor.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(catIcon, size: 16, color: catColor),
                                  const SizedBox(width: 6),
                                  Text(
                                    l.translateCategory(issue.category),
                                    style: TextStyle(
                                      color: catColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Title
                        Text(
                          issue.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Author and Date
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: theme.colorScheme.primaryContainer,
                              child: Text(
                                (issue.authorName?.isNotEmpty == true ? issue.authorName![0] : '?').toUpperCase(),
                                style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  issue.authorName ?? l.anonymousCitizen,
                                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  DateFormat('MMMM d, yyyy • h:mm a').format(issue.createdAt.toLocal()),
                                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Divider(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        // Description
                        Text(
                          l.description,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          issue.description,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Location Info (If available)
                        if (issue.rawLocation != null) ...[
                           Row(
                             children: [
                               Icon(Icons.location_on_outlined, color: theme.colorScheme.primary, size: 20),
                               const SizedBox(width: 8),
                               Text(
                                 l.reportLocation,
                                 style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                               ),
                             ],
                           ),
                           const SizedBox(height: 4),
                           Padding(
                             padding: const EdgeInsets.only(left: 28),
                             child: Text(
                               issue.rawLocation?['kebele'] ?? 'Jimma City',
                               style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                             ),
                           ),
                           const SizedBox(height: 24),
                        ],
                        
                        Divider(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        // Comments Header
                        Row(
                          children: [
                            const Icon(Icons.forum_outlined, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              l.communityDiscussion,
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            Text(
                              l.commentsCount(issue.commentCount),
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // ── Comments List ───────────────────────────────────────
                commentsAsync.when(
                  data: (comments) {
                    if (comments.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text(l.noCommentsYet),
                          ),
                        ),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final c = comments[index];
                          return _CommentTile(comment: c);
                        },
                        childCount: comments.length,
                      ),
                    );
                  },
                  loading: () => const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  error: (e, _) => SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(child: Text('Error loading comments: $e')),
                    ),
                  ),
                ),
                // Extra space at bottom for input field
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            ),
            ),
          ),

          // ── Comment Input Field ─────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentCtrl,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: l.commentHint,
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _isPosting
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : IconButton.filled(
                      onPressed: _postComment,
                      icon: const Icon(Icons.send_rounded),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: comment.isAdmin ? theme.colorScheme.primaryContainer : theme.colorScheme.secondaryContainer,
            child: Text(
              comment.authorName[0].toUpperCase(),
              style: TextStyle(
                color: comment.isAdmin ? theme.colorScheme.primary : theme.colorScheme.secondary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.authorName,
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (comment.isAdmin) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          comment.adminRoleLabel ?? 'Admin',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      DateFormat.yMMMd().format(comment.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: comment.isAdmin 
                        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3) 
                        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    border: comment.isAdmin 
                        ? Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1))
                        : null,
                  ),
                  child: Text(
                    comment.text,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
