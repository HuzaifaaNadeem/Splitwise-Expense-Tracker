# Splitwise Expense Tracker

A clean, offline-first expense management app built with Flutter. It supports personal expense tracking, budgets, analytics, shared group expenses, balance calculation, settlement suggestions, and PDF reports.

## Features

- Personal expense CRUD
- Category management
- Weekly and monthly budgets
- Expense analytics and charts
- Group creation and member management
- Shared group expenses
- Equal split with precise minor-unit rounding
- Net balance calculation
- Debt settlement suggestions
- PDF group reports
- Offline persistence with Isar
- Light and dark theme support
- Unit, repository, widget, and integration testing

## Tech Stack

- Flutter & Dart
- Riverpod
- Isar Community
- fl_chart
- pdf & printing
- Equatable
- Feature-First Clean Architecture

## Architecture

The project follows a feature-first clean architecture:

```text
lib/
├── core/
├── features/
│   ├── expenses/
│   ├── categories/
│   ├── budgets/
│   ├── analytics/
│   └── group_splits/
│       ├── data/
│       ├── domain/
│       └── presentation/
└── main.dart

packages/
└── local_database/
```

## Getting Started

### Prerequisites

Make sure Flutter is installed:

```bash
flutter doctor
```

### Clone and install

```bash
git clone https://github.com/HuzaifaaNadeem/Splitwise-Expense-Tracker.git
cd Splitwise-Expense-Tracker
flutter pub get
```

### Code generation

Riverpod:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Isar models:

```bash
cd packages/local_database
dart run build_runner build --delete-conflicting-outputs
cd ../..
```

## Run the App

Windows:

```bash
flutter run -d windows
```

Android:

```bash
flutter run
```

## Testing

Run static analysis:

```bash
flutter analyze
```

Run the full test suite:

```bash
flutter test -j 1
```

Run the integration test:

```bash
flutter test integration_test/app_test.dart
```

## Group Expense Logic

For a shared expense:

```text
PKR 3,000 paid by A for A, B, and C
```

Each member owes PKR 1,000, so the resulting balances are:

```text
A  +PKR 2,000
B  -PKR 1,000
C  -PKR 1,000
```

Settlement suggestions:

```text
B → A  PKR 1,000
C → A  PKR 1,000
```

All monetary calculations use integer minor units to avoid floating-point precision issues.

## PDF Reports

Group reports include:

- Group members
- Shared expenses
- Net balances
- Settlement suggestions

## Project Status

**Version 1.0.0**

Core functionality is complete and tested.

## Future Improvements

- Exact split
- Percentage split
- Weighted shares
- Settlement history
- Cloud sync
- Authentication

## Repository

https://github.com/HuzaifaaNadeem/Splitwise-Expense-Tracker
