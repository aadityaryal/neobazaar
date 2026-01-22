import 'package:dio/dio.dart';
import 'package:neobazaar/core/error/failures.dart';

Failure mapDioExceptionToFailure(DioException exception) {
  final statusCode = exception.response?.statusCode;
  final body = exception.response?.data;

  final mappedMessage =
      _extractMessage(body) ?? exception.message ?? 'Request failed';
  final code = _extractCode(body)?.toUpperCase();

  if (statusCode == 401 ||
      code == 'UNAUTHORIZED' ||
      code == 'SESSION_EXPIRED') {
    if (code == 'SESSION_EXPIRED' ||
        mappedMessage.toLowerCase().contains('session')) {
      return SessionExpiredFailure(message: mappedMessage);
    }
    return UnauthorizedFailure(
      message: mappedMessage,
      statusCode: statusCode ?? 401,
    );
  }

  if (statusCode == 403 || code == 'FORBIDDEN') {
    return ForbiddenFailure(
      message: mappedMessage,
      statusCode: statusCode ?? 403,
    );
  }

  if (statusCode == 404 || code == 'NOT_FOUND') {
    return NotFoundFailure(
      message: mappedMessage,
      statusCode: statusCode ?? 404,
    );
  }

  if (statusCode == 409 || code == 'CONFLICT' || code == 'EMAIL_EXISTS') {
    if (code == 'EMAIL_EXISTS' ||
        mappedMessage.toLowerCase().contains('email')) {
      return EmailConflictFailure(message: mappedMessage);
    }
    return ConflictFailure(
      message: mappedMessage,
      statusCode: statusCode ?? 409,
    );
  }

  if (statusCode == 422 || code == 'VALIDATION_ERROR') {
    return ValidationFailure(
      message: mappedMessage,
      statusCode: statusCode ?? 422,
    );
  }

  if (statusCode == 429 || code == 'RATE_LIMITED') {
    return RateLimitedFailure(
      message: mappedMessage,
      statusCode: statusCode ?? 429,
    );
  }

  return ApiFailure(message: mappedMessage, statusCode: statusCode);
}

String? _extractCode(dynamic body) {
  if (body is Map<String, dynamic>) {
    final errors = body['errors'];
    if (errors is List &&
        errors.isNotEmpty &&
        errors.first is Map<String, dynamic>) {
      return (errors.first as Map<String, dynamic>)['code']?.toString();
    }
    return body['code']?.toString();
  }
  return null;
}

String? _extractMessage(dynamic body) {
  if (body is Map<String, dynamic>) {
    final errors = body['errors'];
    if (errors is List &&
        errors.isNotEmpty &&
        errors.first is Map<String, dynamic>) {
      final first = errors.first as Map<String, dynamic>;
      final detail = first['detail']?.toString();
      if (detail != null && detail.isNotEmpty) {
        return detail;
      }
      final message = first['message']?.toString();
      if (message != null && message.isNotEmpty) {
        return message;
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
