import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cityfix_mobile/l10n/app_localizations.dart';
import '../../../core/constants.dart';
import '../providers/feed_provider.dart';
import '../widgets/issue_card.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../../../core/providers/connectivity_provider.dart';
import '../../../shared/custom_toast.dart';
import '../../profile/providers/settings_provider.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key, this.isSearchFocused = false});

  final bool isSearchFocused;

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  FeedFilter _currentFilter = const FeedFilter();
  Timer? _debounce;
  late bool _isSearching;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isSearching = widget.isSearchFocused;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider(_currentFilter));
    final notifications = ref.watch(notificationsProvider);
    final isOffline = ref.watch(isOfflineProvider);
    final l = AppLocalizations.of(context)!;

    // Listen for connectivity changes to show "Back Online" feedback
    ref.listen(isOfflineProvider, (previous, current) {
      if (previous == true && current == false) {
        ToastService.showSuccess(context, l.backOnline);
        ref.refresh(feedProvider(_currentFilter).future);
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(feedProvider(_currentFilter).future),
        child: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          if (isOffline)
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: Theme.of(context).colorScheme.errorContainer,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_off_rounded,
                      size: 16,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l.offlineMode,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // ── App Bar ──────────────────────────────────────────────
          SliverAppBar(
            backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            elevation: 0,
            pinned: true,
            floating: true,
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(color: Colors.transparent),
              ),
            ),
            title: _isSearching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: l.feedSearchHint,
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) {
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(const Duration(milliseconds: 500), () {
                        setState(() {
                          _currentFilter = _currentFilter.copyWith(search: value);
                        });
                      });
                    },
                  )
                : Row(
                    children: [
                      Icon(Icons.location_city, size: 28, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'CityFix',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          fontSize: 24,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
            actions: [
              _buildLanguageToggle(context, ref),
              _buildNotificationBell(context, ref, notifications, l),
              const SizedBox(width: 8),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildSortChip('recent', l.feedNew, Icons.access_time),
                      const SizedBox(width: 6),
                      _buildSortChip('closest', l.feedNear, Icons.my_location),
                      const SizedBox(width: 6),
                      _buildSortChip('urgent', l.feedUrgent, Icons.local_fire_department),
                      const SizedBox(width: 12),
                      Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _currentFilter.kebele,
                            icon: const Icon(Icons.arrow_drop_down_rounded, size: 24),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            items: ['All', ...AppConstants.jimmaKebeles]
                                .map((k) => DropdownMenuItem(
                                      value: k,
                                      child: Text(
                                        k == 'All' ? l.feedEverywhere : k,
                                      ),
                                    ))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setState(() {
                                  _currentFilter = _currentFilter.copyWith(kebele: v);
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Feed List ──────────────────────────────────────────────
          feedState.when(
            data: (issues) {
              if (issues.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.forum_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l.feedNoIssues,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l.feedBeFirst,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: IssueCard(issue: issues[index]),
                      );
                    },
                    childCount: issues.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, st) => SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        l.feedLoadError,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(e.toString(), textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildSortChip(String value, String label, IconData icon) {
    final isSelected = _currentFilter.sort == value;
    final theme = Theme.of(context);
    
    return ChoiceChip(
      label: Text(label),
      avatar: isSelected ? null : Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
      selected: isSelected,
      showCheckmark: isSelected,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      labelStyle: TextStyle(
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? theme.colorScheme.onSecondaryContainer : theme.colorScheme.onSurfaceVariant,
      ),
      backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      selectedColor: theme.colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isSelected 
            ? BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.3), width: 1.5)
            : BorderSide.none,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _currentFilter = FeedFilter(
              sort: value,
              search: _currentFilter.search,
              kebele: _currentFilter.kebele,
            );
          });
        }
      },
    );
  }

  Widget _buildLanguageToggle(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final currentLocale = settings['locale'] ?? 'en';
    final theme = Theme.of(context);

    String label;
    String nextLocale;
    switch (currentLocale) {
      case 'en':
        label = 'En';
        nextLocale = 'am';
        break;
      case 'am':
        label = 'አማ';
        nextLocale = 'om';
        break;
      case 'om':
        label = 'Af';
        nextLocale = 'en';
        break;
      default:
        label = 'En';
        nextLocale = 'am';
    }

    return GestureDetector(
      onTap: () => ref.read(settingsProvider.notifier).updateLocale(nextLocale),
      child: Center(
        child: Container(
          width: 38,
          height: 38,
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13,
              color: theme.colorScheme.primary,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationBell(
      BuildContext context, WidgetRef ref, List<dynamic> notifications, AppLocalizations l) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded),
          onPressed: () => _showNotificationsSheet(context, ref, l),
        ),
        if (notifications.isNotEmpty)
          Positioned(
            right: 12,
            top: 12,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
            ),
          ),
      ],
    );
  }

  void _showNotificationsSheet(BuildContext context, WidgetRef ref, AppLocalizations l) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _NotificationsSheet(),
    );
  }
}

class _NotificationsSheet extends ConsumerWidget {
  const _NotificationsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l.notifications,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (notifications.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            ref.read(notificationsProvider.notifier).clearHistory();
                          },
                          child: Text(l.clearAll),
                        ),
                    ],
                  ),
                ),
                if (notifications.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 48,
                            color: theme.colorScheme.outlineVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l.noNotifications,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: notifications.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final n = notifications[index];
                        final timeString =
                            "${n.timestamp.hour}:${n.timestamp.minute.toString().padLeft(2, '0')}";
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: theme.colorScheme.primaryContainer,
                                child: Icon(Icons.info_outline_rounded,
                                    color: theme.colorScheme.primary),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      n.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      n.body,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(timeString, style: theme.textTheme.bodySmall),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
