import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/usecases/app_usecase.dart';
import 'package:neobazaar/features/item/data/repositories/product_repository_impl.dart';
import 'package:neobazaar/features/item/domain/entities/product_entity.dart';
import 'package:neobazaar/features/item/domain/repositories/product_repository.dart';

class GetProductDetailParams extends Equatable {
  final String productId;

  const GetProductDetailParams({required this.productId});

  @override
  List<Object?> get props => <Object?>[productId];
}

final getProductDetailUsecaseProvider = Provider<GetProductDetailUsecase>((
  ref,
) {
  return GetProductDetailUsecase(
    repository: ref.read(productRepositoryProvider),
  );
});

class GetProductDetailUsecase
    implements UsecaseWithParams<ProductEntity, GetProductDetailParams> {
  final IProductRepository _repository;

  GetProductDetailUsecase({required IProductRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, ProductEntity>> call(GetProductDetailParams params) {
    return _repository.getProductById(params.productId);
  }
}
