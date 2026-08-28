<div align="center">

<img src="assets/icon/app_icon.png" alt="Splitwise Expense Tracker" width="96" />

Splitwise Expense Tracker

Offline-first personal finance and shared expense management built with Flutter.

<p>
Flutter · Riverpod · Isar Community · Material 3 · fl_chart · PDF Reports
</p>

</div>

Overview

Splitwise Expense Tracker is a cross-platform finance application for managing personal expenses, budgets, analytics, shared group expenses, balances, settlements, and PDF reports.

The app is designed around an offline-first architecture with local persistence, clean separation of concerns, and a responsive Material 3 interface for desktop and mobile.

Features

Personal finance

Add, edit, and delete expenses

Search, filter, and sort transactions

Category-based expense organization

Weekly and monthly budgets

Budget progress and warning thresholds

Persistent local storage

Analytics

Weekly and monthly summaries

Income vs expense comparison

Category spending breakdown

Monthly net position

Currency-isolated analytics

Shared expenses

Create groups and manage members

Add shared expenses

Equal-split calculations

Net balance calculation

Debt settlement suggestions

Partial and full settlement payments

Settlement history

Archive or delete groups

Reports

Generate group PDF reports

Include members, expenses, balances, and settlement suggestions

Settings

Persistent default currency

Light / dark / system theme

Budget and category management

Local data location

PDF report access

Supported Currencies

PKR · USD · GBP · EUR · AED · SAR

The selected default currency is used for new records.

Existing expenses, budgets, groups, and settlements keep their original stored currency values. No automatic FX conversion is performed.

Screenshots

<div align="center">

<table>
  <tr>
    <td align="center">
      <img src="docs/screenshots/overview.png" width="390" alt="Overview" /><br/>
      <sub>Overview</sub>
    </td>
    <td align="center">
      <img src="docs/screenshots/expenses.png" width="390" alt="Expenses" /><br/>
      <sub>Expenses</sub>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="docs/screenshots/analytics.png" width="390" alt="Analytics" /><br/>
      <sub>Analytics</sub>
    </td>
    <td align="center">
      <img src="docs/screenshots/groups.png" width="390" alt="Groups" /><br/>
      <sub>Groups</sub>
    </td>
  </tr>
</table>

</div>

Place screenshots in docs/screenshots/ using the filenames above.

Tech Stack

Category

Technology

Framework

Flutter

Language

Dart

State management

Riverpod

Local database

Isar Community

Charts

fl_chart

PDF

pdf + printing

UI

Material 3

Architecture

Feature-First Clean Architecture

Testing

flutter_test + integration_test

Architecture

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

The project separates presentation, domain, and data responsibilities so business logic remains testable and persistence stays isolated from UI code.

Money Handling

All monetary calculations use integer minor units instead of floating-point arithmetic.

Example:

PKR 3,000 paid by A
Split between A, B, C

A  +PKR 2,000
B  -PKR 1,000
C  -PKR 1,000

Suggested settlement:

B -> A  PKR 1,000
C -> A  PKR 1,000

Getting Started

Clone

git clone https://github.com/HuzaifaaNadeem/Splitwise-Expense-Tracker.git
cd Splitwise-Expense-Tracker

Install dependencies

flutter pub get

Riverpod code generation

dart run build_runner build --delete-conflicting-outputs

Isar code generation

cd packages/local_database
dart run build_runner build --delete-conflicting-outputs
cd ../..

Run

Windows

flutter run -d windows

Android

flutter run

Testing

flutter analyze
flutter test -j 1
flutter test integration_test/app_test.dart

The integration test covers the main shared-expense flow:

Launch
-> Groups
-> Create Group
-> Group Details
-> Add Shared Expense
-> Save
-> Verify Transaction

Project Status

Version 1.0.0

Core functionality is complete and tested.

Planned Improvements

Exact split UI

Percentage split UI

Weighted share split UI

Encrypted backup and restore

CSV / spreadsheet export

Cloud sync

Authentication

Live FX conversion

Multi-device sync

License

Choose a license before public or commercial distribution.

<div align="center">

Built with Flutter · Offline-first · Clean Architecture

</div>
