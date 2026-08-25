import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitwise_expense_tracker/app/app.dart';

void main() {
  testWidgets('application shell starts successfully', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: ExpenseTrackerApp()));

    // Do not use pumpAndSettle here because the app contains
    // asynchronous providers / database streams that may remain active.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // This is a shell smoke test, so verify stable navigation UI
    // instead of asynchronous Dashboard database content.
    expect(find.text('Dashboard'), findsWidgets);

    expect(find.text('Expenses'), findsWidgets);

    expect(find.text('Groups'), findsWidgets);

    expect(find.text('Analytics'), findsWidgets);

    expect(tester.takeException(), isNull);
  });
}
