import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/providers/shared_prefs_provider.dart';
import 'package:neobazaar/core/services/analytics/analytics_service.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/item/data/models/product_api_model.dart';
import 'package:neobazaar/features/item/domain/entities/product_entity.dart';
import 'package:neobazaar/features/item/domain/usecases/recommendation_fetch_usecase.dart';
import 'package:neobazaar/features/item/presentation/state/recommendation_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

final recommendationNotifierProvider =
    NotifierProvider<RecommendationNotifier, RecommendationState>(
      RecommendationNotifier.new,
    );

class RecommendationNotifier extends Notifier<RecommendationState> {
  static const String _recentViewsKey = 'recommendation_recent_views';

  late final RecommendationFetchUsecase _recommendationFetchUsecase;
  late final SharedPreferences _sharedPreferences;
  late final AnalyticsService _analyticsService;

  @override
  RecommendationState build() {
    _recommendationFetchUsecase = ref.read(recommendationFetchUsecaseProvider);
    _sharedPreferences = ref.read(sharedPreferencesProvider);
    _analyticsService = ref.read(analyticsServiceProvider);
    return const RecommendationState();
  }

  Future<void> fetch({Map<String, dynamic>? queryOrBody}) async {
    state = state.copyWith(status: AsyncStatus.loading, errorMessage: null);

    final mergedQueryOrBody = <String, dynamic>{
      ...?queryOrBody,
      'recentViews':
          _sharedPreferences.getStringList(_recentViewsKey) ?? const <String>[],
    };

    final result = await _recommendationFetchUsecase(
      RecommendationFetchParams(queryOrBody: mergedQueryOrBody),
    );

    result.fold(
      (failure) {
        _analyticsService.track(
          'recommendation_fetch_error',
          properties: {
            'message': failure.message,
            'recentViewCount':
                (mergedQueryOrBody['recentViews'] as List?)?.length ?? 0,
          },
        );
        state = state.copyWith(
          status: AsyncStatus.error,
          errorMessage: failure.message,
          items: const <ProductEntity>[],
        );
      },
      (payload) {
        final rawItems =
            (payload['items'] as List?) ??
            (payload['recommendations'] as List?) ??
            <dynamic>[];
        final items = rawItems
            .whereType<Map<String, dynamic>>()
            .map(ProductApiModel.fromJson)
            .map((model) => model.toEntity())
            .toList();

        state = state.copyWith(
          status: AsyncStatus.success,
          items: items,
          errorMessage: null,
        );
        _analyticsService.track(
          'recommendation_fetch_success',
          properties: {
            'count': items.length,
            'recentViewCount':
                (mergedQueryOrBody['recentViews'] as List?)?.length ?? 0,
          },
        );
      },
    );
  }

  Future<void> trackRecommendationClick(ProductEntity product) async {
    final current =
        _sharedPreferences.getStringList(_recentViewsKey) ?? const <String>[];

    final merged = <String>[
      product.id,
      ...current.where((id) => id != product.id),
    ];
    final capped = merged.take(20).toList();
    await _sharedPreferences.setStringList(_recentViewsKey, capped);
    _analyticsService.track(
      'recommendation_click',
      properties: {
        'productId': product.id,
        'category': product.category,
        'price': product.price,
      },
    );
  }
}
