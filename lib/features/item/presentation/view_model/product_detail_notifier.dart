import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/services/analytics/analytics_service.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/item/domain/usecases/get_product_detail_usecase.dart';
import 'package:neobazaar/features/item/presentation/state/product_detail_state.dart';

final productDetailNotifierProvider =
    NotifierProvider<ProductDetailNotifier, ProductDetailState>(
      ProductDetailNotifier.new,
    );

class ProductDetailNotifier extends Notifier<ProductDetailState> {
  late final GetProductDetailUsecase _getProductDetailUsecase;
  late final AnalyticsService _analyticsService;
  String? _lastProductId;

  @override
  ProductDetailState build() {
    _getProductDetailUsecase = ref.read(getProductDetailUsecaseProvider);
    _analyticsService = ref.read(analyticsServiceProvider);
    return const ProductDetailState();
  }

  Future<void> fetch(String productId) async {
    _lastProductId = productId;
    state = state.copyWith(
      status: AsyncStatus.loading,
      product: null,
      errorMessage: null,
    );

    final result = await _getProductDetailUsecase(
      GetProductDetailParams(productId: productId),
    );

    result.fold(
      (failure) {
        _analyticsService.track(
          'product_detail_fetch_error',
          properties: {'productId': productId, 'message': failure.message},
        );
        state = state.copyWith(
          status: AsyncStatus.error,
          errorMessage: failure.message,
          product: null,
        );
      },
      (product) {
        _analyticsService.track(
          'product_detail_fetch_success',
          properties: {
            'productId': product.id,
            'category': product.category,
            'mode': product.mode,
            'price': product.price,
          },
        );
        state = state.copyWith(
          status: AsyncStatus.success,
          product: product,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> retry() async {
    final productId = _lastProductId;
    if (productId == null || productId.isEmpty) {
      return;
    }
    await fetch(productId);
  }
}
