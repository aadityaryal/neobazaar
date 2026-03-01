import 'package:dartz/dartz.dart';
import 'package:neobazaar/core/error/failures.dart';

abstract interface class IRiskRepository {
  Future<Either<Failure, Map<String, dynamic>>> getUserRiskScore(String userId);
}
