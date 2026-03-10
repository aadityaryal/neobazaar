import 'package:dartz/dartz.dart';
import 'package:neobazaar/core/error/failures.dart';

abstract interface class IAdminRepository {
  Future<Either<Failure, Map<String, dynamic>>> getHeatmap({
    Map<String, dynamic>? query,
  });

  Future<Either<Failure, Map<String, dynamic>>> getExport({
    Map<String, dynamic>? query,
  });

  Future<Either<Failure, Map<String, dynamic>>> createExportJob(
    Map<String, dynamic> payload,
  );

  Future<Either<Failure, Map<String, dynamic>>> getExportJob(
    String exportJobId,
  );

  Future<Either<Failure, List<Map<String, dynamic>>>> listFlags({
    Map<String, dynamic>? query,
  });

  Future<Either<Failure, Map<String, dynamic>>> updateFlag(
    String flagId,
    Map<String, dynamic> payload,
  );

  Future<Either<Failure, Map<String, dynamic>>> decideDispute(
    String disputeId,
    Map<String, dynamic> payload,
  );

  Future<Either<Failure, Map<String, dynamic>>> undoModeration(
    String actionId,
    Map<String, dynamic> payload,
  );

  Future<Either<Failure, List<Map<String, dynamic>>>> listAuditLogs({
    Map<String, dynamic>? query,
  });

  Future<Either<Failure, Map<String, dynamic>>> runAuditRetention(
    Map<String, dynamic> payload,
  );
}
