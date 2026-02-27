// lib/shared/issue_status_badge.dart
import 'package:flutter/material.dart';
import 'package:cityfix_mobile/l10n/app_localizations.dart';
import 'package:cityfix_mobile/shared/l10n_extensions.dart';
import '../core/constants.dart';

class IssueStatusBadge extends StatelessWidget {
  const IssueStatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    final l = AppLocalizations.of(context)!;

    switch (status.toLowerCase()) {
      case AppConstants.statusPending:
        bg = Colors.red.shade100;
        fg = Colors.red.shade800;
        break;
      case AppConstants.statusInProgress:
      case 'in progress':
        bg = Colors.orange.shade100;
        fg = Colors.orange.shade900;
        break;
      case AppConstants.statusResolved:
        bg = Colors.green.shade100;
        fg = Colors.green.shade800;
        break;
      default:
        bg = Colors.grey.shade100;
        fg = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        l.translateStatus(status),
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
