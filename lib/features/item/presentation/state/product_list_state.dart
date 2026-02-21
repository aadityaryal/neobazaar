import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/item/domain/entities/product_entity.dart';

class ProductListState {
  final AsyncStatus status;
  final List<ProductEntity> items;
  final String? errorMessage;
  final int page;
  final int limit;
  final bool hasMore;
  final String? category;
  final String? location;
  final String? mode;
  final num? minPrice;
  final num? maxPrice;
  final String? sort;

  const ProductListState({
    this.status = AsyncStatus.initial,
    this.items = const <ProductEntity>[],
    this.errorMessage,
    this.page = 1,
    this.limit = 20,
    this.hasMore = true,
    this.category,
    this.location,
    this.mode,
    this.minPrice,
    this.maxPrice,
    this.sort,
  });

  ProductListState copyWith({
    AsyncStatus? status,
    List<ProductEntity>? items,
    String? errorMessage,
    int? page,
    int? limit,
    bool? hasMore,
    String? category,
    String? location,
    String? mode,
    num? minPrice,
    num? maxPrice,
    String? sort,
  }) {
    return ProductListState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      hasMore: hasMore ?? this.hasMore,
      category: category ?? this.category,
      location: location ?? this.location,
      mode: mode ?? this.mode,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      sort: sort ?? this.sort,
    );
  }
}
