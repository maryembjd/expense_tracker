import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppConstants {
  // App Info
  static const appName = 'Expense Tracker';
  static const appVersion = '1.0.0';

  // Firestore Collections
  static const usersCollection = 'users';
  static const expensesCollection = 'expenses';
  static const budgetsCollection = 'budgets';
  static const notificationsCollection = 'notifications';

  // Hive Boxes
  static const expensesBox = 'expenses_box';
  static const budgetsBox = 'budgets_box';
  static const settingsBox = 'settings_box';
  static const userBox = 'user_box';

  // Hive Type IDs
  static const expenseModelTypeId = 0;
  static const budgetModelTypeId = 1;
  static const userModelTypeId = 2;

  // Budget Alert Thresholds
  static const budgetWarningThreshold = 0.80;
  static const budgetCriticalThreshold = 1.00;

  // Pagination
  static const expensesPageSize = 20;

  // Supported Currencies
  static const List<Map<String, String>> currencies = [
    {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
    {'code': 'GBP', 'symbol': '£', 'name': 'British Pound'},
    {'code': 'JPY', 'symbol': '¥', 'name': 'Japanese Yen'},
    {'code': 'CAD', 'symbol': 'CA\$', 'name': 'Canadian Dollar'},
    {'code': 'AUD', 'symbol': 'A\$', 'name': 'Australian Dollar'},
    {'code': 'CHF', 'symbol': 'Fr', 'name': 'Swiss Franc'},
    {'code': 'CNY', 'symbol': '¥', 'name': 'Chinese Yuan'},
    {'code': 'INR', 'symbol': '₹', 'name': 'Indian Rupee'},
    {'code': 'BRL', 'symbol': 'R\$', 'name': 'Brazilian Real'},
    {'code': 'MAD', 'symbol': 'DH', 'name': 'Moroccan Dirham'},
    {'code': 'TND', 'symbol': 'DT', 'name': 'Tunisian Dinar'},
    {'code': 'EGP', 'symbol': 'E£', 'name': 'Egyptian Pound'},
    {'code': 'SAR', 'symbol': '﷼', 'name': 'Saudi Riyal'},
    {'code': 'AED', 'symbol': 'د.إ', 'name': 'UAE Dirham'},
  ];

  // Expense Categories
  static const List<ExpenseCategory> categories = [
    ExpenseCategory(id: 'food', name: 'Food & Dining', icon: Icons.restaurant_rounded, color: AppColors.catFood),
    ExpenseCategory(id: 'transport', name: 'Transport', icon: Icons.directions_car_rounded, color: AppColors.catTransport),
    ExpenseCategory(id: 'shopping', name: 'Shopping', icon: Icons.shopping_bag_rounded, color: AppColors.catShopping),
    ExpenseCategory(id: 'health', name: 'Health', icon: Icons.favorite_rounded, color: AppColors.catHealth),
    ExpenseCategory(id: 'entertainment', name: 'Entertainment', icon: Icons.movie_rounded, color: AppColors.catEntertainment),
    ExpenseCategory(id: 'housing', name: 'Housing', icon: Icons.home_rounded, color: AppColors.catHousing),
    ExpenseCategory(id: 'education', name: 'Education', icon: Icons.school_rounded, color: AppColors.catEducation),
    ExpenseCategory(id: 'travel', name: 'Travel', icon: Icons.flight_rounded, color: AppColors.catTravel),
    ExpenseCategory(id: 'personal', name: 'Personal', icon: Icons.person_rounded, color: AppColors.catPersonal),
    ExpenseCategory(id: 'other', name: 'Other', icon: Icons.category_rounded, color: AppColors.catOther),
  ];

  // Animation Durations
  static const animFast = Duration(milliseconds: 150);
  static const animNormal = Duration(milliseconds: 300);
  static const animSlow = Duration(milliseconds: 500);

  // Spacing
  static const double spacingXS = 4;
  static const double spacingS = 8;
  static const double spacingM = 16;
  static const double spacingL = 24;
  static const double spacingXL = 32;
  static const double spacingXXL = 48;

  // Border Radius
  static const double radiusS = 8;
  static const double radiusM = 12;
  static const double radiusL = 16;
  static const double radiusXL = 24;
  static const double radiusRound = 100;
}

class ExpenseCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  const ExpenseCategory({required this.id, required this.name, required this.icon, required this.color});
}
