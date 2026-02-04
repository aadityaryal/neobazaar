import 'package:equatable/equatable.dart';
import 'package:neobazaar/features/auth/domain/entities/auth_entity.dart';

enum ProfileSaveStatus { idle, saving, success, error }

class ProfileState extends Equatable {
  final String fullName;
  final String username;
  final String email;
  final String? phoneNumber;
  final String? location;
  final ProfileSaveStatus saveStatus;
  final String? errorMessage;
  final AuthEntity? original;

  const ProfileState({
    this.fullName = '',
    this.username = '',
    this.email = '',
    this.phoneNumber,
    this.location,
    this.saveStatus = ProfileSaveStatus.idle,
    this.errorMessage,
    this.original,
  });

  ProfileState copyWith({
    String? fullName,
    String? username,
    String? email,
    String? phoneNumber,
    String? location,
    ProfileSaveStatus? saveStatus,
    String? errorMessage,
    AuthEntity? original,
  }) {
    return ProfileState(
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      location: location ?? this.location,
      saveStatus: saveStatus ?? this.saveStatus,
      errorMessage: errorMessage,
      original: original ?? this.original,
    );
  }

  @override
  List<Object?> get props => [
    fullName,
    username,
    email,
    phoneNumber,
    location,
    saveStatus,
    errorMessage,
    original,
  ];
}
