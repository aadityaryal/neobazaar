class AppException implements Exception {
  final String message;
  const AppException({required this.message});

  @override
  String toString() => message;
}

class ApiException extends AppException {
  final int? statusCode;
  const ApiException({required super.message, this.statusCode});
}

class NetworkException extends AppException {
  const NetworkException({super.message = 'Connection error — please retry'});
}

class UnexpectedResponseException extends AppException {
  const UnexpectedResponseException({
    super.message = 'Unexpected API response format',
  });
}
