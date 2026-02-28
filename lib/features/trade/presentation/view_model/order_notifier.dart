import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/services/analytics/analytics_service.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/trade/domain/entities/order_entity.dart';
import 'package:neobazaar/features/trade/domain/usecases/append_order_timeline_usecase.dart';
import 'package:neobazaar/features/trade/domain/usecases/get_order_timeline_usecase.dart';
import 'package:neobazaar/features/trade/domain/usecases/list_orders_usecase.dart';
import 'package:neobazaar/features/trade/presentation/state/order_state.dart';

final orderNotifierProvider = NotifierProvider<OrderNotifier, OrderState>(
  OrderNotifier.new,
);

class OrderNotifier extends Notifier<OrderState> {
  late final ListOrdersUsecase _listOrdersUsecase;
  late final GetOrderTimelineUsecase _getOrderTimelineUsecase;
  late final AppendOrderTimelineUsecase _appendOrderTimelineUsecase;
  late final AnalyticsService _analyticsService;

  @override
  OrderState build() {
    _listOrdersUsecase = ref.read(listOrdersUsecaseProvider);
    _getOrderTimelineUsecase = ref.read(getOrderTimelineUsecaseProvider);
    _appendOrderTimelineUsecase = ref.read(appendOrderTimelineUsecaseProvider);
    _analyticsService = ref.read(analyticsServiceProvider);
    return const OrderState();
  }

  Future<void> fetchOrders() async {
    state = state.copyWith(status: AsyncStatus.loading, errorMessage: null);
    final result = await _listOrdersUsecase(const ListOrdersParams());
    result.fold(
      (failure) {
        _analyticsService.track(
          'order_list_fetch_error',
          properties: {'message': failure.message},
        );
        state = state.copyWith(
          status: AsyncStatus.error,
          errorMessage: failure.message,
        );
      },
      (items) {
        state = state.copyWith(
          status: AsyncStatus.success,
          orders: items.map(_toEntity).toList(),
          errorMessage: null,
        );
        _analyticsService.track(
          'order_list_fetch_success',
          properties: {'count': items.length},
        );
      },
    );
  }

  Future<void> fetchTimeline(String orderId) async {
    final result = await _getOrderTimelineUsecase(
      GetOrderTimelineParams(orderId: orderId),
    );
    result.fold(
      (failure) {
        _analyticsService.track(
          'order_timeline_fetch_error',
          properties: {'orderId': orderId, 'message': failure.message},
        );
        state = state.copyWith(errorMessage: failure.message);
      },
      (items) {
        state = state.copyWith(
          timeline: items.map(_toTimelineEvent).toList(),
          errorMessage: null,
        );
        _analyticsService.track(
          'order_timeline_fetch_success',
          properties: {'orderId': orderId, 'count': items.length},
        );
      },
    );
  }

  Future<void> appendTimeline({
    required String orderId,
    required String status,
    String? note,
  }) async {
    final result = await _appendOrderTimelineUsecase(
      AppendOrderTimelineParams(
        orderId: orderId,
        payload: <String, dynamic>{
          'status': status,
          if (note != null && note.isNotEmpty) 'note': note,
        },
      ),
    );

    if (result.isLeft()) {
      result.fold((failure) {
        _analyticsService.track(
          'order_timeline_append_error',
          properties: {
            'orderId': orderId,
            'status': status,
            'message': failure.message,
          },
        );
        state = state.copyWith(errorMessage: failure.message);
      }, (_) {});
      return;
    }

    _analyticsService.track(
      'order_timeline_append_success',
      properties: {'orderId': orderId, 'status': status},
    );
    await fetchTimeline(orderId);
  }

  OrderEntity _toEntity(Map<String, dynamic> json) {
    return OrderEntity(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      productId: json['productId']?.toString(),
      buyerId: json['buyerId']?.toString(),
      sellerId: json['sellerId']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      timeline:
          (json['timeline'] as List?)
              ?.whereType<Map>()
              .map((item) => _toTimelineEvent(item.cast<String, dynamic>()))
              .toList() ??
          const <OrderTimelineEventEntity>[],
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }

  OrderTimelineEventEntity _toTimelineEvent(Map<String, dynamic> json) {
    return OrderTimelineEventEntity(
      type: json['type']?.toString() ?? json['status']?.toString() ?? 'update',
      message: json['message']?.toString() ?? json['note']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}
