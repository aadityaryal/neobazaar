import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/services/analytics/analytics_service.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/trade/domain/entities/review_entity.dart';
import 'package:neobazaar/features/trade/domain/usecases/create_review_usecase.dart';
import 'package:neobazaar/features/trade/domain/usecases/flag_review_usecase.dart';
import 'package:neobazaar/features/trade/domain/usecases/list_product_reviews_usecase.dart';
import 'package:neobazaar/features/trade/presentation/state/review_state.dart';

final reviewNotifierProvider = NotifierProvider<ReviewNotifier, ReviewState>(
  ReviewNotifier.new,
);

class ReviewNotifier extends Notifier<ReviewState> {
  late final CreateReviewUsecase _createReviewUsecase;
  late final ListProductReviewsUsecase _listProductReviewsUsecase;
  late final FlagReviewUsecase _flagReviewUsecase;
  late final AnalyticsService _analyticsService;

  @override
  ReviewState build() {
    _createReviewUsecase = ref.read(createReviewUsecaseProvider);
    _listProductReviewsUsecase = ref.read(listProductReviewsUsecaseProvider);
    _flagReviewUsecase = ref.read(flagReviewUsecaseProvider);
    _analyticsService = ref.read(analyticsServiceProvider);
    return const ReviewState();
  }

  Future<void> fetchByProduct(String productId) async {
    state = state.copyWith(status: AsyncStatus.loading, errorMessage: null);
    final result = await _listProductReviewsUsecase(
      ListProductReviewsParams(productId: productId),
    );
    result.fold(
      (failure) {
        _analyticsService.track(
          'review_list_error',
          properties: {'productId': productId, 'message': failure.message},
        );
        state = state.copyWith(
          status: AsyncStatus.error,
          errorMessage: failure.message,
        );
      },
      (items) {
        state = state.copyWith(
          status: AsyncStatus.success,
          reviews: items.map(_toEntity).toList(),
          errorMessage: null,
        );
        _analyticsService.track(
          'review_list_success',
          properties: {'productId': productId, 'count': items.length},
        );
      },
    );
  }

  Future<void> create({
    required String transactionId,
    required String productId,
    required String revieweeId,
    required int rating,
    required String comment,
  }) async {
    final result = await _createReviewUsecase(
      CreateReviewParams(
        payload: <String, dynamic>{
          'transactionId': transactionId,
          'productId': productId,
          'revieweeId': revieweeId,
          'rating': rating,
          'comment': comment,
        },
      ),
    );

    result.fold(
      (failure) {
        _analyticsService.track(
          'review_create_error',
          properties: {
            'productId': productId,
            'rating': rating,
            'message': failure.message,
          },
        );
        state = state.copyWith(errorMessage: failure.message);
      },
      (item) {
        final created = _toEntity(item);
        state = state.copyWith(
          reviews: <ReviewEntity>[created, ...state.reviews],
          errorMessage: null,
        );
        _analyticsService.track(
          'review_create_success',
          properties: {
            'reviewId': created.id,
            'productId': productId,
            'rating': rating,
          },
        );
      },
    );
  }

  Future<void> flag(String reviewId) async {
    final result = await _flagReviewUsecase(
      FlagReviewParams(
        reviewId: reviewId,
        payload: const <String, dynamic>{'flagged': true},
      ),
    );
    result.fold(
      (failure) {
        _analyticsService.track(
          'review_flag_error',
          properties: {'reviewId': reviewId, 'message': failure.message},
        );
        state = state.copyWith(errorMessage: failure.message);
      },
      (_) {
        state = state.copyWith(
          reviews: state.reviews
              .map(
                (item) => item.id == reviewId
                    ? ReviewEntity(
                        id: item.id,
                        productId: item.productId,
                        reviewerId: item.reviewerId,
                        rating: item.rating,
                        comment: item.comment,
                        flagged: true,
                        createdAt: item.createdAt,
                      )
                    : item,
              )
              .toList(),
          errorMessage: null,
        );
        _analyticsService.track(
          'review_flag_success',
          properties: {'reviewId': reviewId},
        );
      },
    );
  }

  ReviewEntity _toEntity(Map<String, dynamic> json) {
    return ReviewEntity(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      productId: json['productId']?.toString(),
      reviewerId: json['reviewerId']?.toString(),
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment']?.toString() ?? '',
      flagged: json['flagged'] == true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}
