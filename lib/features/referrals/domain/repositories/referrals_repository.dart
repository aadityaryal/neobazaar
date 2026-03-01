import 'package:dartz/dartz.dart';
import 'package:neobazaar/core/error/failures.dart';

abstract interface class IReferralsRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> listReferrals({
    Map<String, dynamic>? query,
  });

  Future<Either<Failure, Map<String, dynamic>>> createReferral(
    Map<String, dynamic> payload,
  );

  Future<Either<Failure, Map<String, dynamic>>> qualifyReferral(
    String referralId,
    Map<String, dynamic> payload,
  );
}
