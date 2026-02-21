import 'package:dartz/dartz.dart';
import 'package:neobazaar/core/error/failures.dart';

abstract interface class IExtensionRepository {
  Future<Either<Failure, Map<String, dynamic>>> detect(
    Map<String, dynamic> payload,
  );
  Future<Either<Failure, Map<String, dynamic>>> price(
    Map<String, dynamic> payload,
  );
  Future<Either<Failure, Map<String, dynamic>>> fraud(
    Map<String, dynamic> payload,
  );
  Future<Either<Failure, Map<String, dynamic>>> recommend({
    Map<String, dynamic>? queryOrBody,
  });
}
