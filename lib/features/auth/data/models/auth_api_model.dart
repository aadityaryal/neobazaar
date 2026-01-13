import 'package:neobazaar/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String username;
  final String? password;
  final String? profilePicture;

  AuthApiModel({
    this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.username,
    this.password,
    this.profilePicture,
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
    };
  }

  //fromJson
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      id: json['_id'] as String,
      fullName: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      username: json['username'] as String,
      profilePicture: json['profilePicture'] as String?,
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
      profilePicture: entity.profilePicture,
      password: entity.password,
    );
  }

  //toEntityList
  static List<AuthEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
