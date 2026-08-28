<div align="center">

<img src="assets/icon/app_icon.png" alt="Splitwise Expense Tracker" width="88" />

Splitwise Expense Tracker

A modern, offline-first expense management app built with Flutter.

Personal finance, budgets, analytics, shared expenses, settlements, and PDF reporting — all in one clean cross-platform application.

<br/>

<img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter&logoColor=white" />
<img alt="Dart" src="https://img.shields.io/badge/Dart-3.x-0175C2?style=flat-square&logo=dart&logoColor=white" />
<img alt="Riverpod" src="https://img.shields.io/badge/State-Riverpod-5B5BD6?style=flat-square" />
<img alt="Isar" src="https://img.shields.io/badge/Storage-Isar-6B4EFF?style=flat-square" />
<img alt="Version" src="https://img.shields.io/badge/Version-1.0.0-222222?style=flat-square" />

</div>

About

Splitwise Expense Tracker is a production-oriented Flutter application for managing both personal and shared finances.

It combines:

personal expense tracking

weekly and monthly budgets

financial analytics

shared group expenses

balance and settlement calculations

PDF reports

persistent multi-currency defaults

offline local storage

The project is structured using Feature-First Clean Architecture and uses Riverpod for state management and Isar Community for persistence.

Core Features

Personal Finance

Add, edit, and delete expenses

Organize transactions by category

Search and filter expense history

Sort by date or amount

Weekly and monthly budget tracking

Budget progress and warning thresholds

Analytics

Weekly and monthly summaries

Income vs expense comparison

Category spending breakdown

Monthly net position

Currency-aware reporting

Shared Expenses

Create and manage groups

Add and remove members

Record shared expenses

Equal split calculations

Net balance calculation

Debt settlement suggestions

Partial and full settlement payments

Settlement history

Reports

Generate group PDF reports

Export members, expenses, balances, and settlement suggestions

Multi-Currency Support

Supported default currencies:

PKR · USD · GBP · EUR · AED · SAR

The selected currency is used for new records and filtered financial views.

Existing transactions retain their original stored currency, so historical values are never silently relabeled or converted.

Live exchange-rate conversion is intentionally not included in v1.0.

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

The architecture keeps business logic, persistence, and UI responsibilities separated and testable.

Tech Stack

Area

Technology

Framework

Flutter

Language

Dart

State Management

Riverpod

Local Database

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

Financial Logic

All monetary calculations use integer minor units to avoid floating-point precision issues.

Example:

PKR 3,000 paid by A
Split between A, B, and C

Balances:

A  +PKR 2,000
B  -PKR 1,000
C  -PKR 1,000

Suggested settlements:

B -> A  PKR 1,000
C -> A  PKR 1,000

Interface

The app uses a responsive Material 3 layout.

Desktop

left navigation

KPI-based overview

responsive tables and cards

dedicated settings workspace

Mobile

bottom navigation

compact responsive cards

scroll-safe forms

touch-friendly actions

The interface supports light, dark, and system appearance modes.

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

The integration test verifies the main shared-expense flow:

Launch
→ Open Groups
→ Create Group
→ Add Shared Expense
→ Save
→ Verify Transaction

Project Status

v1.0.0

Core functionality is complete and tested.

Roadmap

Exact split UI

Percentage split UI

Weighted split UI

Encrypted backup and restore

CSV / spreadsheet export

Authentication

Cloud synchronization

Live FX conversion

Multi-device sync

License

Add the appropriate license before public or commercial distribution.

<div align="center">

Built with Flutter · Offline-first · Clean Architecture

</div>
