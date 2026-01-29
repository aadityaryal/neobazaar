import 'package:neobazaar/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String username;
  final String? password;
  final String? campus;
  final String? location;
  final String? profilePicture;
  final int? neoTokens;
  final int? xp;
  final int? reputationScore;
  final bool? kycVerified;
  final List<String>? badges;

  AuthApiModel({
    this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.username,
    this.password,
    this.campus,
    this.location,
    this.profilePicture,
    this.neoTokens,
    this.xp,
    this.reputationScore,
    this.kycVerified,
    this.badges,
  });

  //toJSON
  Map<String, dynamic> toJson() {
    final nameParts = fullName.split(' ');
    return {
      "firstName": nameParts.first,
      "lastName": nameParts.length > 1 ? nameParts.last : '',
      "email": email,
      "username": username,
      "password": password,
      "confirmPassword": password,
      "campus": campus,
      "location": location,
    };
  }

  //fromJson
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    String asString(dynamic value) {
      if (value == null) {
        return '';
      }
      return value.toString();
    }

    String? asNullableString(dynamic value) {
      if (value == null) {
        return null;
      }
      final text = value.toString();
      return text.isEmpty ? null : text;
    }

    int? asNullableInt(dynamic value) {
      if (value == null) {
        return null;
      }
      return int.tryParse(value.toString());
    }

    bool? asNullableBool(dynamic value) {
      if (value == null) {
        return null;
      }
      if (value is bool) {
        return value;
      }
      final normalized = value.toString().toLowerCase();
      if (normalized == 'true') {
        return true;
      }
      if (normalized == 'false') {
        return false;
      }
      return null;
    }

    final fullName =
        asNullableString(json['name']) ??
        asNullableString(json['fullName']) ??
        [asNullableString(json['firstName']), asNullableString(json['lastName'])]
            .whereType<String>()
            .where((value) => value.trim().isNotEmpty)
            .join(' ')
            .trim();

    final email = asString(json['email']);
    final fallbackUsername = email.contains('@')
        ? email.split('@').first
        : 'user';

    final username =
        asNullableString(json['username']) ??
        asNullableString(json['userName']) ??
        fallbackUsername;

    return AuthApiModel(
      id: asNullableString(json['_id']) ??
          asNullableString(json['userId']) ??
          asNullableString(json['id']),
      fullName: fullName.isEmpty ? username : fullName,
      email: email,
      phoneNumber: asNullableString(json['phoneNumber']) ??
          asNullableString(json['phone']),
      username: username,
      campus: asNullableString(json['campus']),
      location: asNullableString(json['location']),
      profilePicture: asNullableString(json['profilePicture']) ??
          asNullableString(json['avatar']) ??
          asNullableString(json['image']),
        neoTokens: asNullableInt(json['neoTokens']) ??
          asNullableInt(json['tokenBalance']) ??
          asNullableInt(json['balance']),
        xp: asNullableInt(json['xp']),
        reputationScore: asNullableInt(json['reputationScore']),
        kycVerified: asNullableBool(json['kycVerified']),
        badges: (json['badges'] is List)
          ? (json['badges'] as List)
            .map((item) => item.toString())
            .toList(growable: false)
          : null,
    );
  }

  //toEntity
  AuthEntity toEntity() {
    return AuthEntity(
      authId: id,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      username: username,
      neoTokens: neoTokens,
      xp: xp,
      reputationScore: reputationScore,
      kycVerified: kycVerified,
      badges: badges,
      campus: campus,
      location: location,
      profilePicture: profilePicture,
    );
  }

  //fromEntity
  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      // id: entity.authId,
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      username: entity.username,
      campus: entity.campus,
      location: entity.location,
      profilePicture: entity.profilePicture,
      neoTokens: entity.neoTokens,
      xp: entity.xp,
      reputationScore: entity.reputationScore,
      kycVerified: entity.kycVerified,
      badges: entity.badges,
      password: entity.password,
    );
  }

  //toEntityList
  static List<AuthEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
