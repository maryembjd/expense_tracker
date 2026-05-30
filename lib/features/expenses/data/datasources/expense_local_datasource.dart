import 'package:hive/hive.dart';
import '../models/expense_model.dart';
import '../../../../core/constants/app_constants.dart';

abstract class ExpenseLocalDataSource {
  Future<List<ExpenseModel>> getCachedExpenses(String userId);
  Future<void> cacheExpenses(List<ExpenseModel> expenses);
  Future<void> addCachedExpense(ExpenseModel expense);
  Future<void> updateCachedExpense(ExpenseModel expense);
  Future<void> deleteCachedExpense(String id);
  Future<void> clearCache(String userId);
}

class ExpenseLocalDataSourceImpl implements ExpenseLocalDataSource {
  Box<ExpenseModel> get _box => Hive.box<ExpenseModel>(AppConstants.expensesBox);

  @override
  Future<List<ExpenseModel>> getCachedExpenses(String userId) async {
    return _box.values.where((e) => e.userId == userId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<void> cacheExpenses(List<ExpenseModel> expenses) async {
    final map = {for (var e in expenses) e.id: e};
    await _box.putAll(map);
  }

  @override
  Future<void> addCachedExpense(ExpenseModel expense) async {
    await _box.put(expense.id, expense);
  }

  @override
  Future<void> updateCachedExpense(ExpenseModel expense) async {
    await _box.put(expense.id, expense);
  }

  @override
  Future<void> deleteCachedExpense(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> clearCache(String userId) async {
    final keys = _box.keys.where((k) => _box.get(k)?.userId == userId).toList();
    await _box.deleteAll(keys);
  }
}
