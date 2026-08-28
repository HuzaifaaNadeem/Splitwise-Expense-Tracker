import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitwise_expense_tracker/app/app.dart';

void main() {
  testWidgets('application shell starts successfully', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: ExpenseTrackerApp()));

    await tester.pump();

    expect(find.text('Overview'), findsAtLeastNWidgets(1));

    expect(find.text('Expenses'), findsAtLeastNWidgets(1));

    expect(find.text('Groups'), findsAtLeastNWidgets(1));

    expect(find.text('Analytics'), findsAtLeastNWidgets(1));
  });
}
