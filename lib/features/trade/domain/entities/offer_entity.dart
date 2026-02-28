import 'package:equatable/equatable.dart';

class OfferEntity extends Equatable {
  final String id;
  final String? productId;
  final String? buyerId;
  final String? sellerId;
  final num amount;
  final String status;
  final DateTime? createdAt;

  const OfferEntity({
    required this.id,
    this.productId,
    this.buyerId,
    this.sellerId,
    this.amount = 0,
    this.status = 'pending',
    this.createdAt,
  });

  @override
  List<Object?> get props => <Object?>[
    id,
    productId,
    buyerId,
    sellerId,
    amount,
    status,
    createdAt,
  ];
}
