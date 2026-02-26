import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/services/connectivity/network_info.dart';
import 'package:neobazaar/features/leaderboard/data/datasources/leaderboard_datasource.dart';
import 'package:neobazaar/features/leaderboard/data/datasources/remote/leaderboard_remote_datasource.dart';
import 'package:neobazaar/features/leaderboard/domain/repositories/leaderboard_repository.dart';

final leaderboardRepositoryProvider = Provider<ILeaderboardRepository>((ref) {
  return LeaderboardRepositoryImpl(
    remoteDatasource: ref.read(leaderboardRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class LeaderboardRepositoryImpl implements ILeaderboardRepository {
  final ILeaderboardRemoteDatasource _remoteDatasource;
  final INetworkInfo _networkInfo;

  LeaderboardRepositoryImpl({
    required ILeaderboardRemoteDatasource remoteDatasource,
    required INetworkInfo networkInfo,
  }) : _remoteDatasource = remoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> listLeaderboard({
    required String tab,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'Leaderboard requires network'));
    }

    try {
      final entries = await _remoteDatasource.listLeaderboard(tab: tab);
      return Right(entries);
    } on DioException catch (error) {
      return Left(
        ApiFailure(
          message:
              error.response?.data?['message']?.toString() ??
              'Leaderboard request failed',
          statusCode: error.response?.statusCode,
        ),
      );
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }
}
