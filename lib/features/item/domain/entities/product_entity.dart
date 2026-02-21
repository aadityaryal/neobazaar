import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final num price;
  final String? category;
  final String? location;
  final String? mode;
  final List<String> imageUrls;
  final String? sellerId;
  final num? aiSuggestedPrice;
  final String? aiCondition;
  final num? aiConfidence;
  final bool aiVerified;
  final bool flagged;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProductEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.category,
    this.location,
    this.mode,
    this.imageUrls = const <String>[],
    this.sellerId,
    this.aiSuggestedPrice,
    this.aiCondition,
    this.aiConfidence,
    this.aiVerified = false,
    this.flagged = false,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => <Object?>[
    id,
    title,
    description,
    price,
    category,
    location,
    mode,
    imageUrls,
    sellerId,
    aiSuggestedPrice,
    aiCondition,
    aiConfidence,
    aiVerified,
    flagged,
    createdAt,
    updatedAt,
  ];
}
