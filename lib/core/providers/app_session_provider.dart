import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/providers/app_settings_provider.dart';
import 'package:neobazaar/core/usecases/app_bootstrap_usecase.dart';
import 'package:neobazaar/features/auth/domain/entities/auth_entity.dart';

class AppSessionState {
  final bool sessionChecked;
  final bool isAuthenticated;
  final AuthEntity? user;
  final String? errorMessage;

  const AppSessionState({
    this.sessionChecked = false,
    this.isAuthenticated = false,
    this.user,
    this.errorMessage,
  });

  AppSessionState copyWith({
    bool? sessionChecked,
    bool? isAuthenticated,
    AuthEntity? user,
    String? errorMessage,
  }) {
    return AppSessionState(
      sessionChecked: sessionChecked ?? this.sessionChecked,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final appSessionProvider =
    NotifierProvider<AppSessionNotifier, AppSessionState>(
      AppSessionNotifier.new,
    );

class AppSessionNotifier extends Notifier<AppSessionState> {
  AppBootstrapUsecase get _appBootstrapUsecase =>
      ref.read(appBootstrapUsecaseProvider);

  @override
  AppSessionState build() {
    return const AppSessionState();
  }

  Future<void> bootstrapSession() async {
    final bootstrapData = await _appBootstrapUsecase();

    ref
        .read(appSettingsProvider.notifier)
        .hydrate(
          themeMode: bootstrapData.themeMode,
          languageCode: bootstrapData.languageCode,
          uiMode: bootstrapData.uiMode,
        );

    state = state.copyWith(
      sessionChecked: bootstrapData.sessionChecked,
      isAuthenticated: bootstrapData.isAuthenticated,
      user: bootstrapData.user,
      errorMessage: bootstrapData.errorMessage,
    );
  }

  void clearSession() {
    state = const AppSessionState(sessionChecked: true, isAuthenticated: false);
  }

  void syncUser(AuthEntity user) {
    state = state.copyWith(user: user);
  }

  void setAuthenticated(AuthEntity user) {
    state = state.copyWith(
      sessionChecked: true,
      isAuthenticated: true,
      user: user,
      errorMessage: null,
    );
  }
}
