// AUTO-GENERATED FILE. DO NOT EDIT.
// Source: pilot parity contract (offers/orders/transactions/disputes)

class TradeOfferDto {
  final String id;
  final String? productId;
  final String? buyerId;
  final String? sellerId;
  final num amount;
  final String status;
  final DateTime? createdAt;

  const TradeOfferDto({
    required this.id,
    required this.productId,
    required this.buyerId,
    required this.sellerId,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  factory TradeOfferDto.fromJson(Map<String, dynamic> json) {
    return TradeOfferDto(
      id: (json['offerId'] ?? json['id'] ?? json['_id'] ?? '').toString(),
      productId: json['productId']?.toString(),
      buyerId: json['buyerId']?.toString(),
      sellerId: json['sellerId']?.toString(),
      amount: json['amount'] as num? ?? json['counterAmount'] as num? ?? 0,
      status: json['status']?.toString() ?? 'pending',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'productId': productId,
      'buyerId': buyerId,
      'sellerId': sellerId,
      'amount': amount,
      'status': status,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}

class TradeOrderTimelineEntryDto {
  final String status;
  final String? actor;
  final String? note;
  final DateTime? at;

  const TradeOrderTimelineEntryDto({
    required this.status,
    required this.actor,
    required this.note,
    required this.at,
  });

  factory TradeOrderTimelineEntryDto.fromJson(Map<String, dynamic> json) {
    return TradeOrderTimelineEntryDto(
      status:
          json['status']?.toString() ?? json['type']?.toString() ?? 'update',
      actor: json['actor']?.toString(),
      note: json['note']?.toString() ?? json['message']?.toString(),
      at: DateTime.tryParse(
        (json['at'] ?? json['createdAt'] ?? json['timestamp'])?.toString() ??
            '',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'status': status,
      if (actor != null) 'actor': actor,
      if (note != null) 'note': note,
      if (at != null) 'at': at!.toIso8601String(),
    };
  }
}

class TradeOrderDto {
  final String id;
  final String? productId;
  final String? buyerId;
  final String? sellerId;
  final String status;
  final List<TradeOrderTimelineEntryDto> timeline;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TradeOrderDto({
    required this.id,
    required this.productId,
    required this.buyerId,
    required this.sellerId,
    required this.status,
    required this.timeline,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TradeOrderDto.fromJson(Map<String, dynamic> json) {
    final timelineRaw = json['timeline'] as List? ?? const <dynamic>[];
    return TradeOrderDto(
      id: (json['orderId'] ?? json['id'] ?? json['_id'] ?? '').toString(),
      productId: json['productId']?.toString(),
      buyerId: json['buyerId']?.toString(),
      sellerId: json['sellerId']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      timeline: timelineRaw
          .whereType<Map>()
          .map((item) => TradeOrderTimelineEntryDto.fromJson(_map(item)))
          .toList(growable: false),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'productId': productId,
      'buyerId': buyerId,
      'sellerId': sellerId,
      'status': status,
      'timeline': timeline.map((item) => item.toJson()).toList(growable: false),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}

class TradeTransactionDto {
  final String id;
  final String? productId;
  final String? buyerId;
  final String? sellerId;
  final num amount;
  final String status;
  final bool buyerConfirmed;
  final bool sellerConfirmed;
  final String? disputeReason;
  final DateTime? createdAt;

  const TradeTransactionDto({
    required this.id,
    required this.productId,
    required this.buyerId,
    required this.sellerId,
    required this.amount,
    required this.status,
    required this.buyerConfirmed,
    required this.sellerConfirmed,
    required this.disputeReason,
    required this.createdAt,
  });

  factory TradeTransactionDto.fromJson(Map<String, dynamic> json) {
    return TradeTransactionDto(
      id:
          (json['txnId'] ??
                  json['transactionId'] ??
                  json['id'] ??
                  json['_id'] ??
                  '')
              .toString(),
      productId: json['productId']?.toString(),
      buyerId: json['buyerId']?.toString(),
      sellerId: json['sellerId']?.toString(),
      amount: json['amount'] as num? ?? json['tokenAmount'] as num? ?? 0,
      status: json['status']?.toString() ?? 'pending',
      buyerConfirmed: json['buyerConfirmed'] == true,
      sellerConfirmed: json['sellerConfirmed'] == true,
      disputeReason: json['disputeReason']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'txnId': id,
      'productId': productId,
      'buyerId': buyerId,
      'sellerId': sellerId,
      'amount': amount,
      'status': status,
      'buyerConfirmed': buyerConfirmed,
      'sellerConfirmed': sellerConfirmed,
      if (disputeReason != null) 'disputeReason': disputeReason,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}

Map<String, dynamic> _map(Map<dynamic, dynamic> input) {
  return input.map((key, value) => MapEntry(key.toString(), value));
}
