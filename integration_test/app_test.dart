import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:splitwise_expense_tracker/main.dart' as app;

Future<void> waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 12),
  Duration step = const Duration(milliseconds: 100),
}) async {
  final DateTime deadline = DateTime.now().add(timeout);

  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(step);

    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }

  expect(finder, findsWidgets, reason: 'Expected widget did not appear.');
}

Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  await waitFor(tester, finder);

  await tester.ensureVisible(finder.first);
  await tester.pumpAndSettle();

  await tester.tap(finder.first);
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('create group and add shared expense', (
    WidgetTester tester,
  ) async {
    await app.main();
    await tester.pumpAndSettle();

    final String uniqueSuffix = DateTime.now().microsecondsSinceEpoch
        .toString();

    final String groupName = 'Integration Group $uniqueSuffix';
    final String expenseTitle = 'Integration Dinner $uniqueSuffix';

    // Open Groups from the main application navigation.
    final Finder groupsNavigation = find.text('Groups');

    await waitFor(tester, groupsNavigation);

    await tester.tap(groupsNavigation.first);

    await tester.pumpAndSettle();

    // Open the Create Group screen.
    final Finder createGroupButton = find.widgetWithText(
      FloatingActionButton,
      'Create group',
    );

    await tapAndSettle(tester, createGroupButton);

    await waitFor(tester, find.text('Group details'));

    // The first TextFormField on CreateGroupScreen is the group-name field.
    final Finder groupNameField = find.byType(TextFormField).first;

    await tester.enterText(groupNameField, groupName);

    await tester.pump();

    final Finder confirmCreateGroupButton = find.widgetWithText(
      FilledButton,
      'Create group',
    );

    await tapAndSettle(tester, confirmCreateGroupButton);

    // The screen returns to the groups workspace after creation.
    final Finder createdGroup = find.text(groupName);

    await waitFor(tester, createdGroup);

    await tester.ensureVisible(createdGroup.first);

    await tester.pumpAndSettle();

    await tester.tap(createdGroup.first);

    await tester.pumpAndSettle();

    await waitFor(tester, find.byKey(const Key('group_details_screen')));

    // Open Add Group Expense.
    final Finder addExpenseButton = find.byKey(
      const Key('add_group_expense_button'),
    );

    await tapAndSettle(tester, addExpenseButton);

    await waitFor(tester, find.byKey(const Key('add_group_expense_screen')));

    // Fill the shared-expense form.
    final Finder expenseTitleField = find.byKey(
      const Key('group_expense_title_field'),
    );

    final Finder expenseAmountField = find.byKey(
      const Key('group_expense_amount_field'),
    );

    await tester.enterText(expenseTitleField, expenseTitle);

    await tester.enterText(expenseAmountField, '3000.00');

    await tester.pump();

    // Save button is fixed in the bottom action area and remains hittable.
    final Finder saveExpenseButton = find.byKey(
      const Key('save_group_expense_button'),
    );

    await tapAndSettle(tester, saveExpenseButton);

    // Successful save returns to Group Details.
    await waitFor(tester, find.byKey(const Key('group_details_screen')));

    // Wait for the newly-created shared expense to be rendered.
    await waitFor(tester, find.text(expenseTitle));

    expect(find.text(expenseTitle), findsOneWidget);

    // Group Details uses production money formatting with thousands
    // separators, therefore 3000.00 is displayed as 3,000.00.
    expect(find.textContaining('3,000.00'), findsOneWidget);
  });
}
