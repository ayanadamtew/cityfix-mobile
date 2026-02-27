import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../auth/providers/auth_provider.dart';

import '../../my_reports/providers/my_reports_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final myReportsAsync = ref.watch(myReportsProvider);

    if (firebaseUser == null) {
      return const Scaffold(
        body: Center(child: Text('Not logged in.')),
      );
    }

    // Safely extract stats
    int totalReports = 0;
    int resolvedReports = 0;
    
    if (myReportsAsync is AsyncData) {
      final reports = myReportsAsync.value ?? [];
      totalReports = reports.length;
      resolvedReports = reports.where((r) => r.status == 'Resolved').length;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        children: [
          // 1. Hero Header Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  Theme.of(context).colorScheme.primary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: Theme.of(context).colorScheme.onPrimary,
                      child: Text(
                        (firebaseUser.displayName?.isNotEmpty == true
                                ? firebaseUser.displayName![0]
                                : firebaseUser.email?[0] ?? '?')
                            .toUpperCase(),
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  firebaseUser.displayName?.isNotEmpty == true
                      ? firebaseUser.displayName!
                      : 'CitizenUser',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  firebaseUser.email ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                      ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        firebaseUser.emailVerified ? Icons.verified : Icons.warning_amber_rounded,
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        firebaseUser.emailVerified ? 'Verified Citizen' : 'Unverified',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // 2. User Statistics Row
          Text(
            'Your Impact',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Total Reports',
                  value: myReportsAsync.isLoading ? '...' : totalReports.toString(),
                  icon: Icons.campaign_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Resolved',
                  value: myReportsAsync.isLoading ? '...' : resolvedReports.toString(),
                  icon: Icons.check_circle_rounded,
                  color: Colors.green, // Fixed success color logic for specific stat
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // 3. Settings & Preferences
          Text(
            'Settings & Preferences',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
              ),
            ),
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.notifications_active_rounded,
                  title: 'Push Notifications',
                  trailing: Switch(
                    value: true,
                    onChanged: (val) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notification settings coming soon!')),
                      );
                    },
                  ),
                ),
                Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
                _SettingsTile(
                  icon: Icons.privacy_tip_rounded,
                  title: 'Privacy Policy',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Privacy Policy coming soon!')),
                    );
                  },
                ),
                Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
                _SettingsTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Support',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Support Center coming soon!')),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 48),

          // 4. Polished Logout Button
          OutlinedButton.icon(
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sign Out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(color: Theme.of(context).colorScheme.error.withOpacity(0.5)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// Internal Helper Widgets for cleaner code

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: trailing ??
          Icon(
            Icons.chevron_right_rounded,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
