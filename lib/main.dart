import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/app/app.dart';
import 'package:neobazaar/core/providers/shared_prefs_provider.dart';
import 'package:neobazaar/core/services/analytics/crash_reporting_service.dart';
import 'package:neobazaar/core/services/cache/image_cache_policy.dart';
import 'package:neobazaar/core/services/hive/hive_service.dart';
import 'package:neobazaar/core/services/storage/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureGlobalImageCache();
  final crashReporting = CrashReportingService.instance;

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    crashReporting.recordFatal(
      'flutter_framework_error',
      details.exception,
      details.stack ?? StackTrace.current,
      context: {
        'library': details.library,
        'context': details.context?.toDescription(),
      },
    );
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stackTrace) {
    crashReporting.recordFatal('platform_dispatcher_error', error, stackTrace);
    return true;
  };

  // use provider scope

  await HiveService().init();

  final sharedPrefs = await SharedPreferences.getInstance();

  runZonedGuarded(
    () {
      runApp(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPrefs),
            storageServiceProvider.overrideWithValue(
              StorageService(prefs: sharedPrefs),
            ),
          ],
          child: const MyApp(),
        ),
      );
    },
    (error, stackTrace) {
      crashReporting.recordFatal('zoned_guarded_uncaught', error, stackTrace);
    },
  );
}
