// lib/shared/issue_status_badge.dart
import 'package:flutter/material.dart';
import '../core/constants.dart';

class IssueStatusBadge extends StatelessWidget {
  const IssueStatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (status.toLowerCase()) {
      case AppConstants.statusPending:
        bg = Colors.red.shade100;
        fg = Colors.red.shade800;
        label = 'Pending';
        break;
      case AppConstants.statusInProgress:
        bg = Colors.orange.shade100;
        fg = Colors.orange.shade900;
        label = 'In Progress';
        break;
      case AppConstants.statusResolved:
        bg = Colors.green.shade100;
        fg = Colors.green.shade800;
        label = 'Resolved';
        break;
      default:
        bg = Colors.grey.shade100;
        fg = Colors.grey.shade700;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
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
