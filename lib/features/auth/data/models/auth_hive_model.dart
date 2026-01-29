import 'package:hive/hive.dart';
import 'package:neobazaar/core/constants/hive_table_constant.dart';
import 'package:neobazaar/features/auth/domain/entities/auth_entity.dart';
import 'package:uuid/uuid.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.authTypeId)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String? authId;
  @HiveField(1)
  final String fullName;
  @HiveField(2)
  final String email;
  @HiveField(3)
  final String? phoneNumber;
  @HiveField(4)
  final String username;
  @HiveField(5)
  final String? password;
  @HiveField(6)
  final int neoTokens; // Default starting tokens
  @HiveField(7)
  final int xp;
  @HiveField(8)
  final int reputationScore;
  @HiveField(9)
  final bool kycVerified;
  @HiveField(10)
  final List<String> badges;
  @HiveField(11)
  final String? location;
  @HiveField(12)
  final String? profilePicture;

  AuthHiveModel({
    String? authId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.username,
    required this.password,
    int? neoTokens,
    int? xp,
    int? reputationScore,
    bool? kycVerified,
    List<String>? badges,
    this.location,
    this.profilePicture,
  }) : authId = authId ?? const Uuid().v4(),
       neoTokens = neoTokens ?? 0,
       xp = xp ?? 0,
       reputationScore = reputationScore ?? 0,
       kycVerified = kycVerified ?? false,
       badges = badges ?? [];

  // from Entity
  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      authId: entity.authId,
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      username: entity.username,
      password: entity.password,
      neoTokens: entity.neoTokens,
      xp: entity.xp,
      reputationScore: entity.reputationScore,
      kycVerified: entity.kycVerified,
      badges: entity.badges,
      location: entity.location,
      profilePicture: entity.profilePicture,
    );
  }

  // To Entity
  AuthEntity toEntity() {
    return AuthEntity(
      authId: authId,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      username: username,
      password: password,
      neoTokens: neoTokens,
      xp: xp,
      reputationScore: reputationScore,
      kycVerified: kycVerified,
      badges: badges,
      location: location,
      profilePicture: profilePicture,
    );
  }

  // To Entity List
  static List<AuthEntity> toEntityList(List<AuthHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
