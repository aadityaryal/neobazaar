import 'package:hive/hive.dart';
import 'package:neobazaar/core/constants/hive_table_constant.dart';
import 'package:neobazaar/features/auth/domain/entities/auth_entity.dart';
import 'package:uuid/uuid.dart';


  // final String? userId;
  // final String fullName;
  // final String email;
  // final String? phoneNumber;
  // final String username;
  // final String? password;
  // final int neoTokens;   // Default starting tokens
  // final int xp;
  // final int reputationScore;
  // final bool kycVerified;
  // final List<String> badges;
  // final String? location;
  // final String? profileImage;


part 'auth_hive_model.g.dart';

@HiveType(typeId:HiveTableConstant.userTypeId)
class AuthHiveModel extends HiveObject {

  @HiveField(0)
  final String? userId;
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
  final int neoTokens;   // Default starting tokens
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
  final String? profileImage;

  AuthHiveModel({
    String? userId, required this.fullName, required this.email, required this.phoneNumber, required this.username, required this.password, int? neoTokens, int? xp, int? reputationScore, bool? kycVerified, List<String>? badges, required this.location, required this.profileImage
  }) : userId = userId ?? Uuid().v4(),
        neoTokens = neoTokens ?? 0,
        xp = xp ?? 0,
        reputationScore = reputationScore ?? 0,
        kycVerified = kycVerified ?? false,
        badges = badges ?? [];

  
  // from Entity 
  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      userId: entity.userId,
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
      profileImage: entity.profileImage
    );
  } 

  // To Entity
  AuthEntity toEntity() {
    return AuthEntity(
      userId: userId,
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
      profileImage: profileImage
    );
  }

  // To Entity List
  static List<AuthEntity> toEntityList(List<AuthHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }


  

  
  
}