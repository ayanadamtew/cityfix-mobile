// lib/features/my_reports/widgets/my_report_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:cityfix_mobile/l10n/app_localizations.dart';
import 'package:cityfix_mobile/shared/l10n_extensions.dart';
import '../../../core/constants.dart';
import '../../feed/providers/feed_provider.dart';
import '../../../shared/issue_status_badge.dart';

class MyReportCard extends ConsumerWidget {
  const MyReportCard({
    super.key,
    required this.issue,
    required this.onEdit,
    required this.onFeedback,
  });

  final Issue issue;
  final VoidCallback onEdit;
  final VoidCallback onFeedback;

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'water':
        return const Color(0xFF2196F3);
      case 'waste':
        return const Color(0xFF4CAF50);
      case 'road':
        return const Color(0xFFF57C00);
      case 'electricity':
        return const Color(0xFFFFC107);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'water':
        return Icons.water_drop_outlined;
      case 'waste':
        return Icons.delete_outline;
      case 'road':
        return Icons.add_road;
      case 'electricity':
        return Icons.bolt_outlined;
      default:
        return Icons.report_problem_outlined;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final catColor = _categoryColor(issue.category);
    final catIcon = _categoryIcon(issue.category);

    final isResolved = issue.status.toLowerCase() == AppConstants.statusResolved.toLowerCase();
    final isPending = issue.status.toLowerCase() == AppConstants.statusPending.toLowerCase();

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Left: Thumbnail ─────────────────────────────────────────
            if (issue.photoUrl.isNotEmpty) // Use a sized box even if empty for alignment
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: issue.photoUrl.startsWith('http')
                      ? issue.photoUrl
                      : '${AppConstants.baseUrl}${issue.photoUrl}',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    width: 80,
                    height: 80,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Center(
                      child: SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(Icons.image_not_supported_outlined,
                        color: theme.colorScheme.outline, size: 24),
                  ),
                ),
              )
            else
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.image_not_supported_outlined, color: theme.colorScheme.outline),
              ),
            
            const SizedBox(width: 16),
            
            // ── Right: Details Stack ────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    issue.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  
                  // Category & Status Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
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
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IssueStatusBadge(status: issue.status),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Description Snippet
                  Text(
                    issue.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Footer: Date & Actions
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 12,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM d, y').format(issue.createdAt.toLocal()),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const Spacer(),
                      if (isPending)
                        SizedBox(
                          height: 32,
                          child: ElevatedButton.icon(
                            onPressed: onEdit,
                            icon: const Icon(Icons.edit, size: 14),
                            label: Text(l.editReport),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      if (isResolved)
                        SizedBox(
                          height: 32,
                          child: ElevatedButton.icon(
                            onPressed: onFeedback,
                            icon: const Icon(Icons.star_rate_rounded, size: 14),
                            label: Text(l.submitFeedback), // Changed to submitFeedback as "Feedback" was not explicitly in ARB besides button text intent
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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
