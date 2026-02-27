// lib/features/feed/screens/feed_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';
import '../providers/feed_provider.dart';
import '../widgets/issue_card.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  // Initialize with our default 'Closest' sorting and 'All' kebeles
  FeedFilter _currentFilter = const FeedFilter();

  @override
  Widget build(BuildContext context) {
    // Watch the provider using our filter object
    final feedState = ref.watch(feedProvider(_currentFilter));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.location_city, size: 22),
            const SizedBox(width: 8),
            const Text(
              'CityFix',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Sticky Filter Bar ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Sort Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildSortChip('closest', 'Closest (GPS)', Icons.my_location),
                      const SizedBox(width: 8),
                      _buildSortChip('recent', 'Newest', Icons.access_time),
                      const SizedBox(width: 8),
                      _buildSortChip('urgent', 'Most Urgent', Icons.local_fire_department),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Kebele Dropdown
                SizedBox(
                  height: 48,
                  child: DropdownButtonFormField<String>(
                    initialValue: _currentFilter.kebele,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      filled: true,
                    ),
                    items: ['All', ...AppConstants.jimmaKebeles]
                        .map((k) => DropdownMenuItem(value: k, child: Text(k == 'All' ? 'All Kebeles' : k)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          _currentFilter = FeedFilter(sort: _currentFilter.sort, kebele: v);
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // ── Feed List ──────────────────────────────────────────────────────
          Expanded(
            child: feedState.when(
        data: (issues) {
          if (issues.isEmpty) {
            return Center(
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
                    'No issues reported yet.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Be the first to report a problem!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(feedProvider(_currentFilter).notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
              itemCount: issues.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) => IssueCard(issue: issues[index]),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wifi_off_rounded,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Could not load reports',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => ref.read(feedProvider(_currentFilter).notifier).refresh(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
            ),
          ),
        ),
      ),
      ],
    ),
    );
  }

  // Helper to build nice selection chips based on active sort
  Widget _buildSortChip(String sortValue, String label, IconData icon) {
    final isActive = _currentFilter.sort == sortValue;
    return FilterChip(
      selected: isActive,
      label: Text(label),
      avatar: Icon(icon, size: 18, color: isActive ? Theme.of(context).colorScheme.onPrimary : null),
      selectedColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isActive ? Theme.of(context).colorScheme.onPrimary : null,
        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) {
        setState(() {
          _currentFilter = FeedFilter(sort: sortValue, kebele: _currentFilter.kebele);
        });
      },
    );
  }
}
