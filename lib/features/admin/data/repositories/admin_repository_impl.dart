import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/services/connectivity/network_info.dart';
import 'package:neobazaar/features/admin/data/datasources/admin_datasource.dart';
import 'package:neobazaar/features/admin/data/datasources/remote/admin_remote_datasource.dart';
import 'package:neobazaar/features/admin/domain/repositories/admin_repository.dart';

final adminRepositoryProvider = Provider<IAdminRepository>((ref) {
  return AdminRepositoryImpl(
    remoteDatasource: ref.read(adminRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class AdminRepositoryImpl implements IAdminRepository {
  final IAdminRemoteDatasource _remoteDatasource;
  final INetworkInfo _networkInfo;

  AdminRepositoryImpl({
    required IAdminRemoteDatasource remoteDatasource,
    required INetworkInfo networkInfo,
  }) : _remoteDatasource = remoteDatasource,
       _networkInfo = networkInfo;

  Future<Either<Failure, T>> _run<T>(Future<T> Function() operation) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        ApiFailure(message: 'Admin operations require network'),
      );
    }

    try {
      final result = await operation();
      return Right(result);
    } on DioException catch (error) {
      return Left(
        ApiFailure(
          message:
              error.response?.data?['message']?.toString() ??
              'Admin request failed',
          statusCode: error.response?.statusCode,
        ),
      );
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getHeatmap({
    Map<String, dynamic>? query,
  }) {
    return _run(() => _remoteDatasource.getHeatmap(query: query));
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getExport({
    Map<String, dynamic>? query,
  }) {
    return _run(() => _remoteDatasource.getExport(query: query));
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createExportJob(
    Map<String, dynamic> payload,
  ) {
    return _run(() => _remoteDatasource.createExportJob(payload));
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getExportJob(
    String exportJobId,
  ) {
    return _run(() => _remoteDatasource.getExportJob(exportJobId));
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> listFlags({
    Map<String, dynamic>? query,
  }) {
    return _run(() => _remoteDatasource.listFlags(query: query));
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateFlag(
    String flagId,
    Map<String, dynamic> payload,
  ) {
    return _run(() => _remoteDatasource.updateFlag(flagId, payload));
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> decideDispute(
    String disputeId,
    Map<String, dynamic> payload,
  ) {
    return _run(() => _remoteDatasource.decideDispute(disputeId, payload));
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> undoModeration(
    String actionId,
    Map<String, dynamic> payload,
  ) {
    return _run(() => _remoteDatasource.undoModeration(actionId, payload));
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> listAuditLogs({
    Map<String, dynamic>? query,
  }) {
    return _run(() => _remoteDatasource.listAuditLogs(query: query));
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> runAuditRetention(
    Map<String, dynamic> payload,
  ) {
    return _run(() => _remoteDatasource.runAuditRetention(payload));
  }
}
