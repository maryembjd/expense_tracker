import 'package:equatable/equatable.dart';

class BudgetEntity extends Equatable {
  final String id;
  final String userId;
  final double totalBudget;
  final String currency;
  final Map<String, double> categoryBudgets;
  final int month;
  final int year;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const BudgetEntity({
    required this.id,
    required this.userId,
    required this.totalBudget,
    required this.currency,
    this.categoryBudgets = const {},
    required this.month,
    required this.year,
    required this.createdAt,
    this.updatedAt,
  });

  String get periodKey => '$year-${month.toString().padLeft(2, '0')}';

  BudgetEntity copyWith({
    double? totalBudget,
    String? currency,
    Map<String, double>? categoryBudgets,
  }) => BudgetEntity(
    id: id, userId: userId,
    totalBudget: totalBudget ?? this.totalBudget,
    currency: currency ?? this.currency,
    categoryBudgets: categoryBudgets ?? this.categoryBudgets,
    month: month, year: year,
    createdAt: createdAt, updatedAt: DateTime.now(),
  );

  double get totalCategoryBudget => categoryBudgets.values.fold(0, (s, v) => s + v);

  @override
  List<Object?> get props => [id, userId, month, year];
}

class BudgetStatus {
  final BudgetEntity budget;
  final double spent;
  final double remaining;
  final double percentage;
  final Map<String, double> categorySpent;

  const BudgetStatus({
    required this.budget,
    required this.spent,
    required this.remaining,
    required this.percentage,
    required this.categorySpent,
  });

  bool get isWarning => percentage >= 0.80 && percentage < 1.0;
  bool get isOver => percentage >= 1.0;
  bool get isHealthy => percentage < 0.80;

  Map<String, double> get categoryPercentages => {
    for (var entry in budget.categoryBudgets.entries)
      entry.key: entry.value > 0 ? (categorySpent[entry.key] ?? 0) / entry.value : 0,
  };
}
