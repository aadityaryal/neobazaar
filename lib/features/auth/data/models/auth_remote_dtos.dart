import 'package:neobazaar/features/auth/data/models/auth_api_model.dart';
import 'package:neobazaar/features/auth/domain/entities/auth_session_entity.dart';

class RegisterRequestDto {
  final String fullName;
  final String email;
  final String username;
  final String password;
  final String? campus;
  final String? location;

  const RegisterRequestDto({
    required this.fullName,
    required this.email,
    required this.username,
    required this.password,
    this.campus,
    this.location,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      // Backend requires `name` for registration in current API contract.
      'name': fullName.trim(),
      'email': email,
      'password': password,
      'location': location,
    };
  }
}

class LoginRequestDto {
  final String email;
  final String password;

  const LoginRequestDto({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'email': email, 'password': password};
  }
}

class SessionRevokeRequestDto {
  final String sessionId;

  const SessionRevokeRequestDto({required this.sessionId});

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'sessionId': sessionId};
  }
}

class VerificationChallengeRequestDto {
  final String channel;
  final String target;

  const VerificationChallengeRequestDto({
    required this.channel,
    required this.target,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'channel': channel, 'target': target};
  }
}

class VerificationSubmitRequestDto {
  final String challengeId;
  final String code;

  const VerificationSubmitRequestDto({
    required this.challengeId,
    required this.code,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'challengeId': challengeId, 'code': code};
  }
}

class AuthMeResponseDto {
  final AuthApiModel user;

  const AuthMeResponseDto({required this.user});

  factory AuthMeResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthMeResponseDto(user: AuthApiModel.fromJson(json));
  }
}

class AuthLoginResponseDto {
  final AuthApiModel user;

  const AuthLoginResponseDto({required this.user});

  factory AuthLoginResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthLoginResponseDto(user: AuthApiModel.fromJson(json));
  }
}

class AuthRegisterResponseDto {
  final AuthApiModel user;

  const AuthRegisterResponseDto({required this.user});

  factory AuthRegisterResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthRegisterResponseDto(user: AuthApiModel.fromJson(json));
  }
}

class AuthLogoutResponseDto {
  final bool success;

  const AuthLogoutResponseDto({required this.success});

  factory AuthLogoutResponseDto.fromJson(Map<String, dynamic> json) {
    final value = json['success'];
    return AuthLogoutResponseDto(success: value is bool ? value : true);
  }
}

class AuthSessionDto {
  final String id;
  final String? ip;
  final String? userAgent;
  final bool current;
  final DateTime? createdAt;
  final DateTime? expiresAt;

  const AuthSessionDto({
    required this.id,
    this.ip,
    this.userAgent,
    required this.current,
    this.createdAt,
    this.expiresAt,
  });

  factory AuthSessionDto.fromJson(Map<String, dynamic> json) {
    return AuthSessionDto(
      id: (json['id'] ?? json['sessionId'] ?? json['_id'] ?? '').toString(),
      ip: json['ip']?.toString(),
      userAgent: (json['userAgent'] ?? json['deviceLabel'])?.toString(),
      current: json['current'] == true,
      createdAt: DateTime.tryParse(
        (json['createdAt'] ?? json['issuedAt'])?.toString() ?? '',
      ),
      expiresAt: DateTime.tryParse(json['expiresAt']?.toString() ?? ''),
    );
  }

  AuthSessionEntity toEntity() {
    return AuthSessionEntity(
      id: id,
      ip: ip,
      userAgent: userAgent,
      current: current,
      createdAt: createdAt,
      expiresAt: expiresAt,
    );
  }

  static List<AuthSessionEntity> toEntityList(List<AuthSessionDto> sessions) {
    return sessions.map((session) => session.toEntity()).toList();
  }
}
