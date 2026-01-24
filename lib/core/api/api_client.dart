import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/api/api_endpoints.dart';
import 'package:neobazaar/core/constants/app_constants.dart';
import 'package:neobazaar/core/error/exceptions.dart';
import 'package:neobazaar/core/providers/app_event_bus_provider.dart';
import 'package:neobazaar/core/providers/app_session_provider.dart';
import 'package:neobazaar/core/providers/capability_cache_provider.dart';
import 'package:neobazaar/core/providers/feature_circuit_breaker_provider.dart';
import 'package:neobazaar/core/providers/global_error_banner_provider.dart';
import 'package:neobazaar/core/services/analytics/crash_reporting_service.dart';
import 'package:neobazaar/core/services/storage/user_session_service.dart';
import 'package:neobazaar/core/state/app_event.dart';
import 'package:uuid/uuid.dart';

// Provider for ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref);
});

class ApiClient {
  final Ref _ref;
  late final Dio _dio;
  final Uuid _uuid = const Uuid();

  static const Duration _defaultTimeout = Duration(seconds: 30);
  static const Duration _uploadTimeout = Duration(seconds: 60);
  static const Duration _chatTimeout = Duration(seconds: 20);
  static const Duration _exportTimeout = Duration(seconds: 90);

  ApiClient(this._ref) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: ApiEndpoints.connectionTimeout,
        receiveTimeout: ApiEndpoints.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(_AuthHeaderInterceptor(_ref));
    _dio.interceptors.add(RequestMetadataInterceptor(_uuid));

    // Auto retry on network failures
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
        retryEvaluator: (error, attempt) {
          final canRetryByTransport =
              error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.sendTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.connectionError ||
              _isPrematureConnectionClose(error);

          if (!canRetryByTransport) {
            return false;
          }

          final maxRetries = _maxRetriesFor(error.requestOptions);
          return attempt <= maxRetries;
        },
      ),
    );

    _dio.interceptors.add(_HttpStrategyInterceptor(_ref));

    // Only add sanitized logger in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(_RedactingLogInterceptor());
    }
  }

  Dio get dio => _dio;

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get(
      path,
      queryParameters: queryParameters,
      options: _withTimeouts(path, options),
    );
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: _withTimeouts(path, options),
    );
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: _withTimeouts(path, options),
    );
  }

  // PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: _withTimeouts(path, options),
    );
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: _withTimeouts(path, options),
    );
  }

  // Multipart request for file uploads
  Future<Response> uploadFile(
    String path, {
    required FormData formData,
    Options? options,
    ProgressCallback? onSendProgress,
  }) async {
    return _dio.post(
      path,
      data: formData,
      options: _withTimeouts(path, options, isUpload: true),
      onSendProgress: onSendProgress,
    );
  }

  Options _withTimeouts(
    String path,
    Options? options, {
    bool isUpload = false,
  }) {
    final normalized = path.toLowerCase();
    final timeout = _resolveTimeout(normalized, isUpload: isUpload);

    final merged = (options ?? Options()).copyWith(
      sendTimeout: timeout,
      receiveTimeout: timeout,
    );

    return merged;
  }

  Duration _resolveTimeout(String path, {required bool isUpload}) {
    if (isUpload ||
        path.contains(ApiEndpoints.products) ||
        path.contains(ApiEndpoints.detect)) {
      return _uploadTimeout;
    }

    if (path.contains(ApiEndpoints.chats) ||
        path.contains(ApiEndpoints.nlpSuggest)) {
      return _chatTimeout;
    }

    if (path.contains(ApiEndpoints.adminExport)) {
      return _exportTimeout;
    }

    return _defaultTimeout;
  }

  int _maxRetriesFor(RequestOptions requestOptions) {
    final method = requestOptions.method.toUpperCase();
    final path = requestOptions.path.toLowerCase();

    // Admin routes can be heavy and noisy under transport failures; avoid retry storms.
    if (path.contains('/admin/')) {
      return 0;
    }

    final isSafeMethod =
        method == 'GET' || method == 'HEAD' || method == 'OPTIONS';
    if (isSafeMethod) {
      if (path.contains(ApiEndpoints.chats)) {
        return 1;
      }
      if (path.contains(ApiEndpoints.adminExport)) {
        return 1;
      }
      return 3;
    }

    final hasIdempotencyKey =
        requestOptions.headers[AppConstants.headerIdempotencyKey] != null;
    final isExplicitWriteRetryEndpoint =
        path.contains(ApiEndpoints.authLogin) ||
        path.contains(ApiEndpoints.authRegister) ||
        path.contains(ApiEndpoints.authLogout) ||
        path.contains(ApiEndpoints.authSessionsRevoke) ||
        path.contains(ApiEndpoints.authSessionsRevokeAll);

    if (hasIdempotencyKey && isExplicitWriteRetryEndpoint) {
      return 1;
    }

    return 0;
  }

  bool _isPrematureConnectionClose(DioException error) {
    if (error.type != DioExceptionType.unknown) {
      return false;
    }

    final text =
        '${error.message ?? ''} ${error.error?.toString() ?? ''}'
            .toLowerCase();

    return text.contains('connection closed before full header') ||
        text.contains('connection reset by peer') ||
        text.contains('connection terminated');
  }

  T parseDataEnvelope<T>(Response response, T Function(dynamic data) mapper) {
    final dynamic body = response.data;
    if (body is! Map<String, dynamic>) {
      throw const UnexpectedResponseException();
    }

    if (body['success'] == false) {
      final errors = body['errors'];
      if (errors is List && errors.isNotEmpty && errors.first is Map) {
        final first = errors.first as Map;
        throw ApiException(
          message: (first['detail'] ?? body['message'] ?? 'Request failed')
              .toString(),
          statusCode: response.statusCode,
        );
      }
      throw ApiException(
        message: (body['message'] ?? 'Request failed').toString(),
        statusCode: response.statusCode,
      );
    }

    return mapper(body['data']);
  }
}

class _AuthHeaderInterceptor extends Interceptor {
  final Ref _ref;
  static const bool _showFullAuthTokenInLogs = bool.fromEnvironment(
    'NB_SHOW_FULL_AUTH_TOKEN_IN_LOGS',
    defaultValue: false,
  );

  _AuthHeaderInterceptor(this._ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _ref.read(userSessionServiceProvider).getAuthToken();
    final tokenPreview = _tokenPreview(token);

    debugPrint(
      '[TOKEN_READ] Token read from auth_token: ${token == null || token.isEmpty ? 'NO' : 'YES'} ($tokenPreview)',
    );
    debugPrint(
      '[AUTH_INTERCEPTOR] Token read: ${token == null || token.isEmpty ? 'NO' : 'YES'} ($tokenPreview) for ${options.path}',
    );
    debugPrint(
      '[AUTH_INTERCEPTOR] Headers before: ${_safeHeaders(options.headers)}',
    );

    if (token != null && token.isNotEmpty) {
      options.headers.putIfAbsent('Authorization', () => 'Bearer $token');
      debugPrint(
        '[AUTH_INTERCEPTOR] Authorization header added for ${options.path}',
      );
    } else {
      debugPrint(
        '[AUTH_INTERCEPTOR] Authorization header skipped for ${options.path}',
      );
    }

    debugPrint('[AUTH_INTERCEPTOR] Headers after: ${_safeHeaders(options.headers)}');
    handler.next(options);
  }

  String _tokenPreview(String? token) {
    if (token == null || token.isEmpty) {
      return 'none';
    }
    if (_showFullAuthTokenInLogs) {
      return token;
    }
    final end = token.length >= 18 ? 18 : token.length;
    return '${token.substring(0, end)}...';
  }

  Map<String, dynamic> _safeHeaders(Map<String, dynamic> headers) {
    final safe = <String, dynamic>{};
    headers.forEach((key, value) {
      final normalized = key.toLowerCase();
      if (normalized == 'authorization') {
        final raw = value?.toString() ?? '';
        if (_showFullAuthTokenInLogs) {
          safe[key] = raw;
        } else {
          final token = raw.startsWith('Bearer ') ? raw.substring(7) : raw;
          safe[key] = token.isEmpty ? 'Bearer <empty>' : 'Bearer ${_tokenPreview(token)}';
        }
      } else {
        safe[key] = value;
      }
    });
    return safe;
  }
}

class RequestMetadataInterceptor extends Interceptor {
  final Uuid _uuid;

  RequestMetadataInterceptor(this._uuid);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.putIfAbsent(AppConstants.headerRequestId, () => _uuid.v4());

    final method = options.method.toUpperCase();
    final isWriteMethod =
        method == 'POST' ||
        method == 'PUT' ||
        method == 'PATCH' ||
        method == 'DELETE';

    if (isWriteMethod) {
      options.headers.putIfAbsent(
        AppConstants.headerIdempotencyKey,
        () => _uuid.v4(),
      );
    }

    handler.next(options);
  }
}

class _HttpStrategyInterceptor extends Interceptor {
  final Ref _ref;

  _HttpStrategyInterceptor(this._ref);

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final feature = _featureKey(response.requestOptions.path.toLowerCase());
    _ref.read(featureCircuitBreakerProvider.notifier).recordSuccess(feature);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;
    final body = err.response?.data;
    final path = err.requestOptions.path.toLowerCase();
    final feature = _featureKey(path);
    final featureLabel = _featureLabel(path);
    final message =
        _extractDetailMessage(body) ??
      _extractTransportMessage(err) ??
        err.message ??
        'Request failed. Please try again.';

    _ref
        .read(crashReportingServiceProvider)
        .recordNonFatal(
          'api_request_error',
          err,
          err.stackTrace,
          context: {
            'path': path,
            'status_code': statusCode,
            'feature': feature,
            'type': err.type.name,
          },
        );

    if (_isTimeoutError(err)) {
      final breaker = _ref.read(featureCircuitBreakerProvider.notifier);
      breaker.recordFailure(feature);
      final isOpen = breaker.isOpen(feature);
      final fallback = isOpen
          ? '$featureLabel is temporarily unavailable due to repeated timeouts. Please try again shortly.'
          : '$featureLabel is taking longer than expected. Please retry in a moment.';
      _ref.read(globalErrorBannerProvider.notifier).show(fallback);
      _ref
          .read(appEventBusProvider.notifier)
          .publish(type: AppEventType.warning, message: fallback);
    } else if (_isTransportError(err)) {
      final breaker = _ref.read(featureCircuitBreakerProvider.notifier);
      breaker.recordFailure(feature);
      final isOpen = breaker.isOpen(feature);
      final retryMessage = isOpen
          ? '$featureLabel is temporarily paused after repeated network failures. Please retry after a short delay.'
          : 'Network issue while loading $featureLabel. Check connection and retry.';
      _ref.read(globalErrorBannerProvider.notifier).show(retryMessage);
      _ref
          .read(appEventBusProvider.notifier)
          .publish(type: AppEventType.error, message: retryMessage);
    } else if (statusCode == 401) {
      final suppressUnauthorizedLogout =
          err.requestOptions.extra['suppressUnauthorizedLogout'] == true;
      if (!suppressUnauthorizedLogout &&
          _shouldForceSessionClearOnUnauthorized(err, message)) {
        _ref.read(appSessionProvider.notifier).clearSession();
        _ref.read(capabilityCacheProvider.notifier).clear();
        _ref.read(globalErrorBannerProvider.notifier).clear();
        _ref
            .read(appEventBusProvider.notifier)
            .publish(type: AppEventType.unauthorized, message: message);
      } else if (!suppressUnauthorizedLogout) {
        _ref
            .read(appEventBusProvider.notifier)
            .publish(type: AppEventType.warning, message: message);
      }
    } else if (statusCode == 403) {
      _ref.read(globalErrorBannerProvider.notifier).show(message);
      _ref
          .read(appEventBusProvider.notifier)
          .publish(type: AppEventType.forbidden, message: message);
    } else if (statusCode == 404) {
      _ref
          .read(appEventBusProvider.notifier)
          .publish(type: AppEventType.notFound, message: message);
    } else if (statusCode == 409) {
      _ref
          .read(appEventBusProvider.notifier)
          .publish(type: AppEventType.conflict, message: message);
    }

    handler.next(err);
  }

  bool _isTimeoutError(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout;
  }

  bool _isTransportError(DioException error) {
    if (error.type == DioExceptionType.connectionError) {
      return true;
    }

    if (error.type == DioExceptionType.unknown) {
      final text =
          '${error.message ?? ''} ${error.error?.toString() ?? ''}'
              .toLowerCase();
      return text.contains('connection closed before full header') ||
          text.contains('connection reset by peer') ||
          text.contains('connection terminated');
    }

    return false;
  }

  String? _extractTransportMessage(DioException error) {
    if (!_isTransportError(error)) {
      return null;
    }

    return 'Network connection was interrupted. Please retry.';
  }

  String _featureLabel(String path) {
    String rootOf(String endpoint) {
      final normalized = endpoint.startsWith('/')
          ? endpoint.substring(1)
          : endpoint;
      final first = normalized.split('/').first;
      return '/$first';
    }

    final mappings = <MapEntry<String, String>>[
      MapEntry(rootOf(ApiEndpoints.authLogin), 'authentication'),
      MapEntry(rootOf(ApiEndpoints.products), 'product discovery'),
      MapEntry(rootOf(ApiEndpoints.transactions), 'transactions'),
      MapEntry(rootOf(ApiEndpoints.bids), 'bids'),
      MapEntry(rootOf(ApiEndpoints.chats), 'chat'),
      MapEntry(rootOf(ApiEndpoints.userById('placeholder')), 'profile'),
      MapEntry(rootOf(ApiEndpoints.quests), 'quests'),
      MapEntry(rootOf(ApiEndpoints.leaderboard), 'leaderboard'),
      MapEntry(rootOf(ApiEndpoints.adminHeatmap), 'admin operations'),
      MapEntry(rootOf(ApiEndpoints.walletTopup), 'wallet'),
      MapEntry(rootOf(ApiEndpoints.offers), 'offers'),
      MapEntry(rootOf(ApiEndpoints.orders), 'orders'),
      MapEntry(rootOf(ApiEndpoints.reviews), 'reviews'),
      MapEntry(rootOf(ApiEndpoints.campaigns), 'campaigns'),
      MapEntry(rootOf(ApiEndpoints.sellerListingsAnalytics), 'seller tools'),
      MapEntry(rootOf(ApiEndpoints.notifications), 'notifications'),
      MapEntry(rootOf(ApiEndpoints.referrals), 'referrals'),
      MapEntry(
        rootOf(ApiEndpoints.riskUserScore('placeholder')),
        'risk scoring',
      ),
    ];

    for (final mapping in mappings) {
      if (path.contains(mapping.key)) {
        return mapping.value;
      }
    }

    return 'this feature';
  }

  String _featureKey(String path) {
    final segments = path.split('/').where((segment) => segment.isNotEmpty);
    if (segments.isEmpty) {
      return 'global';
    }
    return segments.first;
  }

  bool _shouldForceSessionClearOnUnauthorized(
    DioException error,
    String message,
  ) {
    final path = error.requestOptions.path.toLowerCase();
    final normalizedMessage = message.toLowerCase();

    final isAuthIdentityCheck =
        path.contains(ApiEndpoints.authMe.toLowerCase());
    if (isAuthIdentityCheck) {
      return true;
    }

    return normalizedMessage.contains('session expired') ||
        normalizedMessage.contains('invalid token') ||
        normalizedMessage.contains('token expired');
  }

  String? _extractDetailMessage(dynamic body) {
    if (body is Map<String, dynamic>) {
      final errors = body['errors'];
      if (errors is List && errors.isNotEmpty && errors.first is Map) {
        final first = errors.first as Map;
        final detail = first['detail']?.toString();
        if (detail != null && detail.isNotEmpty) {
          return detail;
        }
      }

      final detail = body['detail']?.toString();
      if (detail != null && detail.isNotEmpty) {
        return detail;
      }

      final message = body['message']?.toString();
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }
    return null;
  }
}

class _RedactingLogInterceptor extends Interceptor {
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
  };

  static const String _divider =
      '══════════════════════════════════════════════════════════════════════════════════════════';

  void _printBoxHeader(String title) {
    debugPrint('╔$title');
  }

  void _printBoxEnd() {
    debugPrint('╚$_divider╝');
  }

  void _printLine(String line) {
    debugPrint('║ $line');
  }

  void _printKv(String key, Object? value) {
    debugPrint('╟ $key: $value');
  }

  String _prettyBody(dynamic body) {
    try {
      return const JsonEncoder.withIndent('   ').convert(body);
    } catch (_) {
      return body?.toString() ?? 'null';
    }
  }

  String _requestUrl(RequestOptions options) => options.uri.toString();

  int? _elapsedMs(RequestOptions options) {
    final startedAt = options.extra['_startedAtMs'];
    if (startedAt is int) {
      return DateTime.now().millisecondsSinceEpoch - startedAt;
    }
    return null;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['_startedAtMs'] = DateTime.now().millisecondsSinceEpoch;

    final method = options.method.toUpperCase();
    final url = _requestUrl(options);

    _printBoxHeader('╣ Request ║ $method ');
    _printLine(url);
    _printBoxEnd();

    if (options.queryParameters.isNotEmpty) {
      _printBoxHeader(' Query Parameters ');
      _redactMap(options.queryParameters).forEach((key, value) {
        _printKv(key, value);
      });
      _printBoxEnd();
    }

    _printBoxHeader(' Headers ');
    final safeHeaders = _redactMap(options.headers);
    safeHeaders.forEach((key, value) {
      if (key.toLowerCase() == 'authorization' && value is String) {
        _printKv('Authorization', '');
        final tokenLine = value.startsWith('Bearer ') ? value.substring(7) : value;
        _printLine('Bearer $tokenLine');
      } else {
        _printKv(key, value);
      }
    });
    _printKv('contentType', options.contentType);
    _printKv('responseType', options.responseType);
    _printKv('followRedirects', options.followRedirects);
    _printKv('connectTimeout', options.connectTimeout);
    _printKv('receiveTimeout', options.receiveTimeout);
    _printBoxEnd();

    if (options.data != null) {
      _printBoxHeader(' Body ');
      _printLine('');
      for (final line in _prettyBody(_redactData(options.data)).split('\n')) {
        _printLine(line);
      }
      _printLine('');
      _printBoxEnd();
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final method = response.requestOptions.method.toUpperCase();
    final url = _requestUrl(response.requestOptions);
    final elapsed = _elapsedMs(response.requestOptions);
    final status = response.statusCode ?? 0;
    final reason = response.statusMessage ?? '';
    final timing = elapsed == null ? '' : '  ║ Time: $elapsed ms';

    _printBoxHeader('╣ Response ║ $method ║ Status: $status $reason$timing');
    _printLine(url);
    _printBoxEnd();

    _printBoxHeader(' Body');
    _printLine('');
    for (final line in _prettyBody(_redactData(response.data)).split('\n')) {
      _printLine(line);
    }
    _printLine('');
    _printBoxEnd();

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final method = err.requestOptions.method.toUpperCase();
    final url = _requestUrl(err.requestOptions);
    final elapsed = _elapsedMs(err.requestOptions);
    final status = err.response?.statusCode?.toString() ?? 'no-status';
    final timing = elapsed == null ? '' : '  ║ Time: $elapsed ms';

    _printBoxHeader('╣ Error ║ $method ║ Status: $status$timing');
    _printLine(url);
    _printBoxEnd();
    _printBoxHeader(' Error Message ');
    _printLine(err.message ?? err.error?.toString() ?? 'Unknown Dio error');
    _printBoxEnd();

    handler.next(err);
  }

  dynamic _redactData(dynamic data) {
    if (data is Map) {
      return _redactMap(data);
    }
    if (data is List) {
      return data.map(_redactData).toList();
    }
    return data;
  }

  Map<String, dynamic> _redactMap(Map<dynamic, dynamic> source) {
    final redacted = <String, dynamic>{};

    source.forEach((key, value) {
      final normalizedKey = key.toString().toLowerCase();
      if (_sensitiveKeys.contains(normalizedKey)) {
        redacted[key.toString()] = '***REDACTED***';
        return;
      }

      if (value is Map) {
        redacted[key.toString()] = _redactMap(value);
      } else if (value is List) {
        redacted[key.toString()] = value.map(_redactData).toList();
      } else {
        redacted[key.toString()] = value;
      }
    });

    return redacted;
  }
}
