import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../../../../core/constants/app_constants.dart';

abstract class AuthRemoteDataSource {
  Stream<User?> get firebaseAuthState;
  Future<UserModel> signIn({required String email, required String password});
  Future<UserModel> signUp({required String email, required String password, required String displayName});
  Future<void> signOut();
  Future<void> sendEmailVerification();
  Future<void> sendPasswordResetEmail(String email);
  Future<UserModel> updateProfile({String? displayName, String? photoUrl, String? phoneNumber});
  Future<UserModel?> getCurrentUserFromFirestore();
  Future<void> updateUserSettings({String? currency, bool? notifications, bool? darkMode});
  Future<void> deleteAccount();
  Future<void> reauthenticate({required String email, required String password});
  Future<void> updatePassword({required String currentPassword, required String newPassword});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<User?> get firebaseAuthState => _auth.authStateChanges();

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(AppConstants.usersCollection);

  @override
  Future<UserModel> signIn({required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    await _users.doc(cred.user!.uid).update({'lastLoginAt': DateTime.now().millisecondsSinceEpoch});
    final doc = await _users.doc(cred.user!.uid).get();
    if (doc.exists) return UserModel.fromFirestore(doc.data()!, cred.user!.uid);
    return _createUserDoc(cred.user!);
  }

  @override
  Future<UserModel> signUp({required String email, required String password, required String displayName}) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await cred.user!.updateDisplayName(displayName);
    return _createUserDoc(cred.user!, displayName: displayName);
  }

  Future<UserModel> _createUserDoc(User user, {String? displayName}) async {
    final model = UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: displayName ?? user.displayName ?? 'User',
      photoUrl: user.photoURL,
      emailVerified: user.emailVerified,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
    await _users.doc(user.uid).set(model.toFirestore());
    return model;
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<UserModel> updateProfile({String? displayName, String? photoUrl, String? phoneNumber}) async {
    final user = _auth.currentUser!;
    if (displayName != null) await user.updateDisplayName(displayName);
    if (photoUrl != null) await user.updatePhotoURL(photoUrl);
    final updates = <String, dynamic>{};
    if (displayName != null) updates['displayName'] = displayName;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;
    if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
    if (updates.isNotEmpty) await _users.doc(user.uid).update(updates);
    final doc = await _users.doc(user.uid).get();
    return UserModel.fromFirestore(doc.data()!, user.uid);
  }

  @override
  Future<UserModel?> getCurrentUserFromFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _users.doc(user.uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc.data()!, user.uid);
  }

  @override
  Future<void> updateUserSettings({String? currency, bool? notifications, bool? darkMode}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final updates = <String, dynamic>{};
    if (currency != null) updates['preferredCurrency'] = currency;
    if (notifications != null) updates['notificationsEnabled'] = notifications;
    if (darkMode != null) updates['darkMode'] = darkMode;
    if (updates.isNotEmpty) await _users.doc(uid).update(updates);
  }

  @override
  Future<void> deleteAccount() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _users.doc(uid).delete();
      await _firestore.collection(AppConstants.expensesCollection)
        .where('userId', isEqualTo: uid).get()
        .then((s) { for (var d in s.docs) { d.reference.delete(); } });
      await _firestore.collection(AppConstants.budgetsCollection)
        .where('userId', isEqualTo: uid).get()
        .then((s) { for (var d in s.docs) { d.reference.delete(); } });
    }
    await _auth.currentUser?.delete();
  }

  @override
  Future<void> reauthenticate({required String email, required String password}) async {
    final cred = EmailAuthProvider.credential(email: email, password: password);
    await _auth.currentUser?.reauthenticateWithCredential(cred);
  }

  @override
  Future<void> updatePassword({required String currentPassword, required String newPassword}) async {
    await reauthenticate(email: _auth.currentUser!.email!, password: currentPassword);
    await _auth.currentUser?.updatePassword(newPassword);
  }
}
