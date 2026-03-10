import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/usecases/app_usecase.dart';
import 'package:neobazaar/features/item/data/models/product_list_query_model.dart';
import 'package:neobazaar/features/item/data/repositories/product_repository_impl.dart';
import 'package:neobazaar/features/item/domain/entities/product_entity.dart';
import 'package:neobazaar/features/item/domain/repositories/product_repository.dart';

final getProductsUsecaseProvider = Provider<GetProductsUsecase>((ref) {
  return GetProductsUsecase(repository: ref.read(productRepositoryProvider));
});

class GetProductsUsecase
    implements UsecaseWithParams<List<ProductEntity>, ProductListQueryModel> {
  final IProductRepository _repository;

  GetProductsUsecase({required IProductRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<ProductEntity>>> call(
    ProductListQueryModel params,
  ) {
    return _repository.getProducts(params);
  }
}
