import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/app/theme/theme_data.dart';
import 'package:neobazaar/core/providers/app_event_bus_provider.dart';
import 'package:neobazaar/core/providers/app_session_provider.dart';
import 'package:neobazaar/core/providers/app_settings_provider.dart';
import 'package:neobazaar/core/providers/capability_cache_provider.dart';
import 'package:neobazaar/core/providers/device_sensor_provider.dart';
import 'package:neobazaar/core/services/storage/user_session_service.dart';
import 'package:neobazaar/core/services/sync/offline_queue_replay_worker.dart';
import 'package:neobazaar/core/state/app_event.dart';
import 'package:neobazaar/core/utils/snackbar_utils.dart';
import 'package:neobazaar/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:neobazaar/features/auth/presentation/state/login_form_state.dart';
import 'package:neobazaar/features/auth/presentation/state/register_form_state.dart';
import 'package:neobazaar/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:neobazaar/features/auth/presentation/view_model/profile_view_model.dart';
import 'package:neobazaar/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:neobazaar/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:neobazaar/features/splash/presentation/pages/splash_screen.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NeoBazaar',
      theme: appLightTheme(),
      darkTheme: appDarkTheme(),
      themeMode: settings.themeMode,
      locale: settings.locale,
      home: const _AppBootstrapGate(),
    );
  }
}

class _AppBootstrapGate extends ConsumerStatefulWidget {
  const _AppBootstrapGate();

  @override
  ConsumerState<_AppBootstrapGate> createState() => _AppBootstrapGateState();
}

class _AppBootstrapGateState extends ConsumerState<_AppBootstrapGate>
    with WidgetsBindingObserver {
  static const double _shakeThreshold = 22.0;
  static const Duration _shakeCooldown = Duration(seconds: 2);

  DateTime? _lastShakeAt;

  ThemeMode _nextThemeMode(AppSettingsState settings, BuildContext context) {
    if (settings.themeMode == ThemeMode.system) {
      final isDarkSystem =
          MediaQuery.platformBrightnessOf(context) == Brightness.dark;
      return isDarkSystem ? ThemeMode.light : ThemeMode.dark;
    }

    return settings.themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() {
      ref.read(appSessionProvider.notifier).bootstrapSession();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(offlineQueueReplayWorkerProvider).onAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(appSessionProvider);

    ref.listen<AsyncValue<DeviceSensorState>>(deviceSensorStateProvider, (
      previous,
      next,
    ) {
      next.whenData((state) {
        final snapshot = state.snapshot;
        if (state.status != DeviceSensorStatus.active || snapshot == null) {
          return;
        }

        final settings = ref.read(appSettingsProvider);
        if (!settings.shakeToThemeEnabled) {
          return;
        }

        final magnitude = snapshot.accelerometer.magnitude;
        if (magnitude < _shakeThreshold) {
          return;
        }

        final now = DateTime.now();
        if (_lastShakeAt != null &&
            now.difference(_lastShakeAt!) < _shakeCooldown) {
          return;
        }
        _lastShakeAt = now;

        final nextTheme = _nextThemeMode(settings, context);
        unawaited(
          ref.read(appSettingsProvider.notifier).setThemeMode(nextTheme),
        );

        if (!mounted) {
          return;
        }
        SnackbarUtils.showInfo(
          context,
          'Shake detected. Switched to ${nextTheme.name} mode.',
        );
      });
    });

    ref.listen<AppEvent?>(appEventBusProvider, (previous, next) {
      if (next == null || !mounted) {
        return;
      }

      switch (next.type) {
        case AppEventType.unauthorized:
          unawaited(ref.read(authViewModelProvider.notifier).resetState());
          ref.read(profileViewModelProvider.notifier).reset();
          ref.read(loginFormStateProvider.notifier).reset();
          ref.read(registerFormStateProvider.notifier).reset();
          SnackbarUtils.showError(
            context,
            'Session expired. Please log in again.',
          );
          break;
        case AppEventType.forbidden:
          SnackbarUtils.showError(context, next.message);
          break;
        case AppEventType.notFound:
          SnackbarUtils.showInfo(context, next.message);
          break;
        case AppEventType.conflict:
          SnackbarUtils.showInfo(context, next.message);
          break;
        case AppEventType.info:
          SnackbarUtils.showInfo(context, next.message);
          break;
        case AppEventType.warning:
          SnackbarUtils.showInfo(context, next.message);
          break;
        case AppEventType.error:
          SnackbarUtils.showError(context, next.message);
          break;
      }

      ref.read(appEventBusProvider.notifier).clear();
    });

    if (!session.sessionChecked) {
      return const SplashScreen();
    }

    if (session.isAuthenticated) {
      return _isCurrentUserAdmin()
          ? const AdminDashboardPage()
          : const DashboardScreen();
    }

    return const OnboardingScreen();
  }

  bool _isCurrentUserAdmin() {
    final token = ref.read(userSessionServiceProvider).getAuthToken();
    if (token != null && token.isNotEmpty) {
      try {
        final parts = token.split('.');
        if (parts.length < 2) {
          return _isAdminFromCapabilities();
        }

        final payload = utf8.decode(
          base64Url.decode(base64Url.normalize(parts[1])),
        );
        final decoded = jsonDecode(payload);
        if (decoded is! Map<String, dynamic>) {
          return _isAdminFromCapabilities();
        }

        final directRole = decoded['role']?.toString().toLowerCase();
        if (directRole == 'admin') {
          return true;
        }

        final nestedUser = decoded['user'];
        if (nestedUser is Map) {
          final nestedRole = nestedUser['role']?.toString().toLowerCase();
          if (nestedRole == 'admin') {
            return true;
          }
        }

        final roles = decoded['roles'];
        if (roles is List &&
            roles.any((item) => item?.toString().toLowerCase() == 'admin')) {
          return true;
        }

        return false;
      } catch (_) {
        return _isAdminFromCapabilities();
      }
    }

    return _isAdminFromCapabilities();
  }

  bool _isAdminFromCapabilities() {
    final cache = ref.read(capabilityCacheProvider);
    return cache.has('role:admin') ||
        cache.has('admin:access') ||
        cache.has('admin:all') ||
        cache.has('admin:*');
  }
}
