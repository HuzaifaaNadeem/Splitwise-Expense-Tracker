import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../analytics/presentation/screens/analytics_screen.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../expenses/presentation/screens/expenses_screen.dart';
import '../../../group_splits/presentation/screens/groups_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../controllers/home_navigation_controller.dart';

class HomeShellScreen extends ConsumerStatefulWidget {
  const HomeShellScreen({super.key});

  @override
  ConsumerState<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends ConsumerState<HomeShellScreen> {
  bool _settingsSelected = false;

  static const List<String> _titles = <String>[
    'Overview',
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
  Widget build(BuildContext context) {
    final int selectedIndex = ref.watch(homeNavigationControllerProvider);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool desktop =
            constraints.maxWidth >= AppConstants.desktopBreakpoint;

        if (desktop) {
          return _DesktopShell(
            selectedIndex: selectedIndex,
            settingsSelected: _settingsSelected,
            title: _settingsSelected ? 'Settings' : _titles[selectedIndex],
            content: _settingsSelected
                ? const SettingsScreen(embedded: true)
                : _screens[selectedIndex],
            onDestinationSelected: _selectDestination,
            onSettingsSelected: _selectSettings,
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(_titles[selectedIndex]),
            actions: <Widget>[
              IconButton(
                tooltip: 'Settings',
                onPressed: () {
                  unawaited(
                    Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) {
                          return const SettingsScreen();
                        },
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.settings_outlined),
              ),
              const _ThemeToggleButton(),
              const SizedBox(width: 8),
            ],
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
                icon: Icon(Icons.space_dashboard_outlined),
                selectedIcon: Icon(Icons.space_dashboard),
                label: 'Overview',
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
                icon: Icon(Icons.analytics_outlined),
                selectedIcon: Icon(Icons.analytics),
                label: 'Analytics',
              ),
            ],
          ),
        );
      },
    );
  }

  void _selectDestination(int index) {
    setState(() {
      _settingsSelected = false;
    });

    ref
        .read(homeNavigationControllerProvider.notifier)
        .selectDestination(index);
  }

  void _selectSettings() {
    setState(() {
      _settingsSelected = true;
    });
  }
}

class _DesktopShell extends StatelessWidget {
  const _DesktopShell({
    required this.selectedIndex,
    required this.settingsSelected,
    required this.title,
    required this.content,
    required this.onDestinationSelected,
    required this.onSettingsSelected,
  });

  final int selectedIndex;
  final bool settingsSelected;
  final String title;
  final Widget content;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onSettingsSelected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Row(
        children: <Widget>[
          _DesktopSidebar(
            selectedIndex: selectedIndex,
            settingsSelected: settingsSelected,
            onDestinationSelected: onDestinationSelected,
            onSettingsSelected: onSettingsSelected,
          ),
          VerticalDivider(width: 1, color: colors.outlineVariant),
          Expanded(
            child: Column(
              children: <Widget>[
                Container(
                  height: 76,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const _ThemeToggleButton(),
                    ],
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

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({
    required this.selectedIndex,
    required this.settingsSelected,
    required this.onDestinationSelected,
    required this.onSettingsSelected,
  });

  final int selectedIndex;
  final bool settingsSelected;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onSettingsSelected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: 268,
      child: ColoredBox(
        color: colors.surface,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 28),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_outlined,
                          color: colors.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              AppConstants.appName,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Financial workspace',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: colors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _SidebarDestination(
                  selected: !settingsSelected && selectedIndex == 0,
                  icon: Icons.space_dashboard_outlined,
                  selectedIcon: Icons.space_dashboard,
                  label: 'Overview',
                  onTap: () {
                    onDestinationSelected(0);
                  },
                ),
                _SidebarDestination(
                  selected: !settingsSelected && selectedIndex == 1,
                  icon: Icons.receipt_long_outlined,
                  selectedIcon: Icons.receipt_long,
                  label: 'Expenses',
                  onTap: () {
                    onDestinationSelected(1);
                  },
                ),
                _SidebarDestination(
                  selected: !settingsSelected && selectedIndex == 2,
                  icon: Icons.groups_outlined,
                  selectedIcon: Icons.groups,
                  label: 'Groups',
                  onTap: () {
                    onDestinationSelected(2);
                  },
                ),
                _SidebarDestination(
                  selected: !settingsSelected && selectedIndex == 3,
                  icon: Icons.analytics_outlined,
                  selectedIcon: Icons.analytics,
                  label: 'Analytics',
                  onTap: () {
                    onDestinationSelected(3);
                  },
                ),
                const Spacer(),
                Divider(color: colors.outlineVariant),
                const SizedBox(height: 8),
                _SidebarDestination(
                  selected: settingsSelected,
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings,
                  label: 'Settings',
                  onTap: onSettingsSelected,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarDestination extends StatelessWidget {
  const _SidebarDestination({
    required this.selected,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Material(
        color: selected
            ? colors.primary.withValues(alpha: 0.10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: <Widget>[
                Icon(
                  selected ? selectedIcon : icon,
                  size: 22,
                  color: selected ? colors.primary : colors.onSurfaceVariant,
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? colors.primary : colors.onSurface,
                    ),
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
