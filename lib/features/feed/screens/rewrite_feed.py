import re
import sys

def modify_file(filepath):
    try:
        with open(filepath, 'r') as f:
            content = f.read()
    except FileNotFoundError:
        print(f"File not found: {filepath}")
        return

    # Replace Scaffold body from Column to CustomScrollView
    pattern_body = r"body: Column\(\s*children: \[\s*// ── Sticky Filter Bar ──────────────────────────────────────────────"
    replacement_body = """body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar ──────────────────────────────────────────────
          SliverAppBar(
            backgroundColor: Theme.of(context).colorScheme.surface.withAlpha(200),
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
            title: Row(
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
              _buildNotificationBell(context, ref, notifications),
              IconButton(
                icon: const Icon(Icons.person_outline_rounded),
                onPressed: () => context.go('/profile'),
              ),
              const SizedBox(width: 8),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(130),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant.withAlpha(76), # 0.3 * 255
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Search Bar"""
                    
    # Need to remove the old AppBar entirely since it's now a Sliver.
    pattern_appbar = r"appBar: AppBar\(.*?\),(\s+)body: Column\("
    
    # Just replace the whole widget build method
    
    with open(filepath, 'w') as f:
        f.write(content)
        
    print("Done")

if __name__ == '__main__':
    modify_file(sys.argv[1])
