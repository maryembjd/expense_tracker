import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/expenses/data/models/expense_model.dart';
import 'features/budget/data/models/budget_model.dart';
import 'features/auth/data/models/user_model.dart';
import 'core/constants/app_constants.dart';
import 'core/services/notification_service.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
  ));

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  // Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Hive
  await Hive.initFlutter();
  Hive.registerAdapter(ExpenseModelAdapter());
  Hive.registerAdapter(BudgetModelAdapter());
  Hive.registerAdapter(UserModelAdapter());
  await Hive.openBox<ExpenseModel>(AppConstants.expensesBox);
  await Hive.openBox<BudgetModel>(AppConstants.budgetsBox);
  await Hive.openBox<UserModel>(AppConstants.userBox);
  await Hive.openBox(AppConstants.settingsBox);

  // Notifications
  await NotificationService.init();

  runApp(const ProviderScope(child: ExpenseTrackerApp()));
}
