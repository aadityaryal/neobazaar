import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/providers/shared_prefs_provider.dart';
import 'package:neobazaar/core/services/storage/storage_service.dart';

enum UiMode { buyer, seller }

class AppSettingsState {
  final ThemeMode themeMode;
  final Locale locale;
  final UiMode uiMode;
  final bool shakeToThemeEnabled;
  final bool tiltRefreshEnabled;

  const AppSettingsState({
    required this.themeMode,
    required this.locale,
    required this.uiMode,
    bool? shakeToThemeEnabled,
    bool? tiltRefreshEnabled,
    bool? motionGesturesEnabled,
  }) : shakeToThemeEnabled =
           shakeToThemeEnabled ?? motionGesturesEnabled ?? true,
       tiltRefreshEnabled = tiltRefreshEnabled ?? motionGesturesEnabled ?? true;

  bool get motionGesturesEnabled => shakeToThemeEnabled || tiltRefreshEnabled;

  AppSettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    UiMode? uiMode,
    bool? shakeToThemeEnabled,
    bool? tiltRefreshEnabled,
  }) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      uiMode: uiMode ?? this.uiMode,
      shakeToThemeEnabled: shakeToThemeEnabled ?? this.shakeToThemeEnabled,
      tiltRefreshEnabled: tiltRefreshEnabled ?? this.tiltRefreshEnabled,
    );
  }
}

final appSettingsProvider =
    NotifierProvider<AppSettingsNotifier, AppSettingsState>(
      AppSettingsNotifier.new,
    );

class AppSettingsNotifier extends Notifier<AppSettingsState> {
  static const String _themeModeKey = 'app_theme_mode';
  static const String _languageCodeKey = 'app_language_code';
  static const String _uiModeKey = 'app_ui_mode';
  static const String _motionGesturesEnabledKey = 'app_motion_gestures_enabled';
  static const String _shakeToThemeEnabledKey = 'app_shake_theme_enabled';
  static const String _tiltRefreshEnabledKey = 'app_tilt_refresh_enabled';

  StorageService? get _storageOrNull {
    try {
      return ref.read(storageServiceProvider);
    } catch (_) {
      return null;
    }
  }

  @override
  AppSettingsState build() {
    final storage = _storageOrNull;
    final storedTheme = storage?.getString(_themeModeKey) ?? 'system';
    final storedLanguageCode = storage?.getString(_languageCodeKey) ?? 'en';
    final storedUiMode = storage?.getString(_uiModeKey) ?? 'buyer';
    final storedMotionGestures =
        storage?.getBool(_motionGesturesEnabledKey) ?? true;
    final storedShakeToTheme =
        storage?.getBool(_shakeToThemeEnabledKey) ?? storedMotionGestures;
    final storedTiltRefresh =
        storage?.getBool(_tiltRefreshEnabledKey) ?? storedMotionGestures;

    return AppSettingsState(
      themeMode: _parseThemeMode(storedTheme),
      locale: Locale(storedLanguageCode),
      uiMode: _parseUiMode(storedUiMode),
      shakeToThemeEnabled: storedShakeToTheme,
      tiltRefreshEnabled: storedTiltRefresh,
    );
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    state = state.copyWith(themeMode: themeMode);
    await _storageOrNull?.setString(_themeModeKey, themeMode.name);
  }

  Future<void> setLanguageCode(String languageCode) async {
    state = state.copyWith(locale: Locale(languageCode));
    await _storageOrNull?.setString(_languageCodeKey, languageCode);
  }

  Future<void> setUiMode(UiMode uiMode) async {
    state = state.copyWith(uiMode: uiMode);
    await _storageOrNull?.setString(_uiModeKey, uiMode.name);
  }

  Future<void> resetUiMode() async {
    await setUiMode(UiMode.buyer);
  }

  Future<void> setMotionGesturesEnabled(bool enabled) async {
    state = state.copyWith(
      shakeToThemeEnabled: enabled,
      tiltRefreshEnabled: enabled,
    );
    await _storageOrNull?.setBool(_motionGesturesEnabledKey, enabled);
    await _storageOrNull?.setBool(_shakeToThemeEnabledKey, enabled);
    await _storageOrNull?.setBool(_tiltRefreshEnabledKey, enabled);
  }

  Future<void> setShakeToThemeEnabled(bool enabled) async {
    state = state.copyWith(shakeToThemeEnabled: enabled);
    await _storageOrNull?.setBool(_shakeToThemeEnabledKey, enabled);
  }

  Future<void> setTiltRefreshEnabled(bool enabled) async {
    state = state.copyWith(tiltRefreshEnabled: enabled);
    await _storageOrNull?.setBool(_tiltRefreshEnabledKey, enabled);
  }

  void hydrate({
    required String themeMode,
    required String languageCode,
    String? uiMode,
    bool? shakeToThemeEnabled,
    bool? tiltRefreshEnabled,
    bool? motionGesturesEnabled,
  }) {
    state = state.copyWith(
      themeMode: _parseThemeMode(themeMode),
      locale: Locale(languageCode),
      uiMode: uiMode == null ? state.uiMode : _parseUiMode(uiMode),
      shakeToThemeEnabled:
          shakeToThemeEnabled ??
          motionGesturesEnabled ??
          state.shakeToThemeEnabled,
      tiltRefreshEnabled:
          tiltRefreshEnabled ??
          motionGesturesEnabled ??
          state.tiltRefreshEnabled,
    );
  }

  ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  UiMode _parseUiMode(String value) {
    switch (value) {
      case 'seller':
        return UiMode.seller;
      default:
        return UiMode.buyer;
    }
  }
}
