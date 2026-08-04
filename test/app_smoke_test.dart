import 'package:flutter_test/flutter_test.dart';
import 'package:splitwise_expense_tracker/main.dart';

void main() {
  testWidgets('application starts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpenseTrackerApp());
    await tester.pumpAndSettle();

    expect(find.text('Project foundation is ready'), findsOneWidget);

    expect(find.text('Split Expense Tracker'), findsOneWidget);
  });
}
