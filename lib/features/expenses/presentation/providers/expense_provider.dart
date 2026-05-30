import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../data/datasources/expense_remote_datasource.dart';
import '../../data/datasources/expense_local_datasource.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Infrastructure Providers
final expenseRemoteDataSourceProvider = Provider<ExpenseRemoteDataSource>((ref) {
  return ExpenseRemoteDataSourceImpl(firestore: FirebaseFirestore.instance);
});

final expenseLocalDataSourceProvider = Provider<ExpenseLocalDataSource>((ref) {
  return ExpenseLocalDataSourceImpl();
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepositoryImpl(
    ref.read(expenseRemoteDataSourceProvider),
    ref.read(expenseLocalDataSourceProvider),
  );
});

// Realtime stream of all expenses for current user
final expensesStreamProvider = StreamProvider<List<ExpenseEntity>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.read(expenseRepositoryProvider).watchExpenses(user.uid);
});

// Filter State
class ExpenseFilter {
  final String? category;
  final DateTime? from;
  final DateTime? to;
  final double? minAmount;
  final double? maxAmount;
  final String searchQuery;
  final String sortBy; // 'date', 'amount', 'category'
  final bool sortDesc;

  const ExpenseFilter({
    this.category,
    this.from,
    this.to,
    this.minAmount,
    this.maxAmount,
    this.searchQuery = '',
    this.sortBy = 'date',
    this.sortDesc = true,
  });

  ExpenseFilter copyWith({
    String? category,
    DateTime? from,
    DateTime? to,
    double? minAmount,
    double? maxAmount,
    String? searchQuery,
    String? sortBy,
    bool? sortDesc,
    bool clearCategory = false,
    bool clearFrom = false,
    bool clearTo = false,
  }) => ExpenseFilter(
    category: clearCategory ? null : (category ?? this.category),
    from: clearFrom ? null : (from ?? this.from),
    to: clearTo ? null : (to ?? this.to),
    minAmount: minAmount ?? this.minAmount,
    maxAmount: maxAmount ?? this.maxAmount,
    searchQuery: searchQuery ?? this.searchQuery,
    sortBy: sortBy ?? this.sortBy,
    sortDesc: sortDesc ?? this.sortDesc,
  );

  bool get hasActiveFilters => category != null || from != null || to != null || minAmount != null || maxAmount != null || searchQuery.isNotEmpty;
}

final expenseFilterProvider = StateProvider<ExpenseFilter>((ref) => const ExpenseFilter());

// Filtered expenses derived from stream + filter
final filteredExpensesProvider = Provider<AsyncValue<List<ExpenseEntity>>>((ref) {
  final stream = ref.watch(expensesStreamProvider);
  final filter = ref.watch(expenseFilterProvider);
  return stream.whenData((expenses) {
    var list = expenses.where((e) {
      if (filter.category != null && filter.category!.isNotEmpty && e.category != filter.category) return false;
      if (filter.from != null && e.date.isBefore(filter.from!)) return false;
      if (filter.to != null && e.date.isAfter(filter.to!)) return false;
      if (filter.minAmount != null && e.amount < filter.minAmount!) return false;
      if (filter.maxAmount != null && e.amount > filter.maxAmount!) return false;
      if (filter.searchQuery.isNotEmpty) {
        final q = filter.searchQuery.toLowerCase();
        if (!e.description.toLowerCase().contains(q) && !e.category.toLowerCase().contains(q) && !(e.note?.toLowerCase().contains(q) ?? false)) return false;
      }
      return true;
    }).toList();

    list.sort((a, b) {
      int cmp;
      switch (filter.sortBy) {
        case 'amount': cmp = a.amount.compareTo(b.amount); break;
        case 'category': cmp = a.category.compareTo(b.category); break;
        default: cmp = a.date.compareTo(b.date);
      }
      return filter.sortDesc ? -cmp : cmp;
    });
    return list;
  });
});

// Monthly expenses for the current month
final currentMonthExpensesProvider = Provider<AsyncValue<List<ExpenseEntity>>>((ref) {
  final stream = ref.watch(expensesStreamProvider);
  return stream.whenData((expenses) {
    final now = DateTime.now();
    return expenses.where((e) => e.date.year == now.year && e.date.month == now.month).toList();
  });
});

// Expense CRUD notifier
class ExpenseState {
  final bool isLoading;
  final String? error;
  final String? successMessage;
  const ExpenseState({this.isLoading = false, this.error, this.successMessage});
  ExpenseState copyWith({bool? isLoading, String? error, String? successMessage}) =>
    ExpenseState(isLoading: isLoading ?? this.isLoading, error: error, successMessage: successMessage);
}

class ExpenseNotifier extends StateNotifier<ExpenseState> {
  final ExpenseRepository _repo;
  final String userId;

  ExpenseNotifier(this._repo, this.userId) : super(const ExpenseState());

  Future<bool> addExpense(ExpenseEntity expense) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repo.addExpense(expense);
    return result.fold(
      (f) { state = state.copyWith(isLoading: false, error: f.message); return false; },
      (_) { state = state.copyWith(isLoading: false, successMessage: 'Expense added!'); return true; },
    );
  }

  Future<bool> updateExpense(ExpenseEntity expense) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repo.updateExpense(expense);
    return result.fold(
      (f) { state = state.copyWith(isLoading: false, error: f.message); return false; },
      (_) { state = state.copyWith(isLoading: false, successMessage: 'Expense updated!'); return true; },
    );
  }

  Future<bool> deleteExpense(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repo.deleteExpense(id, userId);
    return result.fold(
      (f) { state = state.copyWith(isLoading: false, error: f.message); return false; },
      (_) { state = state.copyWith(isLoading: false, successMessage: 'Expense deleted'); return true; },
    );
  }

  void clearMessages() => state = state.copyWith(error: null, successMessage: null);
}

final expenseNotifierProvider = StateNotifierProvider<ExpenseNotifier, ExpenseState>((ref) {
  final user = ref.watch(currentUserProvider);
  return ExpenseNotifier(ref.read(expenseRepositoryProvider), user?.uid ?? '');
});
