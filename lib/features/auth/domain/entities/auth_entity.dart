import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? authId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String username;
  final String? password;
  final int? neoTokens;
  final int? xp;
  final int? reputationScore;
  final bool? kycVerified;
  final List<String>? badges;
  final String? campus;
  final String? location;
  final String? profilePicture;

  const AuthEntity({
    this.authId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.username,
    this.password,
    this.neoTokens,
    this.xp,
    this.reputationScore,
    this.kycVerified,
    this.badges,
    this.campus,
    this.location,
    this.profilePicture,
  });

  @override
  List<Object?> get props => [
    authId,
    fullName,
    email,
    phoneNumber,
    username,
    password,
    neoTokens,
    xp,
    reputationScore,
    kycVerified,
    badges,
    campus,
    location,
    profilePicture,
  ];
}
