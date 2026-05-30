import 'package:hive/hive.dart';
import '../../domain/entities/expense_entity.dart';
import '../../../../core/constants/app_constants.dart';

part 'expense_model.g.dart';

@HiveType(typeId: AppConstants.expenseModelTypeId)
class ExpenseModel extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) final String userId;
  @HiveField(2) final double amount;
  @HiveField(3) final String currency;
  @HiveField(4) final String category;
  @HiveField(5) final String description;
  @HiveField(6) final DateTime date;
  @HiveField(7) final String? note;
  @HiveField(8) final List<String> tags;
  @HiveField(9) final bool isRecurring;
  @HiveField(10) final String? recurringFrequency;
  @HiveField(11) final DateTime createdAt;
  @HiveField(12) final DateTime? updatedAt;

  ExpenseModel({
    required this.id, required this.userId, required this.amount,
    required this.currency, required this.category, required this.description,
    required this.date, this.note, this.tags = const [],
    this.isRecurring = false, this.recurringFrequency,
    required this.createdAt, this.updatedAt,
  });

  factory ExpenseModel.fromEntity(ExpenseEntity e) => ExpenseModel(
    id: e.id, userId: e.userId, amount: e.amount, currency: e.currency,
    category: e.category, description: e.description, date: e.date,
    note: e.note, tags: e.tags, isRecurring: e.isRecurring,
    recurringFrequency: e.recurringFrequency, createdAt: e.createdAt, updatedAt: e.updatedAt,
  );

  factory ExpenseModel.fromFirestore(Map<String, dynamic> map, String id) => ExpenseModel(
    id: id,
    userId: map['userId'] ?? '',
    amount: (map['amount'] as num).toDouble(),
    currency: map['currency'] ?? 'USD',
    category: map['category'] ?? 'other',
    description: map['description'] ?? '',
    date: DateTime.fromMillisecondsSinceEpoch(map['date']),
    note: map['note'],
    tags: List<String>.from(map['tags'] ?? []),
    isRecurring: map['isRecurring'] ?? false,
    recurringFrequency: map['recurringFrequency'],
    createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch),
    updatedAt: map['updatedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt']) : null,
  );

  Map<String, dynamic> toFirestore() => {
    'userId': userId, 'amount': amount, 'currency': currency,
    'category': category, 'description': description,
    'date': date.millisecondsSinceEpoch,
    'note': note, 'tags': tags, 'isRecurring': isRecurring,
    'recurringFrequency': recurringFrequency,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'updatedAt': updatedAt?.millisecondsSinceEpoch,
  };

  ExpenseEntity toEntity() => ExpenseEntity(
    id: id, userId: userId, amount: amount, currency: currency,
    category: category, description: description, date: date,
    note: note, tags: tags, isRecurring: isRecurring,
    recurringFrequency: recurringFrequency, createdAt: createdAt, updatedAt: updatedAt,
  );
}
