import 'package:equatable/equatable.dart';

class OrderTimelineEventEntity extends Equatable {
  final String type;
  final String? message;
  final DateTime? createdAt;

  const OrderTimelineEventEntity({
    required this.type,
    this.message,
    this.createdAt,
  });

  @override
  List<Object?> get props => <Object?>[type, message, createdAt];
}

class OrderEntity extends Equatable {
  final String id;
  final String? productId;
  final String? buyerId;
  final String? sellerId;
  final String status;
  final List<OrderTimelineEventEntity> timeline;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrderEntity({
    required this.id,
    this.productId,
    this.buyerId,
    this.sellerId,
    this.status = 'pending',
    this.timeline = const <OrderTimelineEventEntity>[],
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => <Object?>[
    id,
    productId,
    buyerId,
    sellerId,
    status,
    timeline,
    createdAt,
    updatedAt,
  ];
}
