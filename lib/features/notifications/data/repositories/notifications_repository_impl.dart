import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/services/connectivity/network_info.dart';
import 'package:neobazaar/features/notifications/data/datasources/notifications_datasource.dart';
import 'package:neobazaar/features/notifications/data/datasources/remote/notifications_remote_datasource.dart';
import 'package:neobazaar/features/notifications/domain/repositories/notifications_repository.dart';

final notificationsRepositoryProvider = Provider<INotificationsRepository>((
  ref,
) {
  return NotificationsRepositoryImpl(
    remoteDatasource: ref.read(notificationsRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class NotificationsRepositoryImpl implements INotificationsRepository {
  final INotificationsRemoteDatasource _remoteDatasource;
  final INetworkInfo _networkInfo;

  NotificationsRepositoryImpl({
    required INotificationsRemoteDatasource remoteDatasource,
    required INetworkInfo networkInfo,
  }) : _remoteDatasource = remoteDatasource,
       _networkInfo = networkInfo;

  Future<Either<Failure, T>> _run<T>(Future<T> Function() operation) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        ApiFailure(message: 'Notifications require network connectivity'),
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
              'Notifications request failed',
          statusCode: error.response?.statusCode,
        ),
      );
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> listNotifications({
    Map<String, dynamic>? query,
  }) {
    return _run(() => _remoteDatasource.listNotifications(query: query));
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createNotification(
    Map<String, dynamic> payload,
  ) {
    return _run(() => _remoteDatasource.createNotification(payload));
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> markNotificationRead(
    String notificationId,
    Map<String, dynamic> payload,
  ) {
    return _run(
      () => _remoteDatasource.markNotificationRead(notificationId, payload),
    );
  }
}
