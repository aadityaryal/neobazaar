import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/services/connectivity/network_info.dart';
import 'package:neobazaar/features/item/data/datasources/product_datasource.dart';
import 'package:neobazaar/features/item/data/datasources/remote/product_remote_datasource.dart';
import 'package:neobazaar/features/item/data/models/product_list_query_model.dart';
import 'package:neobazaar/features/item/domain/entities/product_entity.dart';
import 'package:neobazaar/features/item/domain/repositories/product_repository.dart';

final productRepositoryProvider = Provider<IProductRepository>((ref) {
  return ProductRepositoryImpl(
    remoteDatasource: ref.read(productRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class ProductRepositoryImpl implements IProductRepository {
  final IProductRemoteDatasource _remoteDatasource;
  final INetworkInfo _networkInfo;

  ProductRepositoryImpl({
    required IProductRemoteDatasource remoteDatasource,
    required INetworkInfo networkInfo,
  }) : _remoteDatasource = remoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts(
    ProductListQueryModel query,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        ApiFailure(message: 'Products list requires network connectivity'),
      );
    }

    try {
      final models = await _remoteDatasource.getProducts(query);
      return Right(models.map((item) => item.toEntity()).toList());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to fetch products',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(
    String productId,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        ApiFailure(message: 'Product detail requires network connectivity'),
      );
    }

    try {
      final model = await _remoteDatasource.getProductById(productId);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message:
              e.response?.data['message'] ?? 'Failed to fetch product detail',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getPublicProductPayload(
    String productId,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        ApiFailure(
          message: 'Public product payload requires network connectivity',
        ),
      );
    }

    try {
      final payload = await _remoteDatasource.getPublicProductPayload(
        productId,
      );
      return Right(payload);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message:
              e.response?.data['message'] ??
              'Failed to fetch public product payload',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> createProduct(
    Map<String, dynamic> payload,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        ApiFailure(message: 'Create product requires network connectivity'),
      );
    }

    try {
      final model = await _remoteDatasource.createProduct(payload);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to create product',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
