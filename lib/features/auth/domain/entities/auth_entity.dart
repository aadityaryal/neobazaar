import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable{
  final String? userId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String username;
  final String? password;
  final int neoTokens;   // Default starting tokens
  final int xp;
  final int reputationScore;
  final bool kycVerified;
  final List<String> badges;
  final String? location;
  final String? profileImage;

  const AuthEntity({
    this.userId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.username,
    this.password,
    required this.neoTokens,
    required this.xp,
    required this.reputationScore,
    required this.kycVerified,
    required this.badges,
    this.location,
    this.profileImage
  });
  
  @override
  List<Object?> get props => [userId, fullName, email, phoneNumber, username, password, neoTokens, xp, reputationScore, kycVerified, badges, location, profileImage];
}