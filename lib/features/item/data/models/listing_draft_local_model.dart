import 'dart:convert';

import 'package:neobazaar/features/item/data/models/listing_media_local_model.dart';

class ListingDraftLocalModel {
  final String draftId;
  final String title;
  final String description;
  final num price;
  final String? category;
  final String? location;
  final String? mode;
  final List<ListingMediaLocalModel> media;
  final Map<String, dynamic>? aiSummary;
  final DateTime updatedAt;

  const ListingDraftLocalModel({
    required this.draftId,
    this.title = '',
    this.description = '',
    this.price = 0,
    this.category,
    this.location,
    this.mode,
    this.media = const <ListingMediaLocalModel>[],
    this.aiSummary,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'draftId': draftId,
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'location': location,
      'mode': mode,
      'media': media.map((item) => item.toJson()).toList(),
      'aiSummary': aiSummary,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ListingDraftLocalModel.fromJson(Map<String, dynamic> json) {
    return ListingDraftLocalModel(
      draftId: json['draftId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: json['price'] as num? ?? 0,
      category: json['category']?.toString(),
      location: json['location']?.toString(),
      mode: json['mode']?.toString(),
      media:
          (json['media'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(ListingMediaLocalModel.fromJson)
              .toList() ??
          <ListingMediaLocalModel>[],
      aiSummary: (json['aiSummary'] as Map?)?.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  String toStorageValue() => jsonEncode(toJson());

  factory ListingDraftLocalModel.fromStorageValue(String value) {
    final json = jsonDecode(value) as Map<String, dynamic>;
    return ListingDraftLocalModel.fromJson(json);
  }
}
