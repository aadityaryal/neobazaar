import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/services/storage/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ====================== SHARED PREFERENCES PROVIDER ======================

/// Must be overridden in main.dart before runApp()
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

/// Must be overridden in main.dart before runApp()
final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('storageServiceProvider must be overridden');
});
