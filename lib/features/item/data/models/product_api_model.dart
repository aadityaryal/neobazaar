import 'package:neobazaar/features/item/domain/entities/product_entity.dart';

class ProductApiModel {
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

  const ProductApiModel({
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

  factory ProductApiModel.fromJson(Map<String, dynamic> json) {
    return ProductApiModel(
      id: (json['productId'] ?? json['_id'] ?? json['id'] ?? '').toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['priceListed'] ?? json['price'] ?? json['amount']) as num? ?? 0,
      category: json['category']?.toString(),
      location: json['location']?.toString(),
      mode: json['mode']?.toString(),
      imageUrls:
          (json['images'] as List?)?.map((item) => item.toString()).toList() ??
          (json['imageUrls'] as List?)
              ?.map((item) => item.toString())
              .toList() ??
          <String>[],
      sellerId: (json['sellerId'] ?? json['seller']?['_id'])?.toString(),
      aiSuggestedPrice: json['aiSuggestedPrice'] as num?,
      aiCondition: json['aiCondition']?.toString(),
      aiConfidence: json['aiConfidence'] as num?,
      aiVerified: json['aiVerified'] == true,
      flagged: json['flagged'] == true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'location': location,
      'mode': mode,
      'images': imageUrls,
      'sellerId': sellerId,
      'aiSuggestedPrice': aiSuggestedPrice,
      'aiCondition': aiCondition,
      'aiConfidence': aiConfidence,
      'aiVerified': aiVerified,
      'flagged': flagged,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      title: title,
      description: description,
      price: price,
      category: category,
      location: location,
      mode: mode,
      imageUrls: imageUrls,
      sellerId: sellerId,
      aiSuggestedPrice: aiSuggestedPrice,
      aiCondition: aiCondition,
      aiConfidence: aiConfidence,
      aiVerified: aiVerified,
      flagged: flagged,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static List<ProductEntity> toEntityList(List<ProductApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
