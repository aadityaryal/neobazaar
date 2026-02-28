import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/trade/domain/entities/order_entity.dart';

class OrderState {
  final AsyncStatus status;
  final List<OrderEntity> orders;
  final List<OrderTimelineEventEntity> timeline;
  final String? errorMessage;

  const OrderState({
    this.status = AsyncStatus.initial,
    this.orders = const <OrderEntity>[],
    this.timeline = const <OrderTimelineEventEntity>[],
    this.errorMessage,
  });

  OrderState copyWith({
    AsyncStatus? status,
    List<OrderEntity>? orders,
    List<OrderTimelineEventEntity>? timeline,
    Object? errorMessage = _orderStateSentinel,
  }) {
    return OrderState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      timeline: timeline ?? this.timeline,
      errorMessage: errorMessage == _orderStateSentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

const Object _orderStateSentinel = Object();
