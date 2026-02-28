import 'package:equatable/equatable.dart';

class BidEntity extends Equatable {
  final String id;
  final String? productId;
  final String? bidderId;
  final num amount;
  final String status;
  final DateTime? createdAt;

  const BidEntity({
    required this.id,
    this.productId,
    this.bidderId,
    this.amount = 0,
    this.status = 'placed',
    this.createdAt,
  });

  @override
  List<Object?> get props => <Object?>[
    id,
    productId,
    bidderId,
    amount,
    status,
    createdAt,
  ];
}
