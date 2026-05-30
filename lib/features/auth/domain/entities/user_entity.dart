import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final bool emailVerified;
  final String preferredCurrency;
  final bool notificationsEnabled;
  final bool darkMode;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.phoneNumber,
    required this.emailVerified,
    this.preferredCurrency = 'USD',
    this.notificationsEnabled = true,
    this.darkMode = false,
    required this.createdAt,
    this.lastLoginAt,
  });

  UserEntity copyWith({
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    bool? emailVerified,
    String? preferredCurrency,
    bool? notificationsEnabled,
    bool? darkMode,
  }) => UserEntity(
    uid: uid,
    email: email,
    displayName: displayName ?? this.displayName,
    photoUrl: photoUrl ?? this.photoUrl,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    emailVerified: emailVerified ?? this.emailVerified,
    preferredCurrency: preferredCurrency ?? this.preferredCurrency,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    darkMode: darkMode ?? this.darkMode,
    createdAt: createdAt,
    lastLoginAt: lastLoginAt,
  );

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl, phoneNumber, emailVerified, preferredCurrency, notificationsEnabled, darkMode];
}
