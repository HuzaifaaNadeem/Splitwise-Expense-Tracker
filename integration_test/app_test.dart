import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:splitwise_expense_tracker/main.dart' as app;

Future<void> waitFor(
  WidgetTester tester,
  Finder finder, {
  int attempts = 40,
}) async {
  for (int index = 0; index < attempts; index++) {
    if (finder.evaluate().isNotEmpty) {
      return;
    }

    await tester.pump(const Duration(milliseconds: 250));
  }

  expect(finder, findsWidgets, reason: 'Expected widget did not appear.');
}

Future<void> waitForAny(
  WidgetTester tester,
  List<Finder> finders, {
  int attempts = 40,
}) async {
  for (int index = 0; index < attempts; index++) {
    final bool found = finders.any(
      (Finder finder) => finder.evaluate().isNotEmpty,
    );

    if (found) {
      return;
    }

    await tester.pump(const Duration(milliseconds: 250));
  }

  fail('None of the expected widgets appeared.');
}

Future<void> dragUntilFound(
  WidgetTester tester, {
  required Finder scrollable,
  required Finder target,
}) async {
  await waitFor(tester, scrollable);

  for (int index = 0; index < 15; index++) {
    if (target.evaluate().isNotEmpty) {
      await tester.ensureVisible(target.first);
      await tester.pumpAndSettle();
      return;
    }

    await tester.drag(scrollable, const Offset(0, -350));

    await tester.pumpAndSettle();
  }

  expect(
    target,
    findsWidgets,
    reason: 'Target widget was not found after scrolling.',
  );
}

Finder appBarTitle(String text) {
  return find.descendant(of: find.byType(AppBar), matching: find.text(text));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('create group and add shared expense', (
    WidgetTester tester,
  ) async {
    await app.main();
    await tester.pumpAndSettle();

    try {
      final String stamp = DateTime.now().millisecondsSinceEpoch.toString();

      final String groupName = 'Integration Group $stamp';

      final String expenseTitle = 'Dinner $stamp';

      // --------------------------------------------------
      // 1. Navigate to Groups tab
      // --------------------------------------------------

      final Finder groupsNavigation = find.text('Groups').last;

      expect(groupsNavigation, findsOneWidget);

      await tester.tap(groupsNavigation);
      await tester.pumpAndSettle();

      await waitForAny(tester, <Finder>[
        find.text('Create group'),
        find.byIcon(Icons.add),
      ]);

      // --------------------------------------------------
      // 2. Open Create Group
      // --------------------------------------------------

      final Finder createGroupText = find.text('Create group');

      if (createGroupText.evaluate().isNotEmpty) {
        final Finder createGroupButton = find.ancestor(
          of: createGroupText,
          matching: find.byWidgetPredicate(
            (Widget widget) => widget is ButtonStyleButton,
          ),
        );

        if (createGroupButton.evaluate().isNotEmpty) {
          await tester.tap(createGroupButton.first);
        } else {
          await tester.tap(createGroupText.last);
        }
      } else {
        final Finder addIcon = find.byIcon(Icons.add);

        expect(addIcon, findsAtLeastNWidgets(1));

        await tester.tap(addIcon.last);
      }

      await tester.pumpAndSettle();

      // --------------------------------------------------
      // 3. Verify Create Group screen
      // --------------------------------------------------

      await waitFor(tester, appBarTitle('Create group'));

      expect(appBarTitle('Create group'), findsOneWidget);

      // --------------------------------------------------
      // 4. Enter group name
      // --------------------------------------------------

      final Finder groupFields = find.byType(TextFormField);

      expect(groupFields, findsAtLeastNWidgets(1));

      await tester.enterText(groupFields.first, groupName);

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      // --------------------------------------------------
      // 5. Tap actual Create Group button
      // --------------------------------------------------

      final Finder createButton = find.ancestor(
        of: find.text('Create group'),
        matching: find.byWidgetPredicate(
          (Widget widget) => widget is ButtonStyleButton,
        ),
      );

      expect(createButton, findsOneWidget);

      await tester.ensureVisible(createButton);

      await tester.tap(createButton);

      await tester.pumpAndSettle();

      // --------------------------------------------------
      // 6. Confirm group was created
      // --------------------------------------------------

      final Finder groupText = find.text(groupName);

      await waitFor(tester, groupText);

      expect(groupText, findsOneWidget);

      // --------------------------------------------------
      // 7. Open newly-created group
      // --------------------------------------------------

      await tester.ensureVisible(groupText);

      final Finder groupListTile = find.ancestor(
        of: groupText,
        matching: find.byType(ListTile),
      );

      final Finder groupInkWell = find.ancestor(
        of: groupText,
        matching: find.byType(InkWell),
      );

      if (groupListTile.evaluate().isNotEmpty) {
        await tester.tap(groupListTile.first);
      } else if (groupInkWell.evaluate().isNotEmpty) {
        await tester.tap(groupInkWell.first);
      } else {
        await tester.tap(groupText);
      }

      await tester.pumpAndSettle();

      // --------------------------------------------------
      // 8. Verify real Group Details screen
      // --------------------------------------------------

      final Finder detailsScreen = find.byKey(
        const Key('group_details_screen'),
      );

      await waitFor(tester, detailsScreen);

      expect(detailsScreen, findsOneWidget);

      final Finder detailsList = find.byKey(const Key('group_details_list'));

      await waitFor(tester, detailsList);

      // --------------------------------------------------
      // 9. Find Add Expense button
      // --------------------------------------------------

      final Finder addExpenseButton = find.byKey(
        const Key('add_group_expense_button'),
      );

      await dragUntilFound(
        tester,
        scrollable: detailsList,
        target: addExpenseButton,
      );

      expect(addExpenseButton, findsOneWidget);

      await tester.tap(addExpenseButton);

      await tester.pumpAndSettle();

      // --------------------------------------------------
      // 10. Verify Add Group Expense screen
      // --------------------------------------------------

      final Finder addExpenseScreen = find.byKey(
        const Key('add_group_expense_screen'),
      );

      await waitFor(tester, addExpenseScreen);

      expect(addExpenseScreen, findsOneWidget);

      // --------------------------------------------------
      // 11. Enter expense title and amount
      // --------------------------------------------------

      final Finder titleField = find.byKey(
        const Key('group_expense_title_field'),
      );

      final Finder amountField = find.byKey(
        const Key('group_expense_amount_field'),
      );

      expect(titleField, findsOneWidget);

      expect(amountField, findsOneWidget);

      await tester.enterText(titleField, expenseTitle);

      await tester.enterText(amountField, '3000');

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      // --------------------------------------------------
      // 12. Find Save Expense button
      // --------------------------------------------------

      final Finder expenseList = find.byKey(
        const Key('add_group_expense_list'),
      );

      final Finder saveButton = find.byKey(
        const Key('save_group_expense_button'),
      );

      await dragUntilFound(tester, scrollable: expenseList, target: saveButton);

      expect(saveButton, findsOneWidget);

      // --------------------------------------------------
      // 13. Save expense
      // --------------------------------------------------

      await tester.tap(saveButton);

      await tester.pumpAndSettle();

      // --------------------------------------------------
      // 14. Confirm return to Group Details
      // --------------------------------------------------

      await waitFor(tester, find.byKey(const Key('group_details_screen')));

      final Finder returnedList = find.byKey(const Key('group_details_list'));

      await waitFor(tester, returnedList);

      // --------------------------------------------------
      // 15. Verify saved expense
      // --------------------------------------------------

      final Finder savedExpense = find.text(expenseTitle);

      await dragUntilFound(
        tester,
        scrollable: returnedList,
        target: savedExpense,
      );

      expect(savedExpense, findsOneWidget);

      expect(find.textContaining('3000.00'), findsOneWidget);
    } finally {
      FocusManager.instance.primaryFocus?.unfocus();

      await tester.pump();

      await tester.pumpWidget(const SizedBox.shrink());

      await tester.pump();
    }
  });
}
