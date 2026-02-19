import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/services/connectivity/network_info.dart';
import 'package:neobazaar/features/item/data/datasources/extension_datasource.dart';
import 'package:neobazaar/features/item/data/datasources/remote/extension_remote_datasource.dart';
import 'package:neobazaar/features/item/domain/repositories/extension_repository.dart';

final extensionRepositoryProvider = Provider<IExtensionRepository>((ref) {
  return ExtensionRepositoryImpl(
    remoteDatasource: ref.read(extensionRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class ExtensionRepositoryImpl implements IExtensionRepository {
  final IExtensionRemoteDatasource _remoteDatasource;
  final INetworkInfo _networkInfo;

  ExtensionRepositoryImpl({
    required IExtensionRemoteDatasource remoteDatasource,
    required INetworkInfo networkInfo,
  }) : _remoteDatasource = remoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, Map<String, dynamic>>> detect(
    Map<String, dynamic> payload,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        ApiFailure(message: 'Detect condition requires network connectivity'),
      );
    }

    try {
      final result = await _remoteDatasource.detect(payload);
      return Right(result);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Detect request failed',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> price(
    Map<String, dynamic> payload,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        ApiFailure(message: 'Price suggestion requires network connectivity'),
      );
    }

    try {
      final result = await _remoteDatasource.price(payload);
      return Right(result);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Price request failed',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> fraud(
    Map<String, dynamic> payload,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        ApiFailure(message: 'Fraud pre-check requires network connectivity'),
      );
    }

    try {
      final result = await _remoteDatasource.fraud(payload);
      return Right(result);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Fraud request failed',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> recommend({
    Map<String, dynamic>? queryOrBody,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        ApiFailure(message: 'Recommendation requires network connectivity'),
      );
    }

    try {
      final result = await _remoteDatasource.recommend(
        queryOrBody: queryOrBody,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message:
              e.response?.data['message'] ?? 'Recommendation request failed',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
