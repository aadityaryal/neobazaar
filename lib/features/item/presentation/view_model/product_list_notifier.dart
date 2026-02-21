import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/services/analytics/analytics_service.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/item/data/models/product_list_query_model.dart';
import 'package:neobazaar/features/item/domain/entities/product_entity.dart';
import 'package:neobazaar/features/item/domain/usecases/get_products_usecase.dart';
import 'package:neobazaar/features/item/presentation/state/product_list_state.dart';

final productListNotifierProvider =
    NotifierProvider<ProductListNotifier, ProductListState>(
      ProductListNotifier.new,
    );

class ProductListNotifier extends Notifier<ProductListState> {
  GetProductsUsecase get _getProductsUsecase =>
      ref.read(getProductsUsecaseProvider);
  AnalyticsService get _analyticsService => ref.read(analyticsServiceProvider);

  @override
  ProductListState build() {
    return const ProductListState();
  }

  Future<void> fetchProducts({bool reset = false}) async {
    if (state.status == AsyncStatus.loading && !reset) {
      return;
    }

    final nextPage = reset ? 1 : state.page;
    final previousItems = reset
        ? <ProductEntity>[]
        : List<ProductEntity>.from(state.items);

    state = state.copyWith(status: AsyncStatus.loading, errorMessage: null);

    final query = ProductListQueryModel(
      category: state.category,
      location: state.location,
      mode: state.mode,
      minPrice: state.minPrice,
      maxPrice: state.maxPrice,
      sort: state.sort,
      page: nextPage,
      limit: state.limit,
    );

    final result = await _getProductsUsecase(query);
    result.fold(
      (failure) {
        _analyticsService.track(
          'products_list_fetch_error',
          properties: {
            'reset': reset,
            'page': nextPage,
            'message': failure.message,
          },
        );
        state = state.copyWith(
          status: AsyncStatus.error,
          errorMessage: failure.message,
        );
      },
      (items) {
        _analyticsService.track(
          'products_list_fetch_success',
          properties: {
            'reset': reset,
            'page': nextPage,
            'count': items.length,
            'hasMore': items.length >= state.limit,
            'category': state.category,
            'location': state.location,
            'mode': state.mode,
            'sort': state.sort,
          },
        );
        final merged = <ProductEntity>[...previousItems, ...items];
        state = state.copyWith(
          status: AsyncStatus.success,
          items: merged,
          page: nextPage + 1,
          hasMore: items.length >= state.limit,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.status == AsyncStatus.loading) {
      return;
    }
    await fetchProducts();
  }

  Future<void> refresh() async {
    await fetchProducts(reset: true);
  }

  Future<void> retry() async {
    await fetchProducts(reset: true);
  }

  Future<void> setCategory(String? category) async {
    state = state.copyWith(category: category);
    await refresh();
  }

  Future<void> setLocation(String? location) async {
    state = state.copyWith(location: location);
    await refresh();
  }

  Future<void> setMode(String? mode) async {
    state = state.copyWith(mode: mode);
    await refresh();
  }

  Future<void> setPriceRange({num? minPrice, num? maxPrice}) async {
    state = state.copyWith(minPrice: minPrice, maxPrice: maxPrice);
    await refresh();
  }

  Future<void> setSort(String? sort) async {
    state = state.copyWith(sort: sort);
    await refresh();
  }
}
