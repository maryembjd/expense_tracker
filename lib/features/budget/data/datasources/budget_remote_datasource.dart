import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/budget_model.dart';
import '../../../../core/constants/app_constants.dart';

abstract class BudgetRemoteDataSource {
  Future<BudgetModel?> getBudget(String userId, int month, int year);
  Future<BudgetModel> setBudget(BudgetModel budget);
  Future<void> deleteBudget(String id);
  Stream<BudgetModel?> watchBudget(String userId, int month, int year);
}

class BudgetRemoteDataSourceImpl implements BudgetRemoteDataSource {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  BudgetRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(AppConstants.budgetsCollection);

  String _docId(String userId, int month, int year) => '${userId}_${year}_${month.toString().padLeft(2, '0')}';

  @override
  Future<BudgetModel?> getBudget(String userId, int month, int year) async {
    final doc = await _col.doc(_docId(userId, month, year)).get();
    if (!doc.exists) return null;
    return BudgetModel.fromFirestore(doc.data()!, doc.id);
  }

  @override
  Future<BudgetModel> setBudget(BudgetModel budget) async {
    final docId = _docId(budget.userId, budget.month, budget.year);
    final model = BudgetModel(
      id: docId,
      userId: budget.userId,
      totalBudget: budget.totalBudget,
      currency: budget.currency,
      categoryBudgets: budget.categoryBudgets,
      month: budget.month,
      year: budget.year,
      createdAt: budget.createdAt,
      updatedAt: DateTime.now(),
    );
    await _col.doc(docId).set(model.toFirestore(), SetOptions(merge: true));
    return model;
  }

  @override
  Future<void> deleteBudget(String id) => _col.doc(id).delete();

  @override
  Stream<BudgetModel?> watchBudget(String userId, int month, int year) {
    return _col.doc(_docId(userId, month, year)).snapshots().map((snap) {
      if (!snap.exists) return null;
      return BudgetModel.fromFirestore(snap.data()!, snap.id);
    });
  }
}
