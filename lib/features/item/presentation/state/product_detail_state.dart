import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/item/domain/entities/product_entity.dart';

class ProductDetailState {
  final AsyncStatus status;
  final ProductEntity? product;
  final String? errorMessage;

  const ProductDetailState({
    this.status = AsyncStatus.initial,
    this.product,
    this.errorMessage,
  });

  ProductDetailState copyWith({
    AsyncStatus? status,
    Object? product = _sentinel,
    Object? errorMessage = _sentinel,
  }) {
    return ProductDetailState(
      status: status ?? this.status,
      product: product == _sentinel ? this.product : product as ProductEntity?,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

const Object _sentinel = Object();
