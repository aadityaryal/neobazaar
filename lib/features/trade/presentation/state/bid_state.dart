import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/trade/domain/entities/bid_entity.dart';

class BidState {
  final AsyncStatus status;
  final AsyncStatus placeBidStatus;
  final List<BidEntity> latestBids;
  final num highestBid;
  final String? lastRealtimeEventType;
  final String? errorMessage;

  const BidState({
    this.status = AsyncStatus.initial,
    this.placeBidStatus = AsyncStatus.initial,
    this.latestBids = const <BidEntity>[],
    this.highestBid = 0,
    this.lastRealtimeEventType,
    this.errorMessage,
  });

  BidState copyWith({
    AsyncStatus? status,
    AsyncStatus? placeBidStatus,
    List<BidEntity>? latestBids,
    num? highestBid,
    Object? lastRealtimeEventType = _bidStateSentinel,
    Object? errorMessage = _bidStateSentinel,
  }) {
    return BidState(
      status: status ?? this.status,
      placeBidStatus: placeBidStatus ?? this.placeBidStatus,
      latestBids: latestBids ?? this.latestBids,
      highestBid: highestBid ?? this.highestBid,
      lastRealtimeEventType: lastRealtimeEventType == _bidStateSentinel
          ? this.lastRealtimeEventType
          : lastRealtimeEventType as String?,
      errorMessage: errorMessage == _bidStateSentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

const Object _bidStateSentinel = Object();
