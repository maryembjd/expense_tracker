import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';

// Providers
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(authRemoteDataSourceProvider));
});

final authStateProvider = StreamProvider<UserEntity?>((ref) {
  return ref.read(authRepositoryProvider).authStateChanges;
});

final currentUserProvider = StateProvider<UserEntity?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(data: (u) => u, loading: () => null, error: (_, __) => null);
});

// Auth Notifier
class AuthState {
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const AuthState({this.isLoading = false, this.error, this.successMessage});
  AuthState copyWith({bool? isLoading, String? error, String? successMessage}) => AuthState(
    isLoading: isLoading ?? this.isLoading,
    error: error,
    successMessage: successMessage,
  );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthState());

  Future<bool> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repo.signIn(email: email, password: password);
    return result.fold(
      (failure) { state = state.copyWith(isLoading: false, error: failure.message); return false; },
      (_) { state = state.copyWith(isLoading: false); return true; },
    );
  }

  Future<bool> signUp({required String email, required String password, required String name}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repo.signUp(email: email, password: password, displayName: name);
    return result.fold(
      (failure) { state = state.copyWith(isLoading: false, error: failure.message); return false; },
      (_) { state = state.copyWith(isLoading: false, successMessage: 'Verification email sent.'); return true; },
    );
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await _repo.signOut();
    state = const AuthState();
  }

  Future<bool> sendPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repo.sendPasswordResetEmail(email);
    return result.fold(
      (failure) { state = state.copyWith(isLoading: false, error: failure.message); return false; },
      (_) { state = state.copyWith(isLoading: false, successMessage: 'Reset email sent!'); return true; },
    );
  }

  Future<bool> resendVerificationEmail() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repo.sendEmailVerification();
    return result.fold(
      (failure) { state = state.copyWith(isLoading: false, error: failure.message); return false; },
      (_) { state = state.copyWith(isLoading: false, successMessage: 'Verification email sent!'); return true; },
    );
  }

  void clearError() => state = state.copyWith(error: null);
  void clearMessage() => state = state.copyWith(successMessage: null);
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});
