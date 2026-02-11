import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/services/connectivity/network_info.dart';
import 'package:neobazaar/features/campaigns/data/datasources/campaigns_datasource.dart';
import 'package:neobazaar/features/campaigns/data/datasources/remote/campaigns_remote_datasource.dart';
import 'package:neobazaar/features/campaigns/domain/repositories/campaigns_repository.dart';

final campaignsRepositoryProvider = Provider<ICampaignsRepository>((ref) {
  return CampaignsRepositoryImpl(
    remoteDatasource: ref.read(campaignsRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class CampaignsRepositoryImpl implements ICampaignsRepository {
  final ICampaignsRemoteDatasource _remoteDatasource;
  final INetworkInfo _networkInfo;

  CampaignsRepositoryImpl({
    required ICampaignsRemoteDatasource remoteDatasource,
    required INetworkInfo networkInfo,
  }) : _remoteDatasource = remoteDatasource,
       _networkInfo = networkInfo;

  Future<Either<Failure, T>> _run<T>(Future<T> Function() operation) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        ApiFailure(message: 'Campaigns require network connectivity'),
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
              'Campaigns request failed',
          statusCode: error.response?.statusCode,
        ),
      );
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> listCampaigns({
    Map<String, dynamic>? query,
  }) {
    return _run(() => _remoteDatasource.listCampaigns(query: query));
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createCampaign(
    Map<String, dynamic> payload,
  ) {
    return _run(() => _remoteDatasource.createCampaign(payload));
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateCampaignStatus(
    String campaignId,
    Map<String, dynamic> payload,
  ) {
    return _run(
      () => _remoteDatasource.updateCampaignStatus(campaignId, payload),
    );
  }
}
