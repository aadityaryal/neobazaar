import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/services/connectivity/network_info.dart';
import 'package:neobazaar/features/quests/data/datasources/quests_datasource.dart';
import 'package:neobazaar/features/quests/data/datasources/remote/quests_remote_datasource.dart';
import 'package:neobazaar/features/quests/domain/repositories/quests_repository.dart';

final questsRepositoryProvider = Provider<IQuestsRepository>((ref) {
  return QuestsRepositoryImpl(
    remoteDatasource: ref.read(questsRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class QuestsRepositoryImpl implements IQuestsRepository {
  final IQuestsRemoteDatasource _remoteDatasource;
  final INetworkInfo _networkInfo;

  QuestsRepositoryImpl({
    required IQuestsRemoteDatasource remoteDatasource,
    required INetworkInfo networkInfo,
  }) : _remoteDatasource = remoteDatasource,
       _networkInfo = networkInfo;

  Future<Either<Failure, T>> _run<T>(Future<T> Function() operation) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        ApiFailure(message: 'Quests require network connectivity'),
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
              'Quest request failed',
          statusCode: error.response?.statusCode,
        ),
      );
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> listQuests({
    Map<String, dynamic>? query,
  }) {
    return _run(() => _remoteDatasource.listQuests(query: query));
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createQuest(
    Map<String, dynamic> payload,
  ) {
    return _run(() => _remoteDatasource.createQuest(payload));
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> completeQuest(
    String questId,
    Map<String, dynamic> payload,
  ) {
    return _run(() => _remoteDatasource.completeQuest(questId, payload));
  }
}
