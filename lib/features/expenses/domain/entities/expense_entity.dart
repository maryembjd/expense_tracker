import 'package:equatable/equatable.dart';

class ExpenseEntity extends Equatable {
  final String id;
  final String userId;
  final double amount;
  final String currency;
  final String category;
  final String description;
  final DateTime date;
  final String? note;
  final List<String> tags;
  final bool isRecurring;
  final String? recurringFrequency;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ExpenseEntity({
    required this.id,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.category,
    required this.description,
    required this.date,
    this.note,
    this.tags = const [],
    this.isRecurring = false,
    this.recurringFrequency,
    required this.createdAt,
    this.updatedAt,
  });

  ExpenseEntity copyWith({
    double? amount,
    String? currency,
    String? category,
    String? description,
    DateTime? date,
    String? note,
    List<String>? tags,
    bool? isRecurring,
    String? recurringFrequency,
  }) => ExpenseEntity(
    id: id, userId: userId,
    amount: amount ?? this.amount,
    currency: currency ?? this.currency,
    category: category ?? this.category,
    description: description ?? this.description,
    date: date ?? this.date,
    note: note ?? this.note,
    tags: tags ?? this.tags,
    isRecurring: isRecurring ?? this.isRecurring,
    recurringFrequency: recurringFrequency ?? this.recurringFrequency,
    createdAt: createdAt,
    updatedAt: DateTime.now(),
  );

  @override
  List<Object?> get props => [id, userId, amount, currency, category, description, date];
}
