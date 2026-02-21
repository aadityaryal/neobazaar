import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/item/domain/entities/product_entity.dart';

class RecommendationState {
  final AsyncStatus status;
  final List<ProductEntity> items;
  final String? errorMessage;
  final bool fallbackUsed;

  const RecommendationState({
    this.status = AsyncStatus.initial,
    this.items = const <ProductEntity>[],
    this.errorMessage,
    this.fallbackUsed = false,
  });

  RecommendationState copyWith({
    AsyncStatus? status,
    List<ProductEntity>? items,
    Object? errorMessage = _recommendationSentinel,
    bool? fallbackUsed,
  }) {
    return RecommendationState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage == _recommendationSentinel
          ? this.errorMessage
          : errorMessage as String?,
      fallbackUsed: fallbackUsed ?? this.fallbackUsed,
    );
  }
}

const Object _recommendationSentinel = Object();
