import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/services/analytics/analytics_service.dart';
import 'package:neobazaar/features/auth/domain/entities/auth_entity.dart';
import 'package:neobazaar/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:neobazaar/features/auth/presentation/state/profile_state.dart';
import 'package:neobazaar/features/auth/presentation/view_model/auth_view_model.dart';

final profileViewModelProvider =
    NotifierProvider<ProfileViewModel, ProfileState>(ProfileViewModel.new);

class ProfileViewModel extends Notifier<ProfileState> {
  late final UpdateProfileUsecase _updateProfileUsecase;
  late final AnalyticsService _analyticsService;

  @override
  ProfileState build() {
    _updateProfileUsecase = ref.read(updateProfileUsecaseProvider);
    _analyticsService = ref.read(analyticsServiceProvider);
    return const ProfileState();
  }

  void initialize(AuthEntity? user) {
    if (user == null) {
      return;
    }

    state = state.copyWith(
      fullName: user.fullName,
      username: user.username,
      email: user.email,
      phoneNumber: user.phoneNumber,
      location: user.location,
      original: user,
      saveStatus: ProfileSaveStatus.idle,
      errorMessage: null,
    );
  }

  void setFullName(String value) => state = state.copyWith(fullName: value);
  void setUsername(String value) => state = state.copyWith(username: value);
  void setPhoneNumber(String value) =>
      state = state.copyWith(phoneNumber: value);
  void setLocation(String value) => state = state.copyWith(location: value);

  Future<void> saveProfile() async {
    final original = state.original;
    if (original == null) {
      return;
    }

    final optimistic = AuthEntity(
      authId: original.authId,
      fullName: state.fullName,
      email: state.email,
      phoneNumber: state.phoneNumber,
      username: state.username,
      location: state.location,
      profilePicture: original.profilePicture,
      neoTokens: original.neoTokens,
      xp: original.xp,
      reputationScore: original.reputationScore,
      kycVerified: original.kycVerified,
      badges: original.badges,
    );

    state = state.copyWith(
      saveStatus: ProfileSaveStatus.saving,
      errorMessage: null,
    );
    ref.read(authViewModelProvider.notifier).syncProfile(optimistic);

    final result = await _updateProfileUsecase(optimistic);
    result.fold(
      (failure) {
        _analyticsService.track(
          'profile_edit_error',
          properties: {'message': failure.message},
        );
        ref.read(authViewModelProvider.notifier).syncProfile(original);
        state = state.copyWith(
          saveStatus: ProfileSaveStatus.error,
          errorMessage: failure.message,
          fullName: original.fullName,
          username: original.username,
          phoneNumber: original.phoneNumber,
          location: original.location,
        );
      },
      (updated) {
        _analyticsService.track(
          'profile_edit_success',
          properties: {'userId': updated.authId},
        );
        ref.read(authViewModelProvider.notifier).syncProfile(updated);
        state = state.copyWith(
          saveStatus: ProfileSaveStatus.success,
          errorMessage: null,
          original: updated,
          fullName: updated.fullName,
          username: updated.username,
          phoneNumber: updated.phoneNumber,
          location: updated.location,
        );
      },
    );
  }

  void reset() {
    state = const ProfileState();
  }

  void syncTokenBalance(int neoTokens) {
    final original = state.original;
    if (original == null) {
      return;
    }

    final updated = AuthEntity(
      authId: original.authId,
      fullName: original.fullName,
      email: original.email,
      phoneNumber: original.phoneNumber,
      username: original.username,
      password: original.password,
      neoTokens: neoTokens,
      xp: original.xp,
      reputationScore: original.reputationScore,
      kycVerified: original.kycVerified,
      badges: original.badges,
      campus: original.campus,
      location: original.location,
      profilePicture: original.profilePicture,
    );

    state = state.copyWith(original: updated);
  }

  void syncProgress({int? neoTokens, int? xp}) {
    final original = state.original;
    if (original == null) {
      return;
    }

    final updated = AuthEntity(
      authId: original.authId,
      fullName: original.fullName,
      email: original.email,
      phoneNumber: original.phoneNumber,
      username: original.username,
      password: original.password,
      neoTokens: neoTokens ?? original.neoTokens,
      xp: xp ?? original.xp,
      reputationScore: original.reputationScore,
      kycVerified: original.kycVerified,
      badges: original.badges,
      campus: original.campus,
      location: original.location,
      profilePicture: original.profilePicture,
    );

    state = state.copyWith(original: updated);
  }
}
