import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitwise_expense_tracker/app/app.dart';

void main() {
  testWidgets('application shell starts successfully', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: ExpenseTrackerApp()));

    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Financial overview'), findsOneWidget);
    expect(find.text('PKR 0'), findsWidgets);
  });
}
