import 'package:hive/hive.dart';
import '../../domain/entities/budget_entity.dart';
import '../../../../core/constants/app_constants.dart';

part 'budget_model.g.dart';

@HiveType(typeId: AppConstants.budgetModelTypeId)
class BudgetModel extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) final String userId;
  @HiveField(2) final double totalBudget;
  @HiveField(3) final String currency;
  @HiveField(4) final Map<String, double> categoryBudgets;
  @HiveField(5) final int month;
  @HiveField(6) final int year;
  @HiveField(7) final DateTime createdAt;
  @HiveField(8) final DateTime? updatedAt;

  BudgetModel({
    required this.id, required this.userId, required this.totalBudget,
    required this.currency, required this.categoryBudgets,
    required this.month, required this.year,
    required this.createdAt, this.updatedAt,
  });

  factory BudgetModel.fromEntity(BudgetEntity e) => BudgetModel(
    id: e.id, userId: e.userId, totalBudget: e.totalBudget,
    currency: e.currency, categoryBudgets: e.categoryBudgets,
    month: e.month, year: e.year,
    createdAt: e.createdAt, updatedAt: e.updatedAt,
  );

  factory BudgetModel.fromFirestore(Map<String, dynamic> map, String id) => BudgetModel(
    id: id,
    userId: map['userId'] ?? '',
    totalBudget: (map['totalBudget'] as num).toDouble(),
    currency: map['currency'] ?? 'USD',
    categoryBudgets: Map<String, double>.from(
      (map['categoryBudgets'] as Map<String, dynamic>? ?? {}).map((k, v) => MapEntry(k, (v as num).toDouble()))
    ),
    month: map['month'] ?? DateTime.now().month,
    year: map['year'] ?? DateTime.now().year,
    createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch),
    updatedAt: map['updatedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt']) : null,
  );

  Map<String, dynamic> toFirestore() => {
    'userId': userId, 'totalBudget': totalBudget, 'currency': currency,
    'categoryBudgets': categoryBudgets, 'month': month, 'year': year,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'updatedAt': updatedAt?.millisecondsSinceEpoch,
  };

  BudgetEntity toEntity() => BudgetEntity(
    id: id, userId: userId, totalBudget: totalBudget,
    currency: currency, categoryBudgets: categoryBudgets,
    month: month, year: year,
    createdAt: createdAt, updatedAt: updatedAt,
  );
}
