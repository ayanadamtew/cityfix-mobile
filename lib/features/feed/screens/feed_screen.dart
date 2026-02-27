import 'dart:async';
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
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider using our filter object
    final feedState = ref.watch(feedProvider(_currentFilter));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Icon(Icons.location_city, size: 24, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'CityFix',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Theme.of(context).colorScheme.primary,
              ),
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
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    _debounce = Timer(const Duration(milliseconds: 500), () {
                      setState(() {
                        _currentFilter = FeedFilter(
                          sort: _currentFilter.sort,
                          kebele: _currentFilter.kebele,
                          search: value,
                        );
                      });
                    });
                  },
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search categories, areas, or descriptions...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _currentFilter.search.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _currentFilter = FeedFilter(
                                  sort: _currentFilter.sort,
                                  kebele: _currentFilter.kebele,
                                  search: '',
                                );
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Filters Row (Sort Chips + Kebele Dropdown)
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildSortChip('closest', 'Near', Icons.my_location),
                            const SizedBox(width: 6),
                            _buildSortChip('recent', 'New', Icons.access_time),
                            const SizedBox(width: 6),
                            _buildSortChip('urgent', 'Urgent', Icons.local_fire_department),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Kebele Dropdown Compact
                    Expanded(
                      flex: 4,
                      child: Container(
                        height: 36, // Match standard chip height
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _currentFilter.kebele,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down, size: 20),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            items: ['All', ...AppConstants.jimmaKebeles]
                                .map((k) => DropdownMenuItem(
                                      value: k,
                                      child: Text(
                                        k == 'All' ? 'Everywhere' : k,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setState(() {
                                  _currentFilter = FeedFilter(
                                    sort: _currentFilter.sort,
                                    search: _currentFilter.search,
                                    kebele: v,
                                  );
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
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
          _currentFilter = FeedFilter(
            sort: sortValue,
            kebele: _currentFilter.kebele,
            search: _currentFilter.search,
          );
        });
      },
    );
  }
}
