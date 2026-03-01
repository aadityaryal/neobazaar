import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/services/connectivity/network_info.dart';
import 'package:neobazaar/features/wallet/data/datasources/remote/wallet_remote_datasource.dart';
import 'package:neobazaar/features/wallet/data/datasources/wallet_datasource.dart';
import 'package:neobazaar/features/wallet/domain/repositories/wallet_repository.dart';

final walletRepositoryProvider = Provider<IWalletRepository>((ref) {
  return WalletRepositoryImpl(
    remoteDatasource: ref.read(walletRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class WalletRepositoryImpl implements IWalletRepository {
  final IWalletRemoteDatasource _remoteDatasource;
  final INetworkInfo _networkInfo;

  WalletRepositoryImpl({
    required IWalletRemoteDatasource remoteDatasource,
    required INetworkInfo networkInfo,
  }) : _remoteDatasource = remoteDatasource,
       _networkInfo = networkInfo;

  Future<Either<Failure, T>> _run<T>(Future<T> Function() operation) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        ApiFailure(message: 'Wallet operations require network'),
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
              'Wallet request failed',
          statusCode: error.response?.statusCode,
        ),
      );
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> topup(
    Map<String, dynamic> payload,
  ) {
    return _run(() => _remoteDatasource.topup(payload));
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> topupViaUserAlias(
    Map<String, dynamic> payload,
  ) {
    return _run(() => _remoteDatasource.topupViaUserAlias(payload));
  }
}
