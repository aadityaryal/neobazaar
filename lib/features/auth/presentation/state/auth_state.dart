import 'package:equatable/equatable.dart';
import 'package:neobazaar/features/auth/domain/entities/auth_entity.dart';
import 'package:neobazaar/features/auth/domain/entities/auth_session_entity.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  registered,
  loading,
  error,
}

enum VerificationStatus { initial, challengeRequested, verified, failed }

class AuthState extends Equatable {
  final AuthStatus status;
  final bool sessionChecked;
  final List<AuthSessionEntity> activeSessions;
  final VerificationStatus verificationStatus;
  final String? errorMessage;
  final String? verificationChallengeId;
  final String? verificationDevCode;
  final AuthEntity? authEntity;
  const AuthState({
    this.status = AuthStatus.initial,
    this.sessionChecked = false,
    this.activeSessions = const <AuthSessionEntity>[],
    this.verificationStatus = VerificationStatus.initial,
    this.errorMessage,
    this.verificationChallengeId,
    this.verificationDevCode,
    this.authEntity,
  });

  // copywith
  AuthState copyWith({
    AuthStatus? status,
    bool? sessionChecked,
    List<AuthSessionEntity>? activeSessions,
    VerificationStatus? verificationStatus,
    String? errorMessage,
    bool clearError = false,
    String? verificationChallengeId,
    String? verificationDevCode,
    bool clearVerificationChallenge = false,
    AuthEntity? authEntity,
  }) {
    return AuthState(
      status: status ?? this.status,
      sessionChecked: sessionChecked ?? this.sessionChecked,
      activeSessions: activeSessions ?? this.activeSessions,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      verificationChallengeId: clearVerificationChallenge
          ? null
          : (verificationChallengeId ?? this.verificationChallengeId),
      verificationDevCode: clearVerificationChallenge
          ? null
          : (verificationDevCode ?? this.verificationDevCode),
      authEntity: authEntity ?? this.authEntity,
    );
  }

  @override
  List<Object?> get props => [
    status,
    sessionChecked,
    activeSessions,
    verificationStatus,
    errorMessage,
    verificationChallengeId,
    verificationDevCode,
    authEntity,
  ];
}
