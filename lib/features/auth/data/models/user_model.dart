import 'package:hive/hive.dart';
import '../../domain/entities/user_entity.dart';
import '../../../../core/constants/app_constants.dart';

part 'user_model.g.dart';

@HiveType(typeId: AppConstants.userModelTypeId)
class UserModel extends HiveObject {
  @HiveField(0) final String uid;
  @HiveField(1) final String email;
  @HiveField(2) final String displayName;
  @HiveField(3) final String? photoUrl;
  @HiveField(4) final String? phoneNumber;
  @HiveField(5) final bool emailVerified;
  @HiveField(6) final String preferredCurrency;
  @HiveField(7) final bool notificationsEnabled;
  @HiveField(8) final bool darkMode;
  @HiveField(9) final DateTime createdAt;
  @HiveField(10) final DateTime? lastLoginAt;

  UserModel({
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

  factory UserModel.fromEntity(UserEntity e) => UserModel(
    uid: e.uid, email: e.email, displayName: e.displayName,
    photoUrl: e.photoUrl, phoneNumber: e.phoneNumber,
    emailVerified: e.emailVerified, preferredCurrency: e.preferredCurrency,
    notificationsEnabled: e.notificationsEnabled, darkMode: e.darkMode,
    createdAt: e.createdAt, lastLoginAt: e.lastLoginAt,
  );

  factory UserModel.fromFirestore(Map<String, dynamic> map, String uid) => UserModel(
    uid: uid,
    email: map['email'] ?? '',
    displayName: map['displayName'] ?? '',
    photoUrl: map['photoUrl'],
    phoneNumber: map['phoneNumber'],
    emailVerified: map['emailVerified'] ?? false,
    preferredCurrency: map['preferredCurrency'] ?? 'USD',
    notificationsEnabled: map['notificationsEnabled'] ?? true,
    darkMode: map['darkMode'] ?? false,
    createdAt: map['createdAt'] != null
      ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
      : DateTime.now(),
    lastLoginAt: map['lastLoginAt'] != null
      ? DateTime.fromMillisecondsSinceEpoch(map['lastLoginAt'])
      : null,
  );

  Map<String, dynamic> toFirestore() => {
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'phoneNumber': phoneNumber,
    'emailVerified': emailVerified,
    'preferredCurrency': preferredCurrency,
    'notificationsEnabled': notificationsEnabled,
    'darkMode': darkMode,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'lastLoginAt': lastLoginAt?.millisecondsSinceEpoch,
  };

  UserEntity toEntity() => UserEntity(
    uid: uid, email: email, displayName: displayName,
    photoUrl: photoUrl, phoneNumber: phoneNumber,
    emailVerified: emailVerified, preferredCurrency: preferredCurrency,
    notificationsEnabled: notificationsEnabled, darkMode: darkMode,
    createdAt: createdAt, lastLoginAt: lastLoginAt,
  );
}
