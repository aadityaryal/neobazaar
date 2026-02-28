import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String id;
  final String? productId;
  final String? buyerId;
  final String? sellerId;
  final num amount;
  final String status;
  final bool escrowEnabled;
  final bool buyerConfirmed;
  final bool sellerConfirmed;
  final String? disputeStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TransactionEntity({
    required this.id,
    this.productId,
    this.buyerId,
    this.sellerId,
    this.amount = 0,
    this.status = 'pending',
    this.escrowEnabled = true,
    this.buyerConfirmed = false,
    this.sellerConfirmed = false,
    this.disputeStatus,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => <Object?>[
    id,
    productId,
    buyerId,
    sellerId,
    amount,
    status,
    escrowEnabled,
    buyerConfirmed,
    sellerConfirmed,
    disputeStatus,
    createdAt,
    updatedAt,
  ];
}
