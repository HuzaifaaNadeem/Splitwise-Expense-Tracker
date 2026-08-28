import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../expenses/presentation/screens/expense_settings_screen.dart';

enum _SettingsSection { general, appearance, budgeting, data, reports, about }

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({this.embedded = false, super.key});

  final bool embedded;

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  _SettingsSection _selectedSection = _SettingsSection.general;

  @override
  Widget build(BuildContext context) {
    final Widget content = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool wide = constraints.maxWidth >= 900;

        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                width: 250,
                child: _SettingsSidebar(
                  selectedSection: _selectedSection,
                  onSelected: _selectSection,
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(child: _buildSection()),
            ],
          );
        }

        return Column(
          children: <Widget>[
            _CompactSettingsNavigation(
              selectedSection: _selectedSection,
              onSelected: _selectSection,
            ),
            const Divider(height: 1),
            Expanded(child: _buildSection()),
          ],
        );
      },
    );

    if (widget.embedded) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: content,
    );
  }

  void _selectSection(_SettingsSection section) {
    setState(() {
      _selectedSection = section;
    });
  }

  Widget _buildSection() {
    return switch (_selectedSection) {
      _SettingsSection.general => const _GeneralSettings(),
      _SettingsSection.appearance => const _AppearanceSettings(),
      _SettingsSection.budgeting => _BudgetingSettings(
        onOpenBudgetManager: _openBudgetManager,
      ),
      _SettingsSection.data => const _DataSettings(),
      _SettingsSection.reports => const _ReportsSettings(),
      _SettingsSection.about => const _AboutSettings(),
    };
  }

  Future<void> _openBudgetManager() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return const ExpenseSettingsScreen();
        },
      ),
    );
  }
}

class _SettingsSidebar extends StatelessWidget {
  const _SettingsSidebar({
    required this.selectedSection,
    required this.onSelected,
  });

  final _SettingsSection selectedSection;
  final ValueChanged<_SettingsSection> onSelected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              child: Text(
                'Settings',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            _SettingsMenuItem(
              section: _SettingsSection.general,
              selectedSection: selectedSection,
              icon: Icons.tune_outlined,
              label: 'General',
              onSelected: onSelected,
            ),
            _SettingsMenuItem(
              section: _SettingsSection.appearance,
              selectedSection: selectedSection,
              icon: Icons.palette_outlined,
              label: 'Appearance',
              onSelected: onSelected,
            ),
            _SettingsMenuItem(
              section: _SettingsSection.budgeting,
              selectedSection: selectedSection,
              icon: Icons.account_balance_wallet_outlined,
              label: 'Budgets & categories',
              onSelected: onSelected,
            ),
            _SettingsMenuItem(
              section: _SettingsSection.data,
              selectedSection: selectedSection,
              icon: Icons.storage_outlined,
              label: 'Data & backup',
              onSelected: onSelected,
            ),
            _SettingsMenuItem(
              section: _SettingsSection.reports,
              selectedSection: selectedSection,
              icon: Icons.description_outlined,
              label: 'Export & reports',
              onSelected: onSelected,
            ),
            const Spacer(),
            const Divider(),
            const SizedBox(height: 8),
            _SettingsMenuItem(
              section: _SettingsSection.about,
              selectedSection: selectedSection,
              icon: Icons.info_outline,
              label: 'About',
              onSelected: onSelected,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsMenuItem extends StatelessWidget {
  const _SettingsMenuItem({
    required this.section,
    required this.selectedSection,
    required this.icon,
    required this.label,
    required this.onSelected,
  });

  final _SettingsSection section;
  final _SettingsSection selectedSection;
  final IconData icon;
  final String label;
  final ValueChanged<_SettingsSection> onSelected;

  @override
  Widget build(BuildContext context) {
    final bool selected = section == selectedSection;
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected
            ? colors.primary.withValues(alpha: 0.10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            onSelected(section);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: <Widget>[
                Icon(
                  icon,
                  size: 21,
                  color: selected ? colors.primary : colors.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
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

class _CompactSettingsNavigation extends StatelessWidget {
  const _CompactSettingsNavigation({
    required this.selectedSection,
    required this.onSelected,
  });

  final _SettingsSection selectedSection;
  final ValueChanged<_SettingsSection> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          _SectionChip(
            label: 'General',
            section: _SettingsSection.general,
            selectedSection: selectedSection,
            onSelected: onSelected,
          ),
          _SectionChip(
            label: 'Appearance',
            section: _SettingsSection.appearance,
            selectedSection: selectedSection,
            onSelected: onSelected,
          ),
          _SectionChip(
            label: 'Budgets',
            section: _SettingsSection.budgeting,
            selectedSection: selectedSection,
            onSelected: onSelected,
          ),
          _SectionChip(
            label: 'Data',
            section: _SettingsSection.data,
            selectedSection: selectedSection,
            onSelected: onSelected,
          ),
          _SectionChip(
            label: 'Reports',
            section: _SettingsSection.reports,
            selectedSection: selectedSection,
            onSelected: onSelected,
          ),
          _SectionChip(
            label: 'About',
            section: _SettingsSection.about,
            selectedSection: selectedSection,
            onSelected: onSelected,
          ),
        ],
      ),
    );
  }
}

class _SectionChip extends StatelessWidget {
  const _SectionChip({
    required this.label,
    required this.section,
    required this.selectedSection,
    required this.onSelected,
  });

  final String label;
  final _SettingsSection section;
  final _SettingsSection selectedSection;
  final ValueChanged<_SettingsSection> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selectedSection == section,
        onSelected: (bool selected) {
          if (selected) {
            onSelected(section);
          }
        },
      ),
    );
  }
}

class _GeneralSettings extends StatelessWidget {
  const _GeneralSettings();

  @override
  Widget build(BuildContext context) {
    return const _SettingsPage(
      title: 'General',
      description: 'Core application preferences and financial defaults.',
      children: <Widget>[
        _SettingsCard(
          icon: Icons.currency_exchange_outlined,
          title: 'Default currency',
          subtitle: 'Pakistani Rupee (PKR)',
          trailing: Text('PKR', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        SizedBox(height: 12),
        _SettingsCard(
          icon: Icons.calendar_today_outlined,
          title: 'Week starts on',
          subtitle: 'Weekly budget periods begin every Monday.',
          trailing: Text(
            'Monday',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        SizedBox(height: 12),
        _SettingsCard(
          icon: Icons.offline_bolt_outlined,
          title: 'Offline-first mode',
          subtitle:
              'Your core expense data remains available without an internet connection.',
          trailing: Icon(Icons.check_circle_outline),
        ),
      ],
    );
  }
}

class _AppearanceSettings extends ConsumerWidget {
  const _AppearanceSettings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode mode = ref.watch(themeControllerProvider);

    return _SettingsPage(
      title: 'Appearance',
      description: 'Choose how the application looks across your devices.',
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Theme',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Use your system preference or choose a fixed appearance.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                SegmentedButton<ThemeMode>(
                  segments: const <ButtonSegment<ThemeMode>>[
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.system,
                      icon: Icon(Icons.brightness_auto_outlined),
                      label: Text('System'),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode_outlined),
                      label: Text('Light'),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode_outlined),
                      label: Text('Dark'),
                    ),
                  ],
                  selected: <ThemeMode>{mode},
                  onSelectionChanged: (Set<ThemeMode> selection) {
                    final ThemeMode selected = selection.first;

                    final controller = ref.read(
                      themeControllerProvider.notifier,
                    );

                    switch (selected) {
                      case ThemeMode.system:
                        controller.useSystemTheme();
                      case ThemeMode.light:
                        controller.useLightTheme();
                      case ThemeMode.dark:
                        controller.useDarkTheme();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BudgetingSettings extends StatelessWidget {
  const _BudgetingSettings({required this.onOpenBudgetManager});

  final Future<void> Function() onOpenBudgetManager;

  @override
  Widget build(BuildContext context) {
    return _SettingsPage(
      title: 'Budgets & categories',
      description: 'Control spending limits and organise transactions.',
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Spending controls',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Configure weekly and monthly budgets, monitor remaining amounts, and manage expense categories.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () {
                    unawaited(onOpenBudgetManager());
                  },
                  icon: const Icon(Icons.tune_outlined),
                  label: const Text('Manage budgets & categories'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DataSettings extends StatelessWidget {
  const _DataSettings();

  @override
  Widget build(BuildContext context) {
    return _SettingsPage(
      title: 'Data & backup',
      description:
          'Understand where your information is stored and prepare for backup features.',
      children: <Widget>[
        const _SettingsCard(
          icon: Icons.storage_outlined,
          title: 'Local database',
          subtitle: 'Expense and group data is stored locally using Isar.',
          trailing: Icon(Icons.check_circle_outline),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Backup & restore',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Automatic backup and restore are not enabled in this build yet. They should be implemented before enterprise deployment.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    FilledButton.tonalIcon(
                      onPressed: null,
                      icon: const Icon(Icons.backup_outlined),
                      label: const Text('Create backup'),
                    ),
                    OutlinedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.restore_outlined),
                      label: const Text('Restore backup'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ReportsSettings extends StatelessWidget {
  const _ReportsSettings();

  @override
  Widget build(BuildContext context) {
    return _SettingsPage(
      title: 'Export & reports',
      description: 'Generate professional records from your financial data.',
      children: <Widget>[
        const _SettingsCard(
          icon: Icons.picture_as_pdf_outlined,
          title: 'Group PDF reports',
          subtitle:
              'PDF reports can be generated from individual group screens.',
          trailing: Icon(Icons.check_circle_outline),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Enterprise exports',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'CSV, Excel and organisation-level reports can be added in the enterprise edition.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AboutSettings extends StatelessWidget {
  const _AboutSettings();

  @override
  Widget build(BuildContext context) {
    return _SettingsPage(
      title: 'About',
      description: 'Application and product information.',
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: <Widget>[
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        AppConstants.appName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Version 1.0.0',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const _SettingsCard(
          icon: Icons.shield_outlined,
          title: 'Offline-first architecture',
          subtitle:
              'Designed around local persistence and private on-device financial data.',
          trailing: Icon(Icons.check_circle_outline),
        ),
      ],
    );
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage({
    required this.title,
    required this.description,
    required this.children,
  });

  final String title;
  final String description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(28),
      children: <Widget>[
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 28),
        ...children,
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle),
        ),
        trailing: trailing,
      ),
    );
  }
}
