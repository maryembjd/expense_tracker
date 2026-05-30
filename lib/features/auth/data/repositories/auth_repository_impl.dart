import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../../../core/errors/failures.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;

  AuthRepositoryImpl(this._remote);

  @override
  Stream<UserEntity?> get authStateChanges => _remote.firebaseAuthState.asyncMap((user) async {
    if (user == null) return null;
    try {
      final model = await _remote.getCurrentUserFromFirestore();
      return model?.toEntity();
    } catch (_) { return null; }
  });

  @override
  Future<Either<Failure, UserEntity>> signIn({required String email, required String password}) async {
    try {
      final model = await _remote.signIn(email: email, password: password);
      return Right(model.toEntity());
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseError(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUp({required String email, required String password, required String displayName}) async {
    try {
      final model = await _remote.signUp(email: email, password: password, displayName: displayName);
      await _remote.sendEmailVerification();
      return Right(model.toEntity());
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseError(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remote.signOut();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    try {
      await _remote.sendEmailVerification();
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseError(e)));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await _remote.sendPasswordResetEmail(email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseError(e)));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({String? displayName, String? photoUrl, String? phoneNumber}) async {
    try {
      final model = await _remote.updateProfile(displayName: displayName, photoUrl: photoUrl, phoneNumber: phoneNumber);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final model = await _remote.getCurrentUserFromFirestore();
      return Right(model?.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserSettings({String? currency, bool? notifications, bool? darkMode}) async {
    try {
      await _remote.updateUserSettings(currency: currency, notifications: notifications, darkMode: darkMode);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await _remote.deleteAccount();
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseError(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> reauthenticate({required String email, required String password}) async {
    try {
      await _remote.reauthenticate(email: email, password: password);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseError(e)));
    }
  }

  @override
  Future<Either<Failure, void>> updatePassword({required String currentPassword, required String newPassword}) async {
    try {
      await _remote.updatePassword(currentPassword: currentPassword, newPassword: newPassword);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseError(e)));
    }
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found': return 'No account found with this email.';
      case 'wrong-password': return 'Incorrect password. Please try again.';
      case 'email-already-in-use': return 'An account already exists with this email.';
      case 'weak-password': return 'Password is too weak. Use at least 8 characters.';
      case 'invalid-email': return 'Please enter a valid email address.';
      case 'user-disabled': return 'This account has been disabled.';
      case 'too-many-requests': return 'Too many attempts. Please try again later.';
      case 'network-request-failed': return 'Network error. Check your connection.';
      case 'requires-recent-login': return 'Please sign in again to continue.';
      case 'invalid-credential': return 'Invalid email or password.';
      default: return e.message ?? 'Authentication failed.';
    }
  }
}
