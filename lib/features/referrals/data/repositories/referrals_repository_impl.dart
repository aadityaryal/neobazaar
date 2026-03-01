import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/services/connectivity/network_info.dart';
import 'package:neobazaar/features/referrals/data/datasources/referrals_datasource.dart';
import 'package:neobazaar/features/referrals/data/datasources/remote/referrals_remote_datasource.dart';
import 'package:neobazaar/features/referrals/domain/repositories/referrals_repository.dart';

final referralsRepositoryProvider = Provider<IReferralsRepository>((ref) {
  return ReferralsRepositoryImpl(
    remoteDatasource: ref.read(referralsRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class ReferralsRepositoryImpl implements IReferralsRepository {
  final IReferralsRemoteDatasource _remoteDatasource;
  final INetworkInfo _networkInfo;

  ReferralsRepositoryImpl({
    required IReferralsRemoteDatasource remoteDatasource,
    required INetworkInfo networkInfo,
  }) : _remoteDatasource = remoteDatasource,
       _networkInfo = networkInfo;

  Future<Either<Failure, T>> _run<T>(Future<T> Function() operation) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        ApiFailure(message: 'Referrals require network connectivity'),
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
              'Referrals request failed',
          statusCode: error.response?.statusCode,
        ),
      );
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> listReferrals({
    Map<String, dynamic>? query,
  }) {
    return _run(() => _remoteDatasource.listReferrals(query: query));
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createReferral(
    Map<String, dynamic> payload,
  ) {
    return _run(() => _remoteDatasource.createReferral(payload));
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> qualifyReferral(
    String referralId,
    Map<String, dynamic> payload,
  ) {
    return _run(() => _remoteDatasource.qualifyReferral(referralId, payload));
  }
}
