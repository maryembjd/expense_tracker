import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/expense_entity.dart';

abstract class ExpenseRepository {
  Stream<List<ExpenseEntity>> watchExpenses(String userId);
  Future<Either<Failure, List<ExpenseEntity>>> getExpenses(String userId, {DateTime? from, DateTime? to, String? category});
  Future<Either<Failure, ExpenseEntity>> addExpense(ExpenseEntity expense);
  Future<Either<Failure, ExpenseEntity>> updateExpense(ExpenseEntity expense);
  Future<Either<Failure, void>> deleteExpense(String id, String userId);
  Future<Either<Failure, List<ExpenseEntity>>> searchExpenses(String userId, String query);
  Future<Either<Failure, Map<String, double>>> getExpensesByCategory(String userId, DateTime from, DateTime to);
  Future<Either<Failure, List<MapEntry<DateTime, double>>>> getMonthlyTotals(String userId, int monthsBack);
  Future<Either<Failure, double>> getTotalForPeriod(String userId, DateTime from, DateTime to);
  Future<Either<Failure, void>> cacheExpenses(List<ExpenseEntity> expenses);
  Future<Either<Failure, List<ExpenseEntity>>> getCachedExpenses(String userId);
}
