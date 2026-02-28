import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/services/analytics/analytics_service.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/trade/domain/entities/bid_entity.dart';
import 'package:neobazaar/features/trade/domain/usecases/place_bid_usecase.dart';
import 'package:neobazaar/features/trade/presentation/state/bid_state.dart';

final bidNotifierProvider = NotifierProvider<BidNotifier, BidState>(
  BidNotifier.new,
);

class BidNotifier extends Notifier<BidState> {
  late final PlaceBidUsecase _placeBidUsecase;
  late final AnalyticsService _analyticsService;

  @override
  BidState build() {
    _placeBidUsecase = ref.read(placeBidUsecaseProvider);
    _analyticsService = ref.read(analyticsServiceProvider);
    return const BidState();
  }

  Future<void> placeBid({
    required String productId,
    required num amount,
  }) async {
    state = state.copyWith(
      placeBidStatus: AsyncStatus.loading,
      errorMessage: null,
    );

    final result = await _placeBidUsecase(
      PlaceBidParams(
        payload: <String, dynamic>{'productId': productId, 'amount': amount},
      ),
    );

    result.fold(
      (failure) {
        _analyticsService.track(
          'bid_place_error',
          properties: {
            'productId': productId,
            'amount': amount,
            'message': failure.message,
          },
        );
        state = state.copyWith(
          placeBidStatus: AsyncStatus.error,
          errorMessage: failure.message,
        );
      },
      (payload) {
        final bid = BidEntity(
          id: (payload['_id'] ?? payload['id'] ?? '').toString(),
          productId: payload['productId']?.toString(),
          bidderId: payload['bidderId']?.toString(),
          amount: payload['amount'] as num? ?? amount,
          status: payload['status']?.toString() ?? 'placed',
          createdAt: DateTime.tryParse(payload['createdAt']?.toString() ?? ''),
        );

        final latest = <BidEntity>[bid, ...state.latestBids];
        state = state.copyWith(
          placeBidStatus: AsyncStatus.success,
          latestBids: latest,
          highestBid: latest
              .map((item) => item.amount)
              .fold<num>(
                0,
                (current, value) => value > current ? value : current,
              ),
          errorMessage: null,
        );
        _analyticsService.track(
          'bid_place_success',
          properties: {
            'productId': productId,
            'bidId': bid.id,
            'amount': bid.amount,
            'highestBid': state.highestBid,
          },
        );
      },
    );
  }

  void onRealtimeEvent({required String eventType}) {
    state = state.copyWith(
      lastRealtimeEventType: eventType,
      status: AsyncStatus.success,
    );
    _analyticsService.track(
      'bid_realtime_event',
      properties: {'eventType': eventType},
    );
  }

  void onHighestBidUpdate(num highestBid) {
    state = state.copyWith(
      highestBid: highestBid,
      lastRealtimeEventType: 'highest_bid_update',
    );
    _analyticsService.track(
      'bid_highest_update',
      properties: {'highestBid': highestBid},
    );
  }
}
