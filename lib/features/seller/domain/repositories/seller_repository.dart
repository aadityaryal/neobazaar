import 'package:dartz/dartz.dart';
import 'package:neobazaar/core/error/failures.dart';

abstract interface class ISellerRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> getListingsAnalytics({
    Map<String, dynamic>? query,
  });

  Future<Either<Failure, Map<String, dynamic>>> bulkImport(
    Map<String, dynamic> payload,
  );

  Future<Either<Failure, List<Map<String, dynamic>>>> getPayoutLedger({
    Map<String, dynamic>? query,
  });
}
