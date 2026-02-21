import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/features/chat/presentation/pages/chat_detail_page.dart';
import 'package:neobazaar/features/item/presentation/pages/product_detail_page.dart';
import 'package:neobazaar/features/trade/presentation/pages/offers_inbox_page.dart';
import 'package:neobazaar/features/trade/presentation/pages/order_timeline_page.dart';
import 'package:neobazaar/features/trade/presentation/pages/transaction_history_page.dart';

final notificationDeepLinkResolverProvider =
    Provider<NotificationDeepLinkResolver>((ref) {
      return const NotificationDeepLinkResolver();
    });

class NotificationDeepLinkResolver {
  const NotificationDeepLinkResolver();

  Widget? resolve(Map<String, dynamic> notification) {
    final routeKey = _readRouteKey(notification);
    final params = _readParams(notification);

    switch (routeKey) {
      case 'product.detail':
        final productId =
            _readString(params, 'productId') ??
            _readString(notification, 'productId');
        if (productId == null || productId.isEmpty) {
          return null;
        }
        return ProductDetailPage(productId: productId);
      case 'chat.detail':
        final chatId =
            _readString(params, 'chatId') ??
            _readString(notification, 'chatId');
        if (chatId == null || chatId.isEmpty) {
          return null;
        }
        return ChatDetailPage(
          chatId: chatId,
          title:
              _readString(params, 'title') ??
              _readString(notification, 'title'),
        );
      case 'offers.inbox':
        return const OffersInboxPage();
      case 'orders.timeline':
        final orderId =
            _readString(params, 'orderId') ??
            _readString(notification, 'orderId');
        if (orderId == null || orderId.isEmpty) {
          return null;
        }
        return OrderTimelinePage(orderId: orderId);
      case 'transactions.history':
        return const TransactionHistoryPage();
      default:
        return null;
    }
  }

  String? _readRouteKey(Map<String, dynamic> notification) {
    return _readString(notification, 'routeKey') ??
        _readString(notification, 'route') ??
        _readString(notification, 'target');
  }

  Map<String, dynamic> _readParams(Map<String, dynamic> notification) {
    final direct = notification['routeParams'];
    if (direct is Map<String, dynamic>) {
      return direct;
    }
    if (direct is Map) {
      return direct.map((key, value) => MapEntry(key.toString(), value));
    }

    final payload = notification['payload'];
    if (payload is Map<String, dynamic>) {
      return payload;
    }
    if (payload is Map) {
      return payload.map((key, value) => MapEntry(key.toString(), value));
    }

    return <String, dynamic>{};
  }

  String? _readString(Map<String, dynamic> source, String key) {
    final value = source[key]?.toString();
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }
}
