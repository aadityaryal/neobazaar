import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/services/connectivity/network_info.dart';
import 'package:neobazaar/features/chat/data/datasources/chat_datasource.dart';
import 'package:neobazaar/features/chat/data/datasources/remote/chat_remote_datasource.dart';
import 'package:neobazaar/features/chat/domain/repositories/chat_repository.dart';

final chatRepositoryProvider = Provider<IChatRepository>((ref) {
  return ChatRepositoryImpl(
    remoteDatasource: ref.read(chatRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class ChatRepositoryImpl implements IChatRepository {
  final IChatRemoteDatasource _remoteDatasource;
  final INetworkInfo _networkInfo;

  ChatRepositoryImpl({
    required IChatRemoteDatasource remoteDatasource,
    required INetworkInfo networkInfo,
  }) : _remoteDatasource = remoteDatasource,
       _networkInfo = networkInfo;

  Future<Either<Failure, T>> _run<T>(Future<T> Function() operation) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        ApiFailure(message: 'Chat operations require network connectivity'),
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
              'Chat request failed',
          statusCode: error.response?.statusCode,
        ),
      );
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> replay({
    Map<String, dynamic>? query,
  }) {
    return _run(() => _remoteDatasource.replay(query: query));
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createChat(
    Map<String, dynamic> payload,
  ) {
    return _run(() => _remoteDatasource.createChat(payload));
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getMessages(
    String chatId, {
    Map<String, dynamic>? query,
  }) {
    return _run(() => _remoteDatasource.getMessages(chatId, query: query));
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createMessage(
    String chatId,
    Map<String, dynamic> payload,
  ) {
    return _run(() => _remoteDatasource.createMessage(chatId, payload));
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> markMessageRead(
    String chatId,
    String messageId,
    Map<String, dynamic> payload,
  ) {
    return _run(
      () => _remoteDatasource.markMessageRead(chatId, messageId, payload),
    );
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> suggestReplies(
    Map<String, dynamic> payload,
  ) {
    return _run(() => _remoteDatasource.suggestReplies(payload));
  }
}
