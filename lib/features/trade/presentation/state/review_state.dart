import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/trade/domain/entities/review_entity.dart';

class ReviewState {
  final AsyncStatus status;
  final List<ReviewEntity> reviews;
  final String? errorMessage;

  const ReviewState({
    this.status = AsyncStatus.initial,
    this.reviews = const <ReviewEntity>[],
    this.errorMessage,
  });

  ReviewState copyWith({
    AsyncStatus? status,
    List<ReviewEntity>? reviews,
    Object? errorMessage = _reviewStateSentinel,
  }) {
    return ReviewState(
      status: status ?? this.status,
      reviews: reviews ?? this.reviews,
      errorMessage: errorMessage == _reviewStateSentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

const Object _reviewStateSentinel = Object();
