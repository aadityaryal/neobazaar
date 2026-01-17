import 'package:equatable/equatable.dart';

class AuthSessionEntity extends Equatable {
  final String id;
  final String? ip;
  final String? userAgent;
  final bool current;
  final DateTime? createdAt;
  final DateTime? expiresAt;

  const AuthSessionEntity({
    required this.id,
    this.ip,
    this.userAgent,
    this.current = false,
    this.createdAt,
    this.expiresAt,
  });

  @override
  List<Object?> get props => <Object?>[
    id,
    ip,
    userAgent,
    current,
    createdAt,
    expiresAt,
  ];
}
