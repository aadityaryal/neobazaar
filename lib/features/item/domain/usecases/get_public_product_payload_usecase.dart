import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/usecases/app_usecase.dart';
import 'package:neobazaar/features/item/data/repositories/product_repository_impl.dart';
import 'package:neobazaar/features/item/domain/repositories/product_repository.dart';

class GetPublicProductPayloadParams extends Equatable {
  final String productId;

  const GetPublicProductPayloadParams({required this.productId});

  @override
  List<Object?> get props => <Object?>[productId];
}

final getPublicProductPayloadUsecaseProvider =
    Provider<GetPublicProductPayloadUsecase>((ref) {
      return GetPublicProductPayloadUsecase(
        repository: ref.read(productRepositoryProvider),
      );
    });

class GetPublicProductPayloadUsecase
    implements
        UsecaseWithParams<Map<String, dynamic>, GetPublicProductPayloadParams> {
  final IProductRepository _repository;

  GetPublicProductPayloadUsecase({required IProductRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    GetPublicProductPayloadParams params,
  ) {
    return _repository.getPublicProductPayload(params.productId);
  }
}
