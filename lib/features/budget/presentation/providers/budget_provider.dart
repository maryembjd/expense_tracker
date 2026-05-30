import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/budget_entity.dart';
import '../../data/models/budget_model.dart';
import '../../data/datasources/budget_remote_datasource.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../expenses/presentation/providers/expense_provider.dart';
import '../../../../core/constants/app_constants.dart';

final budgetRemoteDataSourceProvider = Provider<BudgetRemoteDataSource>((ref) {
  return BudgetRemoteDataSourceImpl(firestore: FirebaseFirestore.instance);
});

// Current month/year tracker
final selectedBudgetMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Watch budget for selected month
final currentBudgetProvider = StreamProvider<BudgetEntity?>((ref) {
  final user = ref.watch(currentUserProvider);
  final date = ref.watch(selectedBudgetMonthProvider);
  if (user == null) return const Stream.empty();
  return ref.read(budgetRemoteDataSourceProvider)
    .watchBudget(user.uid, date.month, date.year)
    .map((m) => m?.toEntity());
});

// Budget status combining budget + expenses
final budgetStatusProvider = Provider<AsyncValue<BudgetStatus?>>((ref) {
  final budgetAsync = ref.watch(currentBudgetProvider);
  final expensesAsync = ref.watch(currentMonthExpensesProvider);

  return budgetAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
    data: (budget) {
      if (budget == null) return const AsyncValue.data(null);
      return expensesAsync.when(
        loading: () => const AsyncValue.loading(),
        error: (e, s) => AsyncValue.error(e, s),
        data: (expenses) {
          final spent = expenses.fold(0.0, (s, e) => s + e.amount);
          final categorySpent = <String, double>{};
          for (final e in expenses) {
            categorySpent[e.category] = (categorySpent[e.category] ?? 0) + e.amount;
          }
          return AsyncValue.data(BudgetStatus(
            budget: budget,
            spent: spent,
            remaining: (budget.totalBudget - spent).clamp(0, double.infinity),
            percentage: budget.totalBudget > 0 ? (spent / budget.totalBudget).clamp(0, 2) : 0,
            categorySpent: categorySpent,
          ));
        },
      );
    },
  );
});

// Budget notifier
class BudgetNotifierState {
  final bool isLoading;
  final String? error;
  final String? success;
  const BudgetNotifierState({this.isLoading = false, this.error, this.success});
  BudgetNotifierState copyWith({bool? isLoading, String? error, String? success}) =>
    BudgetNotifierState(isLoading: isLoading ?? this.isLoading, error: error, success: success);
}

class BudgetNotifier extends StateNotifier<BudgetNotifierState> {
  final BudgetRemoteDataSource _datasource;
  final String userId;

  BudgetNotifier(this._datasource, this.userId) : super(const BudgetNotifierState());

  Future<bool> setBudget({
    required double totalBudget,
    required String currency,
    required Map<String, double> categoryBudgets,
    required int month,
    required int year,
    String? existingId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _datasource.setBudget(BudgetModel(
        id: existingId ?? '',
        userId: userId,
        totalBudget: totalBudget,
        currency: currency,
        categoryBudgets: categoryBudgets,
        month: month,
        year: year,
        createdAt: DateTime.now(),
      ));
      state = state.copyWith(isLoading: false, success: 'Budget saved!');
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void clearMessages() => state = state.copyWith(error: null, success: null);
}

final budgetNotifierProvider = StateNotifierProvider<BudgetNotifier, BudgetNotifierState>((ref) {
  final user = ref.watch(currentUserProvider);
  return BudgetNotifier(ref.read(budgetRemoteDataSourceProvider), user?.uid ?? '');
});
