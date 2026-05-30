import 'package:dartz/dartz.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_remote_datasource.dart';
import '../datasources/expense_local_datasource.dart';
import '../models/expense_model.dart';
import '../../../../core/errors/failures.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource _remote;
  final ExpenseLocalDataSource _local;

  ExpenseRepositoryImpl(this._remote, this._local);

  @override
  Stream<List<ExpenseEntity>> watchExpenses(String userId) {
    return _remote.watchExpenses(userId).map((list) => list.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<Failure, List<ExpenseEntity>>> getExpenses(String userId, {DateTime? from, DateTime? to, String? category}) async {
    try {
      final list = await _remote.getExpenses(userId, from: from, to: to, category: category);
      await _local.cacheExpenses(list);
      return Right(list.map((m) => m.toEntity()).toList());
    } catch (_) {
      try {
        final cached = await _local.getCachedExpenses(userId);
        return Right(cached.map((m) => m.toEntity()).toList());
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, ExpenseEntity>> addExpense(ExpenseEntity expense) async {
    try {
      final model = await _remote.addExpense(ExpenseModel.fromEntity(expense));
      await _local.addCachedExpense(model);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExpenseEntity>> updateExpense(ExpenseEntity expense) async {
    try {
      final model = await _remote.updateExpense(ExpenseModel.fromEntity(expense));
      await _local.updateCachedExpense(model);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExpense(String id, String userId) async {
    try {
      await _remote.deleteExpense(id, userId);
      await _local.deleteCachedExpense(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExpenseEntity>>> searchExpenses(String userId, String query) async {
    try {
      final list = await _remote.searchExpenses(userId, query);
      return Right(list.map((m) => m.toEntity()).toList());
    } catch (_) {
      try {
        final cached = await _local.getCachedExpenses(userId);
        final lower = query.toLowerCase();
        final filtered = cached.where((e) =>
          e.description.toLowerCase().contains(lower) ||
          e.category.toLowerCase().contains(lower) ||
          (e.note?.toLowerCase().contains(lower) ?? false)
        ).toList();
        return Right(filtered.map((m) => m.toEntity()).toList());
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getExpensesByCategory(String userId, DateTime from, DateTime to) async {
    try {
      final list = await _remote.getExpenses(userId, from: from, to: to);
      final map = <String, double>{};
      for (final e in list) { map[e.category] = (map[e.category] ?? 0) + e.amount; }
      return Right(map);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MapEntry<DateTime, double>>>> getMonthlyTotals(String userId, int monthsBack) async {
    try {
      final now = DateTime.now();
      final result = <MapEntry<DateTime, double>>[];
      for (int i = monthsBack - 1; i >= 0; i--) {
        final month = DateTime(now.year, now.month - i, 1);
        final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
        final list = await _remote.getExpenses(userId, from: month, to: end);
        final total = list.fold(0.0, (s, e) => s + e.amount);
        result.add(MapEntry(month, total));
      }
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalForPeriod(String userId, DateTime from, DateTime to) async {
    try {
      final list = await _remote.getExpenses(userId, from: from, to: to);
      return Right(list.fold(0.0, (s, e) => s + e.amount));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cacheExpenses(List<ExpenseEntity> expenses) async {
    try {
      await _local.cacheExpenses(expenses.map(ExpenseModel.fromEntity).toList());
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExpenseEntity>>> getCachedExpenses(String userId) async {
    try {
      final list = await _local.getCachedExpenses(userId);
      return Right(list.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
