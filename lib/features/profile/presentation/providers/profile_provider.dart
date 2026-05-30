import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final themeProvider = StateProvider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.darkMode ?? false;
});

class ProfileState {
  final bool isLoading;
  final String? error;
  final String? success;
  const ProfileState({this.isLoading = false, this.error, this.success});
  ProfileState copyWith({bool? isLoading, String? error, String? success}) =>
    ProfileState(isLoading: isLoading ?? this.isLoading, error: error, success: success);
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final AuthRepository _repo;

  ProfileNotifier(this._repo) : super(const ProfileState());

  Future<bool> updateProfile({String? name, String? photoUrl, String? phone}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repo.updateProfile(displayName: name, photoUrl: photoUrl, phoneNumber: phone);
    return result.fold(
      (f) { state = state.copyWith(isLoading: false, error: f.message); return false; },
      (_) { state = state.copyWith(isLoading: false, success: 'Profile updated!'); return true; },
    );
  }

  Future<bool> updateSettings({String? currency, bool? notifications, bool? darkMode}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repo.updateUserSettings(currency: currency, notifications: notifications, darkMode: darkMode);
    return result.fold(
      (f) { state = state.copyWith(isLoading: false, error: f.message); return false; },
      (_) { state = state.copyWith(isLoading: false, success: 'Settings saved!'); return true; },
    );
  }

  Future<bool> updatePassword({required String current, required String next}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repo.updatePassword(currentPassword: current, newPassword: next);
    return result.fold(
      (f) { state = state.copyWith(isLoading: false, error: f.message); return false; },
      (_) { state = state.copyWith(isLoading: false, success: 'Password updated!'); return true; },
    );
  }

  void clearMessages() => state = state.copyWith(error: null, success: null);
}

final profileNotifierProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(ref.read(authRepositoryProvider));
});
