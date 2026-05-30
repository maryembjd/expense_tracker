import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;
  Future<Either<Failure, UserEntity>> signIn({required String email, required String password});
  Future<Either<Failure, UserEntity>> signUp({required String email, required String password, required String displayName});
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, void>> sendEmailVerification();
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);
  Future<Either<Failure, UserEntity>> updateProfile({String? displayName, String? photoUrl, String? phoneNumber});
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Future<Either<Failure, void>> updateUserSettings({String? currency, bool? notifications, bool? darkMode});
  Future<Either<Failure, void>> deleteAccount();
  Future<Either<Failure, void>> reauthenticate({required String email, required String password});
  Future<Either<Failure, void>> updatePassword({required String currentPassword, required String newPassword});
}
