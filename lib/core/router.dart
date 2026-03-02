// lib/core/router.dart
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';

import 'package:cityfix_mobile/l10n/app_localizations.dart';

import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/feed/screens/feed_screen.dart';
import '../features/feed/screens/report_detail_screen.dart';
import '../features/report_issue/screens/report_screen.dart';
import '../features/my_reports/screens/my_reports_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/auth/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Navigation shell for the bottom nav bar.
class _AppShell extends StatefulWidget {
  const _AppShell({required this.child, required this.state});

  final Widget child;
  final GoRouterState state;

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  bool _isBottomBarVisible = true;

  static const _tabs = [
    '/feed',
    '/search', // placeholder or integrated search
    '/my-reports',
    '/profile',
  ];

  int get _selectedIndex {
    final loc = widget.state.uri.toString();
    for (var i = 0; i < _tabs.length; i++) {
      if (loc.startsWith(_tabs[i])) return i;
    }
    return 0;
  }

  // Hide FAB on the report screen itself and on comment sub-screens
  bool get _showFab {
    final loc = widget.state.uri.toString();
    return !loc.startsWith('/report') && !loc.contains('/comments/');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          // If we scroll down, hide. If we scroll up, show.
          // Adjust distance/velocity thresholds if needed, but reverse means scrolling down.
          if (notification.direction == ScrollDirection.reverse && _isBottomBarVisible) {
            setState(() => _isBottomBarVisible = false);
          } else if (notification.direction == ScrollDirection.forward && !_isBottomBarVisible) {
            setState(() => _isBottomBarVisible = true);
          }
          return false;
        },
        child: widget.child,
      ),
      floatingActionButton: _showFab
          ? AnimatedSlide(
              duration: const Duration(milliseconds: 300),
              offset: _isBottomBarVisible ? Offset.zero : const Offset(0, 2),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _isBottomBarVisible ? 1.0 : 0.0,
                child: FloatingActionButton(
                  heroTag: 'report_fab',
                  onPressed: () => context.go('/report'),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 6,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.add_rounded, size: 28),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: ClipRect(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _isBottomBarVisible ? 90.0 : 0.0,
          child: _isBottomBarVisible 
            ? SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: BottomAppBar(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  shape: const CircularNotchedRectangle(),
                  notchMargin: 8,
                  color: theme.colorScheme.surface,
                  elevation: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                       _buildNavItem(0, Icons.home_outlined, Icons.home, AppLocalizations.of(context)!.navFeed, context),
                       _buildNavItem(1, Icons.search_outlined, Icons.search, AppLocalizations.of(context)!.navSearch, context),
                       const SizedBox(width: 48), // FAB Space
                       _buildNavItem(2, Icons.list_alt_outlined, Icons.list_alt, AppLocalizations.of(context)!.navMyReports, context),
                       _buildNavItem(3, Icons.person_outline, Icons.person, AppLocalizations.of(context)!.navProfile, context),
                    ],
                  ),
                ),
              )
            : const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData selectedIcon, String label, BuildContext context) {
    final isSelected = _selectedIndex == index;
    final theme = Theme.of(context);
    final color = isSelected 
        ? theme.colorScheme.primary 
        : theme.colorScheme.onSurfaceVariant;
    
    return Expanded(
      child: InkWell(
        onTap: () => context.go(_tabs[index]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: color,
              size: 26,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// App Router Provider
// -----------------------------------------------------------------------------
final routerProvider = Provider<GoRouter>((ref) {
  // Watch the auth state so the router rebuilds and re-evaluates redirects
  // whenever the user logs in or logs out.
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/feed',
    redirect: (context, state) {
      // Are we logged into Firebase?
      final isLoggedIn = authState.valueOrNull != null;
      
      final isAuthRoute = state.uri.toString().startsWith('/login') ||
          state.uri.toString().startsWith('/register');
          
      // If we're NOT logged in, and we are NOT on the login/register page yet, send us there.
      if (!isLoggedIn && !isAuthRoute) return '/login';
      
      // If we ARE logged in, and we are trying to view login/register page, send us to feed.
      if (isLoggedIn && isAuthRoute) return '/feed';
      
      // Otherwise, let them go where they wanted to go
      return null;
    },
    routes: [
      // ── Auth routes ─────────────────────────────────────────────────────────
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),

      // ── Shell routes (bottom nav) ────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) =>
            _AppShell(state: state, child: child),
        routes: [
          GoRoute(
            path: '/feed',
            builder: (_, __) => const FeedScreen(),
            routes: [
              GoRoute(
                path: 'comments/:issueId',
                builder: (_, state) =>
                    ReportDetailScreen(issueId: state.pathParameters['issueId']!),
              ),
            ],
          ),
          GoRoute(
            path: '/search',
            builder: (_, __) => const FeedScreen(isSearchFocused: true), // Example: reusing feed with focus
          ),
          GoRoute(
            path: '/report',
            builder: (_, __) => const ReportScreen(),
          ),
          GoRoute(
            path: '/my-reports',
            builder: (_, __) => const MyReportsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});
