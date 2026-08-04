import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../analytics/presentation/screens/analytics_screen.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../expenses/presentation/screens/expenses_screen.dart';
import '../../../group_splits/presentation/screens/groups_screen.dart';
import '../controllers/home_navigation_controller.dart';

class HomeShellScreen extends ConsumerWidget {
  const HomeShellScreen({super.key});

  static const List<String> _titles = <String>[
    'Dashboard',
    'Expenses',
    'Groups',
    'Analytics',
  ];

  static const List<Widget> _screens = <Widget>[
    DashboardScreen(),
    ExpensesScreen(),
    GroupsScreen(),
    AnalyticsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int selectedIndex = ref.watch(homeNavigationControllerProvider);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool useNavigationRail =
            constraints.maxWidth >= AppConstants.desktopBreakpoint;

        if (useNavigationRail) {
          return _DesktopShell(
            selectedIndex: selectedIndex,
            title: _titles[selectedIndex],
            content: _screens[selectedIndex],
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(_titles[selectedIndex]),
            actions: const <Widget>[_ThemeToggleButton(), SizedBox(width: 8)],
          ),
          body: IndexedStack(index: selectedIndex, children: _screens),
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: (int index) {
              ref
                  .read(homeNavigationControllerProvider.notifier)
                  .selectDestination(index);
            },
            destinations: const <NavigationDestination>[
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long),
                label: 'Expenses',
              ),
              NavigationDestination(
                icon: Icon(Icons.groups_outlined),
                selectedIcon: Icon(Icons.groups),
                label: 'Groups',
              ),
              NavigationDestination(
                icon: Icon(Icons.donut_large_outlined),
                selectedIcon: Icon(Icons.donut_large),
                label: 'Analytics',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DesktopShell extends ConsumerWidget {
  const _DesktopShell({
    required this.selectedIndex,
    required this.title,
    required this.content,
  });

  final int selectedIndex;
  final String title;
  final Widget content;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          NavigationRail(
            extended: true,
            selectedIndex: selectedIndex,
            onDestinationSelected: (int index) {
              ref
                  .read(homeNavigationControllerProvider.notifier)
                  .selectDestination(index);
            },
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Expense Tracker',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long),
                label: Text('Expenses'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.groups_outlined),
                selectedIcon: Icon(Icons.groups),
                label: Text('Groups'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.donut_large_outlined),
                selectedIcon: Icon(Icons.donut_large),
                label: Text('Analytics'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 72,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const _ThemeToggleButton(),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(child: content),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeToggleButton extends ConsumerWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode themeMode = ref.watch(themeControllerProvider);

    final IconData icon = switch (themeMode) {
      ThemeMode.system => Icons.brightness_auto_outlined,
      ThemeMode.light => Icons.light_mode_outlined,
      ThemeMode.dark => Icons.dark_mode_outlined,
    };

    return IconButton(
      tooltip: 'Change theme',
      icon: Icon(icon),
      onPressed: () {
        ref
            .read(themeControllerProvider.notifier)
            .toggle(MediaQuery.platformBrightnessOf(context));
      },
    );
  }
}
