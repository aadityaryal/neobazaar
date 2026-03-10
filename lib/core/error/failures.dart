import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

// Local Database Failure
class LocalDatabaseFailure extends Failure {
  const LocalDatabaseFailure({
    String message = "Local database operation failed",
  }) : super(message);
}

// API Failure with status code

class ApiFailure extends Failure {
  final int? statusCode;
  const ApiFailure({required String message, this.statusCode}) : super(message);

  @override
  List<Object?> get props => [message, statusCode];
}

class UnauthorizedFailure extends ApiFailure {
  const UnauthorizedFailure({
    super.message = 'Session expired. Please log in again.',
    super.statusCode = 401,
  });
}

class SessionExpiredFailure extends UnauthorizedFailure {
  const SessionExpiredFailure({
    super.message = 'Your session has expired. Please log in again.',
  });
}

class ForbiddenFailure extends ApiFailure {
  const ForbiddenFailure({
    super.message = 'You do not have permission for this action.',
    super.statusCode = 403,
  });
}

class NotFoundFailure extends ApiFailure {
  const NotFoundFailure({
    super.message = 'Requested resource was not found.',
    super.statusCode = 404,
  });
}

class ConflictFailure extends ApiFailure {
  const ConflictFailure({
    super.message = 'Request could not be completed due to a conflict.',
    super.statusCode = 409,
  });
}

class EmailConflictFailure extends ConflictFailure {
  const EmailConflictFailure({
    super.message = 'This email is already registered.',
  });
}

class ValidationFailure extends ApiFailure {
  const ValidationFailure({
    super.message = 'Validation failed for one or more fields.',
    super.statusCode = 422,
  });
}

class RateLimitedFailure extends ApiFailure {
  const RateLimitedFailure({
    super.message = 'Too many requests. Please retry later.',
    super.statusCode = 429,
  });
}
