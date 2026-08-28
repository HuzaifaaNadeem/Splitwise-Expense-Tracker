import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/currency/app_currency.dart';
import '../../../../core/currency/default_currency_controller.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../expenses/presentation/screens/expense_settings_screen.dart';
import '../../../group_splits/domain/entities/group.dart';
import '../../../group_splits/presentation/providers/group_providers.dart';
import '../../../group_splits/presentation/screens/group_details_screen.dart';
import '../../../group_splits/presentation/widgets/group_pdf_export_button.dart';
import '../../../reports/presentation/screens/financial_statement_screen.dart';

enum _SettingsSection { general, appearance, budgeting, data, reports, about }

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({this.embedded = false, super.key});

  final bool embedded;

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  _SettingsSection _selectedSection = _SettingsSection.general;

  late final Future<Directory> _dataDirectoryFuture;

  @override
  void initState() {
    super.initState();

    _dataDirectoryFuture = getApplicationSupportDirectory();
  }

  @override
  Widget build(BuildContext context) {
    final Widget content = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth >= 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                width: 260,
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
            _MobileSectionSelector(
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
      _SettingsSection.general => _GeneralSettings(
        onAppearance: () {
          _selectSection(_SettingsSection.appearance);
        },
        onBudgeting: () {
          unawaited(_openBudgetSettings());
        },
        onData: () {
          _selectSection(_SettingsSection.data);
        },
        onReports: () {
          _selectSection(_SettingsSection.reports);
        },
      ),
      _SettingsSection.appearance => const _AppearanceSettings(),
      _SettingsSection.budgeting => _BudgetSettings(
        onManage: () {
          unawaited(_openBudgetSettings());
        },
      ),
      _SettingsSection.data => _DataSettings(
        directoryFuture: _dataDirectoryFuture,
        onCopyPath: () {
          unawaited(_copyDataPath());
        },
        onOpenFolder: () {
          unawaited(_openDataFolder());
        },
      ),
      _SettingsSection.reports => const _ReportsSettings(),
      _SettingsSection.about => _AboutSettings(
        onCopyInfo: () {
          unawaited(_copyAppInfo());
        },
      ),
    };
  }

  Future<void> _openBudgetSettings() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return const ExpenseSettingsScreen();
        },
      ),
    );
  }

  Future<void> _copyDataPath() async {
    final Directory directory = await _dataDirectoryFuture;

    await Clipboard.setData(ClipboardData(text: directory.path));

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Application data path copied.')),
    );
  }

  Future<void> _openDataFolder() async {
    final Directory directory = await _dataDirectoryFuture;

    if (Platform.isWindows) {
      await Process.run('explorer.exe', <String>[directory.path]);
    } else if (Platform.isMacOS) {
      await Process.run('open', <String>[directory.path]);
    } else if (Platform.isLinux) {
      await Process.run('xdg-open', <String>[directory.path]);
    } else {
      await Clipboard.setData(ClipboardData(text: directory.path));

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The data path was copied. '
            'Opening the folder directly is available on desktop.',
          ),
        ),
      );

      return;
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Application data folder opened.')),
    );
  }

  Future<void> _copyAppInfo() async {
    const String version = '1.0.0';

    await Clipboard.setData(
      const ClipboardData(text: '${AppConstants.appName} - Version $version'),
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Application information copied.')),
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

    return Material(
      color: colors.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Configure your financial workspace.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 24),
            for (final _SettingsSection section in _SettingsSection.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: _SidebarItem(
                  section: section,
                  selected: section == selectedSection,
                  onTap: () {
                    onSelected(section);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.section,
    required this.selected,
    required this.onTap,
  });

  final _SettingsSection section;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Material(
      color: selected
          ? colors.primary.withValues(alpha: 0.09)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: <Widget>[
              Icon(
                _sectionIcon(section),
                size: 20,
                color: selected ? colors.primary : colors.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _sectionTitle(section),
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? colors.primary : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileSectionSelector extends StatelessWidget {
  const _MobileSectionSelector({
    required this.selectedSection,
    required this.onSelected,
  });

  final _SettingsSection selectedSection;
  final ValueChanged<_SettingsSection> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 66,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          for (final _SettingsSection section in _SettingsSection.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                selected: selectedSection == section,
                onSelected: (bool selected) {
                  if (selected) {
                    onSelected(section);
                  }
                },
                avatar: Icon(_sectionIcon(section), size: 18),
                label: Text(_sectionTitle(section)),
              ),
            ),
        ],
      ),
    );
  }
}

class _GeneralSettings extends ConsumerWidget {
  const _GeneralSettings({
    required this.onAppearance,
    required this.onBudgeting,
    required this.onData,
    required this.onReports,
  });

  final VoidCallback onAppearance;
  final VoidCallback onBudgeting;
  final VoidCallback onData;
  final VoidCallback onReports;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode themeMode = ref.watch(themeControllerProvider);

    final AppCurrency defaultCurrency = ref.watch(
      defaultCurrencyControllerProvider,
    );

    return _SettingsPage(
      title: 'General',
      subtitle: 'Frequently used workspace controls and shortcuts.',
      children: <Widget>[
        _InteractiveSettingCard(
          icon: Icons.palette_outlined,
          title: 'Appearance',
          description: 'Current theme: ${_themeName(themeMode)}',
          buttonLabel: 'Change appearance',
          onPressed: onAppearance,
        ),
        _CurrencySettingCard(
          currency: defaultCurrency,
          onChanged: (String code) {
            unawaited(_changeDefaultCurrency(context, ref, code));
          },
        ),
        _InteractiveSettingCard(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Budgets & categories',
          description:
              'Configure weekly and monthly budgets and manage expense categories.',
          buttonLabel: 'Manage budgets',
          onPressed: onBudgeting,
        ),
        _InteractiveSettingCard(
          icon: Icons.storage_outlined,
          title: 'Local data',
          description:
              'View the location where the offline application data is stored.',
          buttonLabel: 'Data & storage',
          onPressed: onData,
        ),
        _InteractiveSettingCard(
          icon: Icons.picture_as_pdf_outlined,
          title: 'Reports',
          description:
              'Generate personal monthly/yearly statements and group PDF reports.',
          buttonLabel: 'Open reports',
          onPressed: onReports,
        ),
      ],
    );
  }

  Future<void> _changeDefaultCurrency(
    BuildContext context,
    WidgetRef ref,
    String code,
  ) async {
    final bool persisted = await ref
        .read(defaultCurrencyControllerProvider.notifier)
        .setCurrency(code);

    if (!context.mounted) {
      return;
    }

    final AppCurrency currency = ref.read(defaultCurrencyControllerProvider);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            persisted
                ? 'Default currency changed to ${currency.code}.'
                : 'Default currency changed to ${currency.code} for this '
                      'session, but it could not be saved on this device.',
          ),
        ),
      );
  }
}

class _CurrencySettingCard extends StatelessWidget {
  const _CurrencySettingCard({required this.currency, required this.onChanged});

  final AppCurrency currency;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const _SettingIcon(icon: Icons.currency_exchange_outlined),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Default currency',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Used automatically for new personal expenses, new '
                    'budgets, and new groups. Existing records are not '
                    'converted or rewritten.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: DropdownButtonFormField<String>(
                      key: ValueKey<String>(
                        'default-currency-${currency.code}',
                      ),
                      initialValue: currency.code,
                      decoration: const InputDecoration(
                        labelText: 'Currency',
                        prefixIcon: Icon(Icons.payments_outlined),
                      ),
                      items: AppCurrency.supported
                          .map(
                            (AppCurrency option) => DropdownMenuItem<String>(
                              value: option.code,
                              child: Text(option.label),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (String? value) {
                        if (value != null && value != currency.code) {
                          onChanged(value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Dashboard and analytics show only records in the '
                    'selected default currency. No exchange-rate conversion '
                    'is performed.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppearanceSettings extends ConsumerWidget {
  const _AppearanceSettings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode themeMode = ref.watch(themeControllerProvider);

    final ThemeController controller = ref.read(
      themeControllerProvider.notifier,
    );

    final bool followsSystem = themeMode == ThemeMode.system;

    return _SettingsPage(
      title: 'Appearance',
      subtitle: 'Choose how the application looks on this device.',
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.brightness_auto_outlined),
                  title: const Text(
                    'Follow system appearance',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Automatically use the operating system light or dark mode.',
                  ),
                  value: followsSystem,
                  onChanged: (bool enabled) {
                    if (enabled) {
                      controller.useSystemTheme();
                      return;
                    }

                    final Brightness brightness =
                        MediaQuery.platformBrightnessOf(context);

                    if (brightness == Brightness.dark) {
                      controller.useDarkTheme();
                    } else {
                      controller.useLightTheme();
                    }
                  },
                ),
                const Divider(height: 30),
                Text(
                  'Theme mode',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Changes are applied immediately.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
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
                  selected: <ThemeMode>{themeMode},
                  onSelectionChanged: (Set<ThemeMode> selected) {
                    final ThemeMode mode = selected.first;

                    switch (mode) {
                      case ThemeMode.system:
                        controller.useSystemTheme();

                      case ThemeMode.light:
                        controller.useLightTheme();

                      case ThemeMode.dark:
                        controller.useDarkTheme();
                    }
                  },
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: controller.useSystemTheme,
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Reset to system'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BudgetSettings extends StatelessWidget {
  const _BudgetSettings({required this.onManage});

  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    return _SettingsPage(
      title: 'Budgets & categories',
      subtitle:
          'Configure real spending limits and the categories used by expenses.',
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _SettingIcon(icon: Icons.account_balance_wallet_outlined),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Budget manager',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Create or update weekly and monthly budgets, '
                        'review current spending progress, and manage '
                        'your expense categories.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: onManage,
                        icon: const Icon(Icons.tune),
                        label: const Text('Manage budgets & categories'),
                      ),
                    ],
                  ),
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
  const _DataSettings({
    required this.directoryFuture,
    required this.onCopyPath,
    required this.onOpenFolder,
  });

  final Future<Directory> directoryFuture;
  final VoidCallback onCopyPath;
  final VoidCallback onOpenFolder;

  @override
  Widget build(BuildContext context) {
    return _SettingsPage(
      title: 'Data & storage',
      subtitle:
          'Inspect the local storage used by this offline-first application.',
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const _SettingIcon(icon: Icons.folder_outlined),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Application data folder',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Your local Isar database and application '
                            'support data are stored on this device.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                FutureBuilder<Directory>(
                  future: directoryFuture,
                  builder:
                      (
                        BuildContext context,
                        AsyncSnapshot<Directory> snapshot,
                      ) {
                        final String value;

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          value = 'Loading data path...';
                        } else if (snapshot.hasError) {
                          value = 'Unable to resolve data path.';
                        } else {
                          value = snapshot.data?.path ?? 'Unavailable';
                        }

                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SelectableText(
                            value,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontFamily: 'monospace'),
                          ),
                        );
                      },
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    FilledButton.tonalIcon(
                      onPressed: onOpenFolder,
                      icon: const Icon(Icons.folder_open_outlined),
                      label: const Text('Open data folder'),
                    ),
                    OutlinedButton.icon(
                      onPressed: onCopyPath,
                      icon: const Icon(Icons.copy_outlined),
                      label: const Text('Copy path'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const _InformationCard(
          icon: Icons.security_outlined,
          title: 'Offline-first storage',
          message:
              'Expense and group data stays in the local application database. '
              'A safe database snapshot/restore workflow should be implemented '
              'before exposing one-click backup and restore.',
        ),
      ],
    );
  }
}

class _ReportsSettings extends ConsumerWidget {
  const _ReportsSettings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Group>> groupsAsync = ref.watch(groupsProvider);

    return _SettingsPage(
      title: 'Export & reports',
      subtitle:
          'Generate personal financial statements and reports from your saved data.',
      children: <Widget>[
        const _PersonalStatementCard(),
        _ReportSectionHeader(
          title: 'Group reports',
          description:
              'Open a shared-expense group or generate its PDF report.',
        ),
        groupsAsync.when(
          loading: () {
            return const Card(
              child: Padding(
                padding: EdgeInsets.all(36),
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          },
          error: (Object error, StackTrace stackTrace) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Icon(Icons.error_outline),
                    const SizedBox(height: 12),
                    const Text(
                      'Unable to load groups.',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () {
                        ref.invalidate(groupsProvider);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          },
          data: (List<Group> groups) {
            if (groups.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    children: <Widget>[
                      Icon(Icons.picture_as_pdf_outlined, size: 42),
                      SizedBox(height: 14),
                      Text(
                        'No groups available for reporting',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Create a shared expense group first.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: <Widget>[
                for (final Group group in groups)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _GroupReportCard(group: group),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _PersonalStatementCard extends StatelessWidget {
  const _PersonalStatementCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const _SettingIcon(icon: Icons.receipt_long_outlined),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Personal financial statement',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Generate a professional PDF e-statement for any completed '
                    'month or year, with income, expenses, net position, '
                    'category totals, and transaction history.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    key: const Key('open_financial_statement_button'),
                    onPressed: () {
                      unawaited(
                        Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) {
                              return const FinancialStatementScreen();
                            },
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: const Text('Generate statement'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportSectionHeader extends StatelessWidget {
  const _ReportSectionHeader({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 10, 2, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 3),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupReportCard extends StatelessWidget {
  const _GroupReportCard({required this.group});

  final Group group;

  @override
  Widget build(BuildContext context) {
    final int memberCount = group.activeMembers.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _SettingIcon(icon: Icons.groups_outlined),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    group.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$memberCount '
                    '${memberCount == 1 ? 'member' : 'members'} '
                    ' |  ${group.defaultCurrencyCode}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed: () {
                    unawaited(
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) {
                            return GroupDetailsScreen(groupId: group.id);
                          },
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open'),
                ),
                GroupPdfExportButton(group: group),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutSettings extends StatelessWidget {
  const _AboutSettings({required this.onCopyInfo});

  final VoidCallback onCopyInfo;

  @override
  Widget build(BuildContext context) {
    return _SettingsPage(
      title: 'About',
      subtitle: 'Application information and technology overview.',
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const _SettingIcon(
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            AppConstants.appName,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 3),
                          const Text('Version 1.0.0'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const Divider(),
                const SizedBox(height: 18),
                const _AboutRow(label: 'Platform', value: 'Flutter'),
                const SizedBox(height: 12),
                const _AboutRow(label: 'Storage', value: 'Isar Community'),
                const SizedBox(height: 12),
                const _AboutRow(label: 'State management', value: 'Riverpod'),
                const SizedBox(height: 12),
                const _AboutRow(label: 'Operation', value: 'Offline-first'),
                const SizedBox(height: 22),
                OutlinedButton.icon(
                  onPressed: onCopyInfo,
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('Copy app information'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 48),
      children: <Widget>[
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 26),
        ...children.expand((Widget child) {
          return <Widget>[child, const SizedBox(height: 14)];
        }),
      ],
    );
  }
}

class _InteractiveSettingCard extends StatelessWidget {
  const _InteractiveSettingCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _SettingIcon(icon: icon),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: onPressed,
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(buttonLabel),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingIcon extends StatelessWidget {
  const _SettingIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 22, color: colors.primary),
    );
  }
}

class _InformationCard extends StatelessWidget {
  const _InformationCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Card(
      color: colors.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, color: colors.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

IconData _sectionIcon(_SettingsSection section) {
  return switch (section) {
    _SettingsSection.general => Icons.settings_outlined,
    _SettingsSection.appearance => Icons.palette_outlined,
    _SettingsSection.budgeting => Icons.account_balance_wallet_outlined,
    _SettingsSection.data => Icons.storage_outlined,
    _SettingsSection.reports => Icons.picture_as_pdf_outlined,
    _SettingsSection.about => Icons.info_outline,
  };
}

String _sectionTitle(_SettingsSection section) {
  return switch (section) {
    _SettingsSection.general => 'General',
    _SettingsSection.appearance => 'Appearance',
    _SettingsSection.budgeting => 'Budgets & categories',
    _SettingsSection.data => 'Data & storage',
    _SettingsSection.reports => 'Export & reports',
    _SettingsSection.about => 'About',
  };
}

String _themeName(ThemeMode mode) {
  return switch (mode) {
    ThemeMode.system => 'System',
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
  };
}
