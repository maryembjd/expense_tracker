import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/email_verification_screen.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/home/presentation/screens/main_navigation_screen.dart';
import '../features/expenses/presentation/screens/add_expense_screen.dart';
import '../features/expenses/presentation/screens/expense_detail_screen.dart';
import '../features/expenses/domain/entities/expense_entity.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/settings_screen.dart';
import '../features/analytics/presentation/screens/analytics_screen.dart';
import '../features/budget/presentation/screens/budget_screen.dart';
import 'export_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuth = authState.whenOrNull(data: (u) => u != null) ?? false;
      final isLoading = authState.isLoading;
      if (isLoading) return null;

      final authRoutes = ['/login', '/register', '/forgot-password'];
      final isOnAuthRoute = authRoutes.any((r) => state.matchedLocation.startsWith(r));
      final isOnVerify = state.matchedLocation == '/verify-email';

      if (!isAuth && !isOnAuthRoute && !isOnVerify) return '/login';
      if (isAuth && isOnAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: '/verify-email', builder: (_, __) => const EmailVerificationScreen()),
      GoRoute(
        path: '/home',
        builder: (_, __) => const MainNavigationScreen(initialIndex: 0),
        routes: [
          GoRoute(path: 'expenses', builder: (_, __) => const MainNavigationScreen(initialIndex: 1)),
          GoRoute(path: 'analytics', builder: (_, __) => const MainNavigationScreen(initialIndex: 2)),
          GoRoute(path: 'budget', builder: (_, __) => const MainNavigationScreen(initialIndex: 3)),
        ],
      ),
      GoRoute(
        path: '/expense/add',
        pageBuilder: (_, state) => _slideUpPage(
          key: state.pageKey,
          child: AddExpenseScreen(expense: state.extra as ExpenseEntity?),
        ),
      ),
      GoRoute(
        path: '/expense/detail',
        pageBuilder: (_, state) => _fadeScalePage(
          key: state.pageKey,
          child: ExpenseDetailScreen(expense: state.extra as ExpenseEntity),
        ),
      ),
      GoRoute(path: '/analytics', builder: (_, __) => const AnalyticsScreen()),
      GoRoute(path: '/budget', builder: (_, __) => const BudgetScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      GoRoute(path: '/export', builder: (_, __) => const ExportScreen()),
    ],
    errorBuilder: (_, state) => _ErrorPage(error: state.error?.message ?? 'Page not found'),
  );
});

CustomTransitionPage _slideUpPage({required LocalKey key, required Widget child}) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (_, animation, __, child) => SlideTransition(
      position: animation.drive(Tween(begin: const Offset(0, 1), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic))),
      child: child,
    ),
  );
}

CustomTransitionPage _fadeScalePage({required LocalKey key, required Widget child}) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (_, animation, __, child) => FadeTransition(
      opacity: animation,
      child: ScaleTransition(scale: animation.drive(Tween(begin: 0.95, end: 1.0).chain(CurveTween(curve: Curves.easeOut))), child: child),
    ),
  );
}

class _ErrorPage extends StatelessWidget {
  final String error;
  const _ErrorPage({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(error, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () => context.go('/login'), child: const Text('Go Home')),
          ],
        ),
      ),
    );
  }
}
