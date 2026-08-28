# Splitwise Expense Tracker

A clean, offline-first expense management application built with Flutter and Dart.

It supports personal expense tracking, budgets, analytics, shared group expenses, balance calculation, settlement suggestions, PDF reports, and multiple default currencies. The project is built with a focus on maintainable architecture, local-first data storage, responsive UI, and automated testing.

---

## Features

### Personal Expenses
- Add, edit, and delete expenses
- Search and filter transactions
- Sort by date or amount
- Organize expenses by category
- Weekly and monthly budget tracking
- Budget progress and warning levels

### Analytics
- Weekly and monthly spending summaries
- Income vs expense comparison
- Category spending breakdown
- Monthly net position
- Currency-aware analytics

### Shared Expenses
- Create groups
- Add and remove members
- Add shared expenses
- Equal split calculation
- Net balance calculation
- Debt settlement suggestions
- Partial and full settlement payments
- Settlement history
- Archive and delete groups

### Reports
- Generate PDF reports for groups
- Export group members, expenses, balances, and settlement suggestions

### Settings
- Default currency selection
- Light, dark, and system theme
- Budget and category management
- Local data location
- Group report access

---

## Supported Currencies

The app currently supports the following default currencies:

- PKR
- USD
- GBP
- EUR
- AED
- SAR

Changing the default currency affects new records and filtered views.

Existing expenses, budgets, groups, and settlements keep their original stored currency values. The app does not perform live currency conversion.

---

## Tech Stack

- Flutter
- Dart
- Riverpod
- Isar Community
- Material 3
- fl_chart
- pdf
- printing
- flutter_test
- integration_test

---

## Architecture

The project follows Feature-First Clean Architecture.

```text
lib/
├── app/
├── core/
│   ├── constants/
│   ├── currency/
│   ├── db/
│   ├── errors/
│   ├── theme/
│   └── utils/
│
├── features/
│   ├── analytics/
│   ├── dashboard/
│   ├── expenses/
│   ├── group_splits/
│   ├── home/
│   └── settings/
│
└── main.dart

packages/
└── local_database/
```

This structure keeps presentation, business logic, and persistence responsibilities separated and easier to test and maintain.

---

## Money Handling

All monetary values are stored and calculated using integer minor units instead of floating-point values.

Example:

```text
PKR 3,000 paid by A
Split between A, B, and C
```

Balances:

```text
A  +PKR 2,000
B  -PKR 1,000
C  -PKR 1,000
```

Suggested settlements:

```text
B -> A  PKR 1,000
C -> A  PKR 1,000
```

This approach avoids common floating-point precision problems in financial calculations.


---

## Getting Started

### Prerequisites

Make sure Flutter is installed:

```bash
flutter doctor
```

### Clone the repository

```bash
git clone https://github.com/HuzaifaaNadeem/Splitwise-Expense-Tracker.git
cd Splitwise-Expense-Tracker
```

### Install dependencies

```bash
flutter pub get
```

---

## Code Generation

### Riverpod

Run from the project root:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Isar

Run inside the local database package:

```bash
cd packages/local_database
dart run build_runner build --delete-conflicting-outputs
cd ../..
```

---

## Run the App

### Windows

```bash
flutter run -d windows
```

### Android

```bash
flutter run
```

To view available devices:

```bash
flutter devices
```

---

## Testing

Run static analysis:

```bash
flutter analyze
```

Run unit, repository, and widget tests:

```bash
flutter test -j 1
```

Run the integration test:

```bash
flutter test integration_test/app_test.dart
```

The integration test covers the main shared-expense flow:

```text
Launch app
-> Open Groups
-> Create Group
-> Open Group Details
-> Add Shared Expense
-> Save
-> Verify Transaction
```

---

## Project Status

Version: **1.0.0**

Current status:

- Core functionality complete
- Unit tests passing
- Repository tests passing
- Widget tests passing
- Integration test passing
- Windows runtime verified

---

## Roadmap

Possible future improvements:

- Exact split UI
- Percentage split UI
- Weighted split UI
- Encrypted backup and restore
- CSV export
- Spreadsheet export
- Authentication
- Cloud sync
- Live FX conversion
- Multi-device sync
- Recurring expenses
- Notifications

---

## Professional Review Checklist

For a polished portfolio or recruiter review, make sure the repository includes:

- A clear README
- Clean project structure
- Screenshots
- Passing tests
- Meaningful Git commit history
- A release tag
- A license
- No secrets or local environment files
- A working release build
- Consistent formatting and linting

Before sharing the repository, run:

```bash
dart format lib test integration_test
flutter analyze
flutter test -j 1
flutter test integration_test/app_test.dart
```

---

## License

Choose and add a suitable license before public or commercial distribution.

Common open-source options include:

- MIT
- Apache 2.0
- GPLv3

For proprietary use, use an appropriate commercial license instead.

---

## Repository

https://github.com/HuzaifaaNadeem/Splitwise-Expense-Tracker
