# Personal Financial Statement Feature

This pass adds a monthly/yearly personal e-statement PDF feature to the existing
Splitwise Expense Tracker without changing the Isar schema.

## What is added

- Settings -> Export & reports -> Personal financial statement
- Monthly statements for completed months
- Yearly statements for completed years
- Currency selection: PKR, USD, GBP, EUR, AED, SAR
- Statement preview before PDF generation
- Total income
- Total expenses
- Net position
- Transaction count
- Expense breakdown by category
- Month-by-month summary for yearly statements
- Full transaction statement
- Professional PDF header/footer and disclaimer
- Unit tests for statement filtering and totals

## Important behavior

The statement never mixes currencies and never performs FX conversion.

Existing records are not modified.

The feature reads the existing Expense records only, so there is no new Isar
model and no database migration/code generation is required.

## Copy these files into the project

The ZIP preserves the correct project paths. Copy its `lib` and `test` folders
over the project root.

New files:

- lib/features/reports/domain/entities/financial_statement.dart
- lib/features/reports/domain/services/financial_statement_builder.dart
- lib/features/reports/presentation/services/financial_statement_pdf_service.dart
- lib/features/reports/presentation/screens/financial_statement_screen.dart
- test/features/reports/domain/services/financial_statement_builder_test.dart

Replacement file:

- lib/features/settings/presentation/screens/settings_screen.dart

The Settings replacement is based on the latest Default Currency pass and keeps
the persistent default-currency functionality.

## Verify

Run from the project root:

```powershell
dart format lib test
flutter analyze
flutter test -j 1
flutter run -d windows
```

Manual verification:

1. Open Settings.
2. Open Export & reports.
3. Click Generate statement.
4. Select Monthly.
5. Select a completed month/year.
6. Select PKR (or another currency with saved records).
7. Confirm the preview totals.
8. Click Generate PDF Statement.
9. Save/print the PDF from the platform PDF dialog.
10. Repeat with Yearly and verify the month-by-month summary.

## Suggested commit

```powershell
git add .
git commit -m "feat: add monthly and yearly financial statement PDF"
git push origin main
```
