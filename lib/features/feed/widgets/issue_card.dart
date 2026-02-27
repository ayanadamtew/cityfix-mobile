// lib/features/feed/widgets/issue_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../providers/feed_provider.dart';
import '../../../shared/issue_status_badge.dart';
import '../../auth/providers/auth_provider.dart';

class IssueCard extends ConsumerWidget {
  const IssueCard({super.key, required this.issue});

  final Issue issue;

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'water': return const Color(0xFF2196F3);
      case 'waste': return const Color(0xFF4CAF50);
      case 'road': return const Color(0xFFF57C00);
      case 'electricity': return const Color(0xFFFFC107);
      default: return const Color(0xFF9E9E9E);
    }
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'water': return Icons.water_drop_outlined;
      case 'waste': return Icons.delete_outline;
      case 'road': return Icons.add_road;
      case 'electricity': return Icons.bolt_outlined;
      default: return Icons.report_problem_outlined;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final catColor = _categoryColor(issue.category);
    final catIcon = _categoryIcon(issue.category);

    // Firebase presence guards the tap; MongoDB _id is used to detect voted state.
    // authNotifierProvider starts null (build returns null) so we need Firebase
    // as a separate check to know if the user is logged in at all.
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final currentUser = ref.watch(authNotifierProvider).valueOrNull;
    final currentBackendId = currentUser?.id ?? '';
    // hasVoted: use backend ID when available (most accurate)
    final hasVoted = currentBackendId.isNotEmpty &&
        issue.voterIds.contains(currentBackendId);
    // The button is tappable whenever a Firebase session exists
    final isLoggedIn = firebaseUser != null;
    // Use backend ID for the vote call; fall back to Firebase UID if not yet synced
    final voteUserId = currentBackendId.isNotEmpty
        ? currentBackendId
        : (firebaseUser?.uid ?? '');

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.go('/feed/comments/${issue.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Photo ────────────────────────────────────────────────────
            if (issue.photoUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: CachedNetworkImage(
                  imageUrl: issue.photoUrl,
                  height: 180,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 180,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 120,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(Icons.image_not_supported_outlined,
                        color: theme.colorScheme.outline, size: 40),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Category pill + status ────────────────────────────
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(catIcon, size: 14, color: catColor),
                            const SizedBox(width: 4),
                            Text(
                              issue.category,
                              style: TextStyle(
                                color: catColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      IssueStatusBadge(status: issue.status),
                      if (isLoggedIn && (currentBackendId.isEmpty || currentBackendId != issue.authorId))
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, size: 20, color: theme.colorScheme.onSurfaceVariant),
                          padding: EdgeInsets.zero,
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'report',
                              child: Row(
                                children: [
                                  Icon(Icons.flag_outlined, size: 20, color: theme.colorScheme.error),
                                  const SizedBox(width: 8),
                                  Text('Report Issue', style: TextStyle(color: theme.colorScheme.error)),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) async {
                            if (value == 'report') {
                              String? currentReason;
                              final reason = await showDialog<String>(
                                context: context,
                                builder: (ctx) {
                                  return AlertDialog(
                                    title: const Text('Report Issue'),
                                    content: TextField(
                                      decoration: const InputDecoration(
                                        labelText: 'Reason',
                                        hintText: 'Why is this issue unnecessary or inappropriate?',
                                      ),
                                      maxLines: 3,
                                      onChanged: (val) => currentReason = val,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('Cancel'),
                                      ),
                                      FilledButton(
                                        onPressed: () => Navigator.pop(ctx, currentReason),
                                        child: const Text('Submit'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              
                              if (reason != null && reason.isNotEmpty) {
                                try {
                                  await ref.read(feedProvider(const FeedFilter()).notifier).reportIssue(issue.id, reason);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Issue reported for review successfully.')),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Failed to report issue.')),
                                    );
                                  }
                                }
                              }
                            }
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // ── Title ─────────────────────────────────────────────
                  Text(
                    issue.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // ── Description ───────────────────────────────────────
                  Text(
                    issue.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 8),

                  // ── Footer ────────────────────────────────────────────
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: catColor.withValues(alpha: 0.15),
                        child: Text(
                          (issue.authorName?.isNotEmpty == true
                                  ? issue.authorName![0]
                                  : '?')
                              .toUpperCase(),
                          style: TextStyle(
                            color: catColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              issue.authorName ?? 'Anonymous Citizen',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              DateFormat('MMM d, y').format(issue.createdAt.toLocal()),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Upvote toggle ────────────────────────────────
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: !isLoggedIn
                            ? null
                            : () {
                                ref
                                    .read(feedProvider(const FeedFilter()).notifier)
                                    .upvote(issue.id, voteUserId);
                              },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: hasVoted
                                ? theme.colorScheme.primary.withValues(alpha: 0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                hasVoted
                                    ? Icons.arrow_upward_rounded
                                    : Icons.arrow_upward_outlined,
                                size: 16,
                                color: hasVoted
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outline,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${issue.urgencyScore}',
                                style: TextStyle(
                                  color: hasVoted
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.outline,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // ── Comments ─────────────────────────────────────
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => context.go('/feed/comments/${issue.id}'),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          child: Row(
                            children: [
                              Icon(Icons.chat_bubble_outline_rounded,
                                  size: 16, color: theme.colorScheme.secondary),
                              const SizedBox(width: 4),
                              Text(
                                '${issue.commentCount}',
                                style: TextStyle(
                                  color: theme.colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
