import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/expense_model.dart';
import '../../../../core/constants/app_constants.dart';

abstract class ExpenseRemoteDataSource {
  Stream<List<ExpenseModel>> watchExpenses(String userId);
  Future<List<ExpenseModel>> getExpenses(String userId, {DateTime? from, DateTime? to, String? category});
  Future<ExpenseModel> addExpense(ExpenseModel expense);
  Future<ExpenseModel> updateExpense(ExpenseModel expense);
  Future<void> deleteExpense(String id, String userId);
  Future<List<ExpenseModel>> searchExpenses(String userId, String query);
}

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  ExpenseRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(AppConstants.expensesCollection);

  @override
  Stream<List<ExpenseModel>> watchExpenses(String userId) {
    return _col
      .where('userId', isEqualTo: userId)
      .orderBy('date', descending: true)
      .limit(100)
      .snapshots()
      .map((s) => s.docs.map((d) => ExpenseModel.fromFirestore(d.data(), d.id)).toList());
  }

  @override
  Future<List<ExpenseModel>> getExpenses(String userId, {DateTime? from, DateTime? to, String? category}) async {
    Query<Map<String, dynamic>> q = _col.where('userId', isEqualTo: userId);
    if (from != null) q = q.where('date', isGreaterThanOrEqualTo: from.millisecondsSinceEpoch);
    if (to != null) q = q.where('date', isLessThanOrEqualTo: to.millisecondsSinceEpoch);
    if (category != null && category.isNotEmpty) q = q.where('category', isEqualTo: category);
    q = q.orderBy('date', descending: true);
    final snap = await q.get();
    return snap.docs.map((d) => ExpenseModel.fromFirestore(d.data(), d.id)).toList();
  }

  @override
  Future<ExpenseModel> addExpense(ExpenseModel expense) async {
    final id = _uuid.v4();
    final model = ExpenseModel(
      id: id, userId: expense.userId, amount: expense.amount,
      currency: expense.currency, category: expense.category,
      description: expense.description, date: expense.date,
      note: expense.note, tags: expense.tags, isRecurring: expense.isRecurring,
      recurringFrequency: expense.recurringFrequency, createdAt: DateTime.now(),
    );
    await _col.doc(id).set(model.toFirestore());
    return model;
  }

  @override
  Future<ExpenseModel> updateExpense(ExpenseModel expense) async {
    final updated = ExpenseModel(
      id: expense.id, userId: expense.userId, amount: expense.amount,
      currency: expense.currency, category: expense.category,
      description: expense.description, date: expense.date,
      note: expense.note, tags: expense.tags, isRecurring: expense.isRecurring,
      recurringFrequency: expense.recurringFrequency, createdAt: expense.createdAt,
      updatedAt: DateTime.now(),
    );
    await _col.doc(expense.id).update(updated.toFirestore());
    return updated;
  }

  @override
  Future<void> deleteExpense(String id, String userId) async {
    final doc = await _col.doc(id).get();
    if (doc.exists && doc.data()?['userId'] == userId) {
      await _col.doc(id).delete();
    }
  }

  @override
  Future<List<ExpenseModel>> searchExpenses(String userId, String query) async {
    final lower = query.toLowerCase();
    final snap = await _col.where('userId', isEqualTo: userId).orderBy('date', descending: true).get();
    return snap.docs
      .map((d) => ExpenseModel.fromFirestore(d.data(), d.id))
      .where((e) =>
        e.description.toLowerCase().contains(lower) ||
        e.category.toLowerCase().contains(lower) ||
        (e.note?.toLowerCase().contains(lower) ?? false) ||
        e.tags.any((t) => t.toLowerCase().contains(lower)))
      .toList();
  }
}
