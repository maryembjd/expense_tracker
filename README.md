# 💸 Expense Tracker

A modern, production-grade personal finance mobile application built with **Flutter 3.x** and **Firebase**. Inspired by fintech leaders like Revolut and Wallet, it delivers a clean and responsive UI backed by a scalable Clean Architecture — helping users take full control of their spending.

---

## 📱 Screenshots Overview

| Dashboard | Expenses | Analytics | Budget |
|:---------:|:--------:|:---------:|:------:|
| Monthly overview, quick actions, recent transactions | Grouped list, search & filter, swipe-to-delete | Pie, bar & line charts, category rankings | Progress bars, category budgets, alerts |

| Add Expense | Profile | Settings | Export |
|:-----------:|:-------:|:--------:|:------:|
| Category picker, currency, recurring toggle | Edit name/photo, change password | Dark mode, currency, notifications | PDF & CSV with date range |

---

## ✨ Features

### 🔐 Authentication
- Email & password sign-up and sign-in
- Email verification flow with auto-polling
- Password reset via email link
- Persistent session (Firebase Auth state)
- Profile management: name, photo, phone number
- Password change with re-authentication
- Account deletion with full data cleanup

### 💰 Expense Management
- Add, edit, and delete expenses
- Fields: amount, currency, category, description, date, note, tags
- Swipe-to-dismiss with confirmation dialog
- 10 built-in categories with icons and colors
- 15 supported currencies
- Recurring expenses (daily / weekly / monthly / yearly)
- Full-text search across description, category, and notes
- Advanced filters: category, date range, amount range, sort order
- Grouped timeline view with daily subtotals

### 📊 Budget Management
- Set a global monthly budget per currency
- Per-category budget limits
- Real-time progress with circular and linear indicators
- Automatic alerts at **80%** (warning) and **100%** (exceeded)
- Month navigation to review past budgets
- Budget vs. actual spending side by side

### 🏠 Dashboard
- Personalised greeting with time-of-day logic
- Live month-to-date total with month-over-month % change
- Budget overview card (spending gauge)
- Quick action buttons: Add, Analytics, Budget, Export
- Recent 5 transactions with inline navigation
- Pull-to-refresh

### 📈 Analytics
Three-tab analytics screen:

**Overview tab**
- Total spending for the selected month
- Interactive pie chart — category distribution
- Average expense and largest single expense stats
- Top 5 expenses ranked by amount

**Trends tab**
- Bar chart — last 6 months of spending
- Line chart — last 7 weeks of evolution (smooth curve + area fill)
- Formatted axis labels with compact currency values

**Categories tab**
- Full ranked list of categories by spending
- Per-category progress bar
- Transaction count and percentage share

### 👤 Profile & Settings
- Edit display name, phone number
- Profile photo via gallery picker
- Email verification badge
- Dark / Light theme toggle (persisted to Firestore)
- Preferred currency selector (15 currencies)
- Push notification controls
- Privacy Policy and Terms of Service links
- Sign out and account deletion

### 📤 Export
- **PDF report**: header, summary stats, category table, full transaction list
- **CSV export**: date, description, category, amount, currency, note
- Custom date-range selector
- Native share sheet via `share_plus`

### 🔔 Notifications
- Firebase Cloud Messaging (FCM) for server-sent alerts
- Local notifications for budget warnings (80% and 100%)
- Scheduled daily expense reminder
- Scheduled weekly summary (every Monday at 9:00 AM)
- Full permission request flow on iOS and Android

### 🌐 Offline Support
- Hive local cache for expenses and budgets
- Automatic fallback to cache on network failure
- Cache invalidated and refreshed on reconnect

---

## 🏗️ Architecture

The project follows **Clean Architecture** with strict layer separation per feature.

```
lib/
├── main.dart                         # Entry point: Firebase, Hive, Notifications
├── app.dart                          # MaterialApp.router with dynamic theming
├── firebase_options.dart             # ⚠️ Replace via `flutterfire configure`
│
├── core/
│   ├── constants/
│   │   └── app_constants.dart        # Categories, currencies, spacing, box names
│   ├── errors/
│   │   └── failures.dart             # Typed failure classes (dartz Either)
│   ├── services/
│   │   ├── notification_service.dart # FCM + local notifications + scheduling
│   │   └── export_service.dart       # PDF and CSV generation + share
│   ├── theme/
│   │   ├── app_colors.dart           # Brand palette, gradients, category colors
│   │   └── app_theme.dart            # Material 3 ThemeData (light + dark)
│   ├── utils/
│   │   ├── currency_formatter.dart   # Compact / full / symbol formatting
│   │   ├── date_formatter.dart       # Relative, grouped, ISO, month helpers
│   │   └── validators.dart           # Form validators (email, password, amount)
│   └── widgets/
│       ├── app_card.dart             # AppCard, GradientCard, StatCard
│       ├── custom_button.dart        # PrimaryButton, GradientButton, SecondaryButton
│       ├── custom_text_field.dart    # AppTextField, AmountTextField, SearchTextField
│       └── loading_states.dart       # Shimmer loaders, EmptyState, ErrorState
│
├── features/
│   ├── auth/
│   │   ├── domain/
│   │   │   ├── entities/user_entity.dart
│   │   │   ├── repositories/auth_repository.dart     # Abstract contract
│   │   │   └── usecases/                             # signIn, signUp, signOut, reset
│   │   ├── data/
│   │   │   ├── models/user_model.dart                # Hive + Firestore serialization
│   │   │   ├── datasources/auth_remote_datasource.dart
│   │   │   └── repositories/auth_repository_impl.dart
│   │   └── presentation/
│   │       ├── providers/auth_provider.dart          # authStateProvider, authNotifierProvider
│   │       └── screens/                              # Login, Register, ForgotPassword, EmailVerification
│   │
│   ├── expenses/
│   │   ├── domain/
│   │   │   ├── entities/expense_entity.dart
│   │   │   └── repositories/expense_repository.dart
│   │   ├── data/
│   │   │   ├── models/expense_model.dart             # Hive adapter (pre-generated .g.dart)
│   │   │   ├── datasources/expense_remote_datasource.dart
│   │   │   ├── datasources/expense_local_datasource.dart
│   │   │   └── repositories/expense_repository_impl.dart
│   │   └── presentation/
│   │       ├── providers/expense_provider.dart       # Stream, filter state, CRUD notifier
│   │       ├── screens/                              # ExpensesScreen, AddExpenseScreen, ExpenseDetailScreen
│   │       └── widgets/expense_card.dart             # Card + grouped list widget
│   │
│   ├── budget/
│   │   ├── domain/entities/budget_entity.dart        # BudgetEntity + BudgetStatus
│   │   ├── data/
│   │   │   ├── models/budget_model.dart
│   │   │   └── datasources/budget_remote_datasource.dart
│   │   └── presentation/
│   │       ├── providers/budget_provider.dart        # watchBudget stream + notifier
│   │       ├── screens/budget_screen.dart
│   │       └── widgets/budget_progress_widget.dart   # BudgetProgressCard, CategoryBudgetTile
│   │
│   ├── dashboard/
│   │   └── presentation/
│   │       ├── providers/dashboard_provider.dart     # DashboardSummary derived provider
│   │       └── screens/dashboard_screen.dart
│   │
│   ├── analytics/
│   │   └── presentation/
│   │       ├── providers/analytics_provider.dart     # CategoryData, MonthlyData, WeeklyData
│   │       └── screens/analytics_screen.dart         # 3 tabs: Overview, Trends, Categories
│   │
│   ├── profile/
│   │   └── presentation/
│   │       ├── providers/profile_provider.dart
│   │       └── screens/                              # ProfileScreen, SettingsScreen
│   │
│   └── home/
│       └── presentation/screens/
│           └── main_navigation_screen.dart           # Bottom nav with floating Add button
│
└── router/
    ├── app_router.dart                               # GoRouter with auth guard + page transitions
    └── export_screen.dart                            # Export UI screen
```

---

## 🛠️ Technology Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter 3.x (Dart ≥3.3) |
| **State Management** | Riverpod 2.x (StateNotifier, StreamProvider, Provider) |
| **Navigation** | GoRouter 14.x with auth redirect guard |
| **Cloud Database** | Firebase Firestore |
| **Authentication** | Firebase Auth |
| **Push Notifications** | Firebase Cloud Messaging (FCM) |
| **Local Notifications** | flutter_local_notifications + timezone |
| **Offline Cache** | Hive + hive_flutter |
| **Charts** | fl_chart 0.68 (Pie, Bar, Line) |
| **UI / Design** | Material Design 3, Google Fonts (Inter) |
| **Animations** | flutter_animate, shimmer |
| **Progress Indicators** | percent_indicator |
| **Export** | pdf + csv + share_plus |
| **Functional Error Handling** | dartz (Either<Failure, T>) |
| **Image Picker** | image_picker |
| **HTTP** | Native Firebase SDK |
| **Equality** | equatable |
| **UUID Generation** | uuid |
| **Date/Number Formatting** | intl |

---

## 🚀 Getting Started

### Prerequisites

| Tool | Version |
|---|---|
| Flutter SDK | ≥ 3.3.0 |
| Dart SDK | ≥ 3.3.0 |
| Android Studio / VS Code | Latest |
| Xcode (iOS builds) | ≥ 15 |
| Firebase account | Free Spark plan is sufficient |

### 1 — Clone the repository

```bash
git clone https://github.com/your-username/expense_tracker.git
cd expense_tracker
```

### 2 — Create your Firebase project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **Add project** → follow the setup wizard
3. Enable the following services:
   - **Authentication** → Email/Password provider
   - **Firestore Database** → Start in production mode
   - **Cloud Messaging** (for push notifications)
   - **Storage** (for profile photo uploads)

### 3 — Configure FlutterFire

```bash
# Install the FlutterFire CLI
dart pub global activate flutterfire_cli

# Run inside the project root — this overwrites lib/firebase_options.dart
# and generates google-services.json / GoogleService-Info.plist
flutterfire configure
```

### 4 — Android setup

Copy the generated file to the correct location:

```
android/app/google-services.json
```

Ensure your `android/app/build.gradle` targets at least API 21:

```gradle
android {
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

### 5 — iOS setup

Copy the generated file:

```
ios/Runner/GoogleService-Info.plist
```

Open `ios/Runner.xcworkspace` in Xcode and:
- Set your **Bundle Identifier** (e.g. `com.yourname.expensetracker`)
- Enable **Push Notifications** capability
- Enable **Background Modes → Remote notifications**

### 6 — Install dependencies

```bash
flutter pub get
```

> **No code generation needed.** The Hive `.g.dart` adapter files are pre-written and committed.

### 7 — Deploy Firestore rules and indexes

```bash
# Install Firebase CLI if needed
npm install -g firebase-tools
firebase login

# Deploy security rules
firebase deploy --only firestore:rules

# Deploy composite indexes (required for filtered queries)
firebase deploy --only firestore:indexes
```

### 8 — Run the app

```bash
# Debug on connected device or emulator
flutter run

# Release build for Android
flutter build apk --release

# Release build for iOS
flutter build ipa --release
```

---

## 🔒 Firestore Security Rules

The included [`firestore.rules`](firestore.rules) enforces:

- Users can only **read and write their own documents**
- Expenses must have valid `amount > 0`, a 3-char `currency`, and a non-empty `description`
- Budgets must have valid `month` (1–12) and `year` (≥ 2020)
- No client can modify `uid`, `email`, or `createdAt` on user documents after creation

---

## 📋 Firestore Data Model

### `users/{uid}`
```json
{
  "uid": "string",
  "email": "string",
  "displayName": "string",
  "photoUrl": "string | null",
  "phoneNumber": "string | null",
  "emailVerified": "boolean",
  "preferredCurrency": "USD",
  "notificationsEnabled": true,
  "darkMode": false,
  "createdAt": 1234567890000,
  "lastLoginAt": 1234567890000
}
```

### `expenses/{expenseId}`
```json
{
  "userId": "string",
  "amount": 42.50,
  "currency": "USD",
  "category": "food",
  "description": "Lunch at cafe",
  "date": 1234567890000,
  "note": "string | null",
  "tags": [],
  "isRecurring": false,
  "recurringFrequency": "monthly | null",
  "createdAt": 1234567890000,
  "updatedAt": 1234567890000
}
```

### `budgets/{userId}_{year}_{month}`
```json
{
  "userId": "string",
  "totalBudget": 2000.00,
  "currency": "USD",
  "categoryBudgets": {
    "food": 500.00,
    "transport": 150.00,
    "entertainment": 200.00
  },
  "month": 5,
  "year": 2026,
  "createdAt": 1234567890000,
  "updatedAt": 1234567890000
}
```

---

## 🎨 Design System

### Color Palette

| Token | Hex | Usage |
|---|---|---|
| Primary | `#6C63FF` | Buttons, active nav, accents |
| Primary Dark | `#4B44D6` | Pressed states |
| Secondary | `#00D4AA` | Success, secondary actions |
| Accent | `#FF6584` | Highlights, error-adjacent |
| Warning | `#FFB347` | Budget 80% alert |
| Error | `#FF6584` | Budget exceeded, delete |
| Background Light | `#F8F9FF` | Scaffold background |
| Background Dark | `#0F0F1E` | Dark scaffold |

### Category Colors

| Category | Color |
|---|---|
| Food & Dining | `#FF6B6B` |
| Transport | `#4ECDC4` |
| Shopping | `#FFE66D` |
| Health | `#6BCB77` |
| Entertainment | `#9B59B6` |
| Housing | `#3498DB` |
| Education | `#E67E22` |
| Travel | `#1ABC9C` |
| Personal | `#E91E63` |
| Other | `#95A5A6` |

### Typography

The app uses **Inter** (Google Fonts fallback) across all text styles, with weight variants from Regular (400) to Bold (700). The Material 3 text scale is fully customised in [`app_theme.dart`](lib/core/theme/app_theme.dart).

---

## 📦 Supported Currencies

USD · EUR · GBP · JPY · CAD · AUD · CHF · CNY · INR · BRL · MAD · TND · EGP · SAR · AED

---

## 🔔 Notification Types

| ID | Type | Trigger |
|---|---|---|
| `1001` | Budget Warning | Spending reaches 80% of monthly budget |
| `1002` | Budget Exceeded | Spending surpasses 100% of monthly budget |
| `2001` | Daily Reminder | Scheduled — configurable hour/minute |
| `3001` | Weekly Summary | Every Monday at 09:00 local time |
| FCM | Server push | Budget alerts, app updates from backend |

---

## 📤 Export Formats

### PDF Report includes:
- Header with user name and date range
- Summary: total spent, transaction count, average per day
- Category breakdown table with amounts and percentages
- Full transaction list (description, category, date, amount)

### CSV columns:
`Date, Description, Category, Amount, Currency, Note`

---

## 🗂️ State Management Patterns

### Provider hierarchy

```
authStateProvider (StreamProvider)
  └── currentUserProvider (StateProvider — derived)
        ├── expensesStreamProvider (StreamProvider — real-time Firestore)
        │     ├── filteredExpensesProvider (Provider — filter + sort)
        │     ├── currentMonthExpensesProvider (Provider — this month)
        │     └── dashboardSummaryProvider (Provider — aggregated)
        ├── currentBudgetProvider (StreamProvider — real-time Firestore)
        │     └── budgetStatusProvider (Provider — budget + spent combined)
        └── analyticsDataProvider (Provider — computed from stream)
```

### CRUD flow

Every mutating operation uses a `StateNotifier` that:
1. Sets `isLoading = true`
2. Calls the repository (returns `Either<Failure, T>`)
3. Folds the result → sets `error` or `successMessage`
4. The UI listens with `ref.listen` and shows `SnackBar` feedback

---

## 🧪 Testing

The project is structured for testability at every layer:

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

**Recommended test targets:**

| Layer | What to test |
|---|---|
| Domain entities | `copyWith`, computed properties |
| Repository impls | Mock datasources, verify Either results |
| Notifiers | State transitions for loading / error / success |
| Widgets | Golden tests for cards and screens |
| Integration | Full auth and expense CRUD flows |

---

## 📁 Project Configuration Files

| File | Purpose |
|---|---|
| `pubspec.yaml` | Dependencies, assets, fonts |
| `analysis_options.yaml` | Lint rules (extends flutter_lints) |
| `firestore.rules` | Firestore security rules |
| `firestore.indexes.json` | Composite indexes for filtered queries |
| `lib/firebase_options.dart` | ⚠️ Placeholder — replaced by `flutterfire configure` |

---

## 🔧 Environment & Build

### Debug vs Release

```bash
# Debug (hot reload enabled)
flutter run

# Profile (performance profiling)
flutter run --profile

# Release APK
flutter build apk --release --split-per-abi

# Release App Bundle (Google Play)
flutter build appbundle --release

# iOS Archive
flutter build ipa --release
```

### Signing Android

Add to `android/key.properties` (do not commit):

```properties
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=your_key_alias
storeFile=/path/to/your/keystore.jks
```

Then reference it in `android/app/build.gradle`.

---

## 🚧 Known Limitations & Future Work

| Item | Status | Notes |
|---|---|---|
| Profile photo upload | Placeholder | `image_picker` is wired; Storage upload needs to be added |
| Biometric login | Not yet | Add `local_auth` package |
| Currency conversion | Not yet | Integrate an exchange rate API |
| Recurring expense automation | Not yet | Cloud Function to auto-create recurring entries |
| Multi-account / family mode | Not yet | Firestore subcollection restructure needed |
| Web / desktop support | Not tested | GoRouter is web-ready; platform-specific code needs review |
| Backup & restore | Not yet | Firestore export already possible via export screen |

---

## 📄 License

```
MIT License

Copyright (c) 2026

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software.
```

---

## 🙏 Acknowledgements

- [Flutter](https://flutter.dev) — cross-platform UI framework
- [Firebase](https://firebase.google.com) — backend infrastructure
- [Riverpod](https://riverpod.dev) — reactive state management
- [fl_chart](https://pub.dev/packages/fl_chart) — beautiful charts
- [GoRouter](https://pub.dev/packages/go_router) — declarative navigation
- [flutter_animate](https://pub.dev/packages/flutter_animate) — smooth animations
- Design inspiration: [Revolut](https://revolut.com) · [Wallet by BudgetBakers](https://budgetbakers.com)

---

<div align="center">
  Built with Flutter &amp; Firebase
</div>
#   e x p e n s e _ t r a c k e r  
 #   e x p e n s e _ t r a c k e r  
 