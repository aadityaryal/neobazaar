import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

class AnalyticsService {
  static const Set<String> _sensitiveKeys = {
    'password',
    'token',
    'authorization',
    'cookie',
    'set-cookie',
    'refresh_token',
    'access_token',
    'id_token',
    'secret',
    'otp',
    'code',
  };

  void track(String eventName, {Map<String, dynamic>? properties}) {
    if (kDebugMode) {
      final safe = _redactMap(properties ?? const <String, dynamic>{});
      debugPrint('[ANALYTICS] $eventName $safe');
    }
  }

  Map<String, dynamic> _redactMap(Map<String, dynamic> source) {
    final redacted = <String, dynamic>{};

    source.forEach((key, value) {
      final normalized = key.toLowerCase();
      if (_sensitiveKeys.contains(normalized)) {
        redacted[key] = '***REDACTED***';
        return;
      }

      redacted[key] = _redactValue(value);
    });

    return redacted;
  }

  dynamic _redactValue(dynamic value) {
    if (value is Map<String, dynamic>) {
      return _redactMap(value);
    }

    if (value is Map) {
      return _redactMap(
        value.map((key, item) => MapEntry(key.toString(), item)),
      );
    }

    if (value is List) {
      return value.map(_redactValue).toList(growable: false);
    }

    return value;
  }
}
