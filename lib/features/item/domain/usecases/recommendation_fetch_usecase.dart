import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/usecases/app_usecase.dart';
import 'package:neobazaar/features/item/data/repositories/extension_repository_impl.dart';
import 'package:neobazaar/features/item/domain/repositories/extension_repository.dart';

class RecommendationFetchParams extends Equatable {
  final Map<String, dynamic>? queryOrBody;

  const RecommendationFetchParams({this.queryOrBody});

  @override
  List<Object?> get props => <Object?>[queryOrBody];
}

final recommendationFetchUsecaseProvider = Provider<RecommendationFetchUsecase>(
  (ref) {
    return RecommendationFetchUsecase(
      repository: ref.read(extensionRepositoryProvider),
    );
  },
);

class RecommendationFetchUsecase
    implements
        UsecaseWithParams<Map<String, dynamic>, RecommendationFetchParams> {
  final IExtensionRepository _repository;

  RecommendationFetchUsecase({required IExtensionRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    RecommendationFetchParams params,
  ) {
    return _repository.recommend(queryOrBody: params.queryOrBody);
  }
}
