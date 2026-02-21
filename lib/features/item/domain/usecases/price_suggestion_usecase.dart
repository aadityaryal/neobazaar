import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/usecases/app_usecase.dart';
import 'package:neobazaar/features/item/data/repositories/extension_repository_impl.dart';
import 'package:neobazaar/features/item/domain/repositories/extension_repository.dart';

class PriceSuggestionParams extends Equatable {
  final Map<String, dynamic> payload;

  const PriceSuggestionParams({required this.payload});

  @override
  List<Object?> get props => <Object?>[payload];
}

final priceSuggestionUsecaseProvider = Provider<PriceSuggestionUsecase>((ref) {
  return PriceSuggestionUsecase(
    repository: ref.read(extensionRepositoryProvider),
  );
});

class PriceSuggestionUsecase
    implements UsecaseWithParams<Map<String, dynamic>, PriceSuggestionParams> {
  final IExtensionRepository _repository;

  PriceSuggestionUsecase({required IExtensionRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    PriceSuggestionParams params,
  ) {
    return _repository.price(params.payload);
  }
}
