import 'package:dartz/dartz.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/features/item/data/models/product_list_query_model.dart';
import 'package:neobazaar/features/item/domain/entities/product_entity.dart';

abstract interface class IProductRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts(
    ProductListQueryModel query,
  );
  Future<Either<Failure, ProductEntity>> getProductById(String productId);
  Future<Either<Failure, Map<String, dynamic>>> getPublicProductPayload(
    String productId,
  );
  Future<Either<Failure, ProductEntity>> createProduct(
    Map<String, dynamic> payload,
  );
}
