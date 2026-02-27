import sys

def modify_file(filepath):
    try:
        with open(filepath, 'r') as f:
            content = f.read()
    except FileNotFoundError:
        print(f"File not found: {filepath}")
        return

    # Replace the AppShell stateless widget with a Stateful version
    old_shell = """class _AppShell extends StatelessWidget {
  const _AppShell({required this.child, required this.state});

  final Widget child;
  final GoRouterState state;

  static const _tabs = [
    '/feed',
    '/my-reports',
    '/profile',
  ];

  int get _selectedIndex {
    final loc = state.uri.toString();
    for (var i = 0; i < _tabs.length; i++) {
      if (loc.startsWith(_tabs[i])) return i;
    }
    return 0;
  }

  // Hide FAB on the report screen itself and on comment sub-screens
  bool get _showFab {
    final loc = state.uri.toString();
    return !loc.startsWith('/report') && !loc.contains('/comments/');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: child,
      floatingActionButton: _showFab
          ? FloatingActionButton(
              heroTag: 'report_fab',
              onPressed: () => context.go('/report'),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 6,
              child: const Icon(Icons.add_rounded, size: 28),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => context.go(_tabs[i]),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Feed',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'My Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}"""

    new_shell = """class _AppShell extends StatefulWidget {
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
                  child: const Icon(Icons.add_rounded, size: 28),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _isBottomBarVisible ? 80.0 : 0.0,
        child: Wrap(
          children: [
            NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (i) => context.go(_tabs[i]),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Feed',
                ),
                NavigationDestination(
                  icon: Icon(Icons.list_alt_outlined),
                  selectedIcon: Icon(Icons.list_alt),
                  label: 'My Reports',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}"""
    
    new_content = content.replace(old_shell, new_shell)
    new_content = new_content.replace(
        "import 'package:flutter/material.dart';", 
        "import 'package:flutter/material.dart';\nimport 'package:flutter/rendering.dart';"
    )
    
    with open(filepath, 'w') as f:
        f.write(new_content)
        
    print("Done")

if __name__ == '__main__':
    modify_file(sys.argv[1])
