import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/services/connectivity/network_info.dart';
import 'package:neobazaar/features/risk/data/datasources/remote/risk_remote_datasource.dart';
import 'package:neobazaar/features/risk/data/datasources/risk_datasource.dart';
import 'package:neobazaar/features/risk/domain/repositories/risk_repository.dart';

final riskRepositoryProvider = Provider<IRiskRepository>((ref) {
  return RiskRepositoryImpl(
    remoteDatasource: ref.read(riskRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class RiskRepositoryImpl implements IRiskRepository {
  final IRiskRemoteDatasource _remoteDatasource;
  final INetworkInfo _networkInfo;

  RiskRepositoryImpl({
    required IRiskRemoteDatasource remoteDatasource,
    required INetworkInfo networkInfo,
  }) : _remoteDatasource = remoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserRiskScore(
    String userId,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'Risk scoring requires network'));
    }

    try {
      final score = await _remoteDatasource.getUserRiskScore(userId);
      return Right(score);
    } on DioException catch (error) {
      return Left(
        ApiFailure(
          message:
              error.response?.data?['message']?.toString() ??
              'Risk request failed',
          statusCode: error.response?.statusCode,
        ),
      );
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }
}
