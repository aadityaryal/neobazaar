import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/usecases/app_usecase.dart';
import 'package:neobazaar/features/item/data/repositories/product_repository_impl.dart';
import 'package:neobazaar/features/item/domain/entities/product_entity.dart';
import 'package:neobazaar/features/item/domain/repositories/product_repository.dart';

class CreateProductParams extends Equatable {
  final Map<String, dynamic> payload;

  const CreateProductParams({required this.payload});

  @override
  List<Object?> get props => <Object?>[payload];
}

final createProductUsecaseProvider = Provider<CreateProductUsecase>((ref) {
  return CreateProductUsecase(repository: ref.read(productRepositoryProvider));
});

class CreateProductUsecase
    implements UsecaseWithParams<ProductEntity, CreateProductParams> {
  final IProductRepository _repository;

  CreateProductUsecase({required IProductRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, ProductEntity>> call(CreateProductParams params) {
    return _repository.createProduct(params.payload);
  }
}
