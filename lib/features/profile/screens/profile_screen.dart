import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cityfix_mobile/l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/custom_toast.dart';

import '../../my_reports/providers/my_reports_provider.dart';
import '../providers/settings_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authProfileAsync = ref.watch(authNotifierProvider);
    final myReportsAsync = ref.watch(myReportsProvider);
    final l = AppLocalizations.of(context)!;

    return authProfileAsync.when(
      data: (profile) {
        if (profile == null) {
          return Scaffold(
            body: Center(child: Text(l.notLoggedIn)),
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

        final settings = ref.watch(settingsProvider);
        final isPushEnabled = settings['pushNotifications'] ?? true;

        // Language options: code -> display name
        const languageOptions = {
          'en': 'English',
          'am': 'አማርኛ',
          'om': 'Afaan Oromoo',
        };

        void showEditProfileModal() {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => _EditProfileModal(
              initialName: profile.name,
              ref: ref,
            ),
          );
        }

        final firebaseUser = FirebaseAuth.instance.currentUser;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              l.profile,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
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
                            (profile.name.isNotEmpty == true
                                    ? profile.name[0]
                                    : profile.email[0])
                                .toUpperCase(),
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        GestureDetector(
                          onTap: showEditProfileModal,
                          child: Container(
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile.name.isNotEmpty == true
                          ? profile.name
                          : 'CitizenUser',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.email,
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
                            (firebaseUser?.emailVerified ?? false) ? Icons.verified : Icons.warning_amber_rounded,
                            size: 16,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            (firebaseUser?.emailVerified ?? false) ? l.verifiedCitizen : l.unverified,
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
            l.yourImpact,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: l.totalReports,
                  value: myReportsAsync.isLoading ? '...' : totalReports.toString(),
                  icon: Icons.campaign_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: l.resolved,
                  value: myReportsAsync.isLoading ? '...' : resolvedReports.toString(),
                  icon: Icons.check_circle_rounded,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // 3. Settings & Preferences
          Text(
            l.settingsTitle,
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
                  title: l.pushNotifications,
                  trailing: Switch(
                    value: isPushEnabled,
                    onChanged: (val) {
                      ref.read(settingsProvider.notifier).togglePushNotifications(val);
                      ToastService.showInfo(context, val ? l.pushEnabled : l.pushDisabled);
                    },
                  ),
                ),
                Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
                _SettingsTile(
                  icon: Icons.dark_mode_rounded,
                  title: l.appTheme,
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: ref.watch(settingsProvider)['themeMode'],
                      icon: const Icon(Icons.arrow_drop_down_rounded),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                      items: [
                        DropdownMenuItem(value: 'system', child: Text(l.systemDefault)),
                        DropdownMenuItem(value: 'light', child: Text(l.lightMode)),
                        DropdownMenuItem(value: 'dark', child: Text(l.darkMode)),
                      ],
                      onChanged: (String? mode) {
                        if (mode != null) {
                          ref.read(settingsProvider.notifier).updateThemeMode(mode);
                        }
                      },
                    ),
                  ),
                ),
                Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
                // ── Language Selector ──
                _SettingsTile(
                  icon: Icons.translate_rounded,
                  title: l.language,
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: settings['locale'] as String? ?? 'en',
                      icon: const Icon(Icons.arrow_drop_down_rounded),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                      items: languageOptions.entries
                          .map((e) => DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value),
                              ))
                          .toList(),
                      onChanged: (String? code) {
                        if (code != null) {
                          ref.read(settingsProvider.notifier).updateLocale(code);
                        }
                      },
                    ),
                  ),
                ),
                Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
                _SettingsTile(
                  icon: Icons.privacy_tip_rounded,
                  title: l.privacyPolicy,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (context) => DraggableScrollableSheet(
                        initialChildSize: 0.6,
                        minChildSize: 0.4,
                        maxChildSize: 0.9,
                        expand: false,
                        builder: (_, controller) => _buildPolicySheet(context, controller, l),
                      ),
                    );
                  },
                ),
                Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
                _SettingsTile(
                  icon: Icons.help_outline_rounded,
                  title: l.helpSupport,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(l.helpSupport),
                        content: Text(l.helpContent),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(l.close),
                          ),
                        ],
                      ),
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
            label: Text(l.signOut),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(color: Theme.of(context).colorScheme.error.withOpacity(0.5)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  },
  loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
  error: (e, st) => Scaffold(body: Center(child: Text('Error: $e'))),
);
}

  Widget _buildPolicySheet(BuildContext context, ScrollController controller, AppLocalizations l) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyMedium?.copyWith(height: 1.5);
    final headerStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.primary,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l.privacyPolicy,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              controller: controller,
              physics: const BouncingScrollPhysics(),
              children: [
                Text(
                  l.privacyIntro,
                  style: textStyle,
                ),
                const SizedBox(height: 24),
                _buildPolicySection(l.privacyDataCollection, headerStyle, textStyle),
                const SizedBox(height: 20),
                _buildPolicySection(l.privacyDataSecurity, headerStyle, textStyle),
                const SizedBox(height: 20),
                _buildPolicySection(l.privacyNotifications, headerStyle, textStyle),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicySection(String text, TextStyle? headerStyle, TextStyle? bodyStyle) {
    final lines = text.split('\n');
    if (lines.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (lines[0].contains(RegExp(r'^\d\.'))) // Simple check for "1. ", "2. ", etc.
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(lines[0], style: headerStyle),
          ),
        Text(
          lines.length > 1 ? lines.sublist(1).join('\n').trim() : lines[0],
          style: bodyStyle,
        ),
      ],
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

class _EditProfileModal extends StatefulWidget {
  final String initialName;
  final WidgetRef ref;

  const _EditProfileModal({required this.initialName, required this.ref});

  @override
  State<_EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<_EditProfileModal> {
  late final TextEditingController _nameCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameCtrl.text.trim();
    final l = AppLocalizations.of(context)!;

    if (name.isEmpty) {
      ToastService.showError(context, l.enterName);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await widget.ref.read(authNotifierProvider.notifier).updateProfile(name);
      if (mounted) {
        Navigator.pop(context);
        ToastService.showSuccess(context, l.profileUpdated);
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError(context, l.failedGeneric(e.toString()));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.editProfile,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              labelText: l.fullName,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isLoading ? null : _handleSave,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(l.saveChanges),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
