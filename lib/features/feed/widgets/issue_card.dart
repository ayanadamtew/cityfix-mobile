// lib/features/feed/widgets/issue_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:cityfix_mobile/l10n/app_localizations.dart';
import 'package:cityfix_mobile/shared/l10n_extensions.dart';
import '../providers/feed_provider.dart';
import '../../../shared/issue_status_badge.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/custom_toast.dart';
import '../../../core/providers/connectivity_provider.dart';

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
    final l = AppLocalizations.of(context)!;

    final firebaseUser = FirebaseAuth.instance.currentUser;
    final currentUser = ref.watch(authNotifierProvider).valueOrNull;
    final currentBackendId = currentUser?.id ?? '';
    final hasVoted = currentBackendId.isNotEmpty &&
        issue.voterIds.contains(currentBackendId);
    final isLoggedIn = firebaseUser != null;
    final voteUserId = currentBackendId.isNotEmpty
        ? currentBackendId
        : (firebaseUser?.uid ?? '');
    final isOffline = ref.watch(isOfflineProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Avatar Outside ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 12.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: catColor.withValues(alpha: 0.15),
              backgroundImage: issue.authorPhotoUrl != null ? CachedNetworkImageProvider(issue.authorPhotoUrl!) : null,
              child: issue.authorPhotoUrl == null ? Text(
                (issue.authorName?.isNotEmpty == true
                        ? issue.authorName![0]
                        : '?')
                    .toUpperCase(),
                style: TextStyle(
                  color: catColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ) : null,
            ),
          ),
          
          // ── Main Card ───────────────────────────────────────────────
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 8.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                        blurRadius: 16,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: isOffline 
                        ? () => ToastService.showInfo(context, l.youAreOffline)
                        : () => context.go('/feed/comments/${issue.id}'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Header (Author, Date, Category) ─────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Reporter Name & Time
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  issue.authorName ?? l.anonymousCitizen,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  DateFormat('MMM d, y • h:mm a').format(issue.createdAt.toLocal()),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.outline,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Category Pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: catColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(catIcon, size: 12, color: catColor),
                                const SizedBox(width: 4),
                                Text(
                                  l.translateCategory(issue.category),
                                  style: TextStyle(
                                    color: catColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Action Menu
                          if (isLoggedIn && (currentBackendId.isEmpty || currentBackendId != issue.authorId))
                            SizedBox(
                              width: 24,
                              child: PopupMenuButton<String>(
                                icon: Icon(Icons.more_horiz_rounded, size: 20, color: theme.colorScheme.onSurfaceVariant),
                                padding: EdgeInsets.zero,
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'report',
                                    enabled: !isOffline,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.flag_outlined, 
                                          size: 20, 
                                          color: isOffline ? theme.colorScheme.outline : theme.colorScheme.error
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          l.reportIssueMenu, 
                                          style: TextStyle(color: isOffline ? theme.colorScheme.outline : theme.colorScheme.error)
                                        ),
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
                                          title: Text(l.reportDialogTitle),
                                          content: TextField(
                                            decoration: InputDecoration(
                                              labelText: l.reportDialogReason,
                                              hintText: l.reportDialogHint,
                                            ),
                                            maxLines: 3,
                                            onChanged: (val) => currentReason = val,
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx),
                                              child: Text(l.cancel),
                                            ),
                                            FilledButton(
                                              onPressed: () => Navigator.pop(ctx, currentReason),
                                              child: Text(l.submit),
                                            ),
                                          ],
                                        );
                                      },
                                    );
        
                                    if (reason != null && reason.isNotEmpty) {
                                      try {
                                        await ref.read(feedProvider(const FeedFilter()).notifier).reportIssue(issue.id, reason);
                                        if (context.mounted) {
                                          if (context.mounted) {
                                            ToastService.showSuccess(context, l.reportedForReview);
                                          }
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          if (context.mounted) {
                                            ToastService.showError(context, l.failedToReport);
                                          }
                                        }
                                      }
                                    }
                                  }
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // ── Image (Clean Radius) ────────────────────────────────────
                    if (issue.photoUrl.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Hero(
                            tag: 'issue_image_${issue.id}',
                            child: CachedNetworkImage(
                              imageUrl: issue.photoUrl,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                height: 180,
                                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                height: 120,
                                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                child: Icon(Icons.image_not_supported_outlined,
                                    color: theme.colorScheme.outline, size: 40),
                              ),
                            ),
                          ),
                        ),
                      ),
        
                    // ── Title & Description ─────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  issue.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                    height: 1.2,
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 12),
                              IssueStatusBadge(status: issue.status),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            issue.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.4,
                              fontSize: 14,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
        
                    Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2)),
        
                    // ── Social Footer ───────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          // Upvote Button
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: !isLoggedIn
                                ? null
                                : () {
                                    if (isOffline) {
                                      ToastService.showInfo(context, l.youAreOffline);
                                      return;
                                    }
                                    ref
                                        .read(feedProvider(const FeedFilter()).notifier)
                                        .upvote(issue.id, voteUserId);
                                  },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    hasVoted
                                        ? Icons.keyboard_double_arrow_up_rounded
                                        : Icons.arrow_upward_rounded,
                                    size: 18,
                                    color: hasVoted
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.outline,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    hasVoted
                                        ? l.upvoted(issue.urgencyScore)
                                        : l.upvote(issue.urgencyScore),
                                    style: TextStyle(
                                      color: hasVoted
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.outline,
                                      fontWeight: hasVoted ? FontWeight.bold : FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
        
                          // Comments Button
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: isOffline 
                                ? () => ToastService.showInfo(context, l.youAreOffline)
                                : () => context.go('/feed/comments/${issue.id}'),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Row(
                                children: [
                                  Icon(Icons.chat_bubble_outline_rounded,
                                      size: 16, color: theme.colorScheme.outline),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${issue.commentCount}',
                                    style: TextStyle(
                                      color: theme.colorScheme.outline,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
                // ── Bubble Tail ──
                Positioned(
                  left: -11,
                  top: 24,
                  child: CustomPaint(
                    size: const Size(12, 16),
                    painter: _BubbleTailPainter(
                      color: theme.colorScheme.surface,
                      borderColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      )
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  _BubbleTailPainter({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paintFill = Paint()..color = color..style = PaintingStyle.fill;
    final paintStroke = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path()
      ..moveTo(size.width, 0)
      ..quadraticBezierTo(size.width * 0.3, 0, 0, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.3, size.height, size.width, size.height)
      ..close();

    canvas.drawPath(path, paintFill);

    final strokePath = Path()
      ..moveTo(size.width, 0)
      ..quadraticBezierTo(size.width * 0.3, 0, 0, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.3, size.height, size.width, size.height);

    canvas.drawPath(strokePath, paintStroke);
  }

  @override
  bool shouldRepaint(covariant _BubbleTailPainter oldDelegate) => 
      color != oldDelegate.color || borderColor != oldDelegate.borderColor;
}
