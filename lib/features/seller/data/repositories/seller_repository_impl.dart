import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/services/connectivity/network_info.dart';
import 'package:neobazaar/features/seller/data/datasources/remote/seller_remote_datasource.dart';
import 'package:neobazaar/features/seller/data/datasources/seller_datasource.dart';
import 'package:neobazaar/features/seller/domain/repositories/seller_repository.dart';

final sellerRepositoryProvider = Provider<ISellerRepository>((ref) {
  return SellerRepositoryImpl(
    remoteDatasource: ref.read(sellerRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class SellerRepositoryImpl implements ISellerRepository {
  final ISellerRemoteDatasource _remoteDatasource;
  final INetworkInfo _networkInfo;

  SellerRepositoryImpl({
    required ISellerRemoteDatasource remoteDatasource,
    required INetworkInfo networkInfo,
  }) : _remoteDatasource = remoteDatasource,
       _networkInfo = networkInfo;

  Future<Either<Failure, T>> _run<T>(Future<T> Function() operation) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        ApiFailure(message: 'Seller operations require network'),
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
              'Seller request failed',
          statusCode: error.response?.statusCode,
        ),
      );
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getListingsAnalytics({
    Map<String, dynamic>? query,
  }) {
    return _run(() => _remoteDatasource.getListingsAnalytics(query: query));
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> bulkImport(
    Map<String, dynamic> payload,
  ) {
    return _run(() => _remoteDatasource.bulkImport(payload));
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getPayoutLedger({
    Map<String, dynamic>? query,
  }) {
    return _run(() => _remoteDatasource.getPayoutLedger(query: query));
  }
}
