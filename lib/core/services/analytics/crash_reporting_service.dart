import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final crashReportingServiceProvider = Provider<CrashReportingService>((ref) {
  return CrashReportingService.instance;
});

class CrashReportingService {
  CrashReportingService._();

  static final CrashReportingService instance = CrashReportingService._();

  void recordFatal(
    String reason,
    Object error,
    StackTrace stackTrace, {
    Map<String, dynamic>? context,
  }) {
    _record(
      kind: 'fatal',
      reason: reason,
      error: error,
      stackTrace: stackTrace,
      context: context,
    );
  }

  void recordNonFatal(
    String reason,
    Object error,
    StackTrace stackTrace, {
    Map<String, dynamic>? context,
  }) {
    _record(
      kind: 'non_fatal',
      reason: reason,
      error: error,
      stackTrace: stackTrace,
      context: context,
    );
  }

  void _record({
    required String kind,
    required String reason,
    required Object error,
    required StackTrace stackTrace,
    Map<String, dynamic>? context,
  }) {
    if (kDebugMode) {
      debugPrint(
        '[CRASH][$kind] $reason error=$error context=${context ?? const {}}',
      );
      debugPrint(stackTrace.toString());
    }
  }
}
