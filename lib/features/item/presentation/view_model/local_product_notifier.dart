import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/providers/shared_prefs_provider.dart';
import 'package:neobazaar/features/item/domain/entities/product_entity.dart';
import 'package:neobazaar/features/item/presentation/state/local_product_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localProductNotifierProvider =
    NotifierProvider<LocalProductNotifier, LocalProductState>(
      LocalProductNotifier.new,
    );

class LocalProductNotifier extends Notifier<LocalProductState> {
  static const String _bookmarkKey = 'product_bookmarks';
  static const String _recentlyViewedKey = 'product_recently_viewed';
  static const String _compareShortlistKey = 'product_compare_shortlist';

  late final SharedPreferences _sharedPreferences;

  @override
  LocalProductState build() {
    _sharedPreferences = ref.read(sharedPreferencesProvider);
    return LocalProductState(
      bookmarkedProductIds:
          (_sharedPreferences.getStringList(_bookmarkKey) ?? const <String>[])
              .toSet(),
      recentlyViewed: _decodeProducts(
        _sharedPreferences.getStringList(_recentlyViewedKey),
      ),
      compareShortlist: _decodeProducts(
        _sharedPreferences.getStringList(_compareShortlistKey),
      ),
    );
  }

  Future<void> toggleBookmark(String productId) async {
    final updated = <String>{...state.bookmarkedProductIds};
    if (updated.contains(productId)) {
      updated.remove(productId);
    } else {
      updated.add(productId);
    }

    await _sharedPreferences.setStringList(_bookmarkKey, updated.toList());
    state = state.copyWith(bookmarkedProductIds: updated);
  }

  bool isBookmarked(String productId) {
    return state.bookmarkedProductIds.contains(productId);
  }

  Future<void> addRecentlyViewed(ProductEntity product) async {
    final merged = <ProductEntity>[
      product,
      ...state.recentlyViewed.where((item) => item.id != product.id),
    ].take(20).toList();

    await _sharedPreferences.setStringList(
      _recentlyViewedKey,
      _encodeProducts(merged),
    );
    state = state.copyWith(recentlyViewed: merged);
  }

  Future<void> toggleCompare(ProductEntity product) async {
    final exists = state.compareShortlist.any((item) => item.id == product.id);

    final updated = exists
        ? state.compareShortlist.where((item) => item.id != product.id).toList()
        : <ProductEntity>[...state.compareShortlist, product];

    await _sharedPreferences.setStringList(
      _compareShortlistKey,
      _encodeProducts(updated),
    );
    state = state.copyWith(compareShortlist: updated);
  }

  bool isCompared(String productId) {
    return state.compareShortlist.any((item) => item.id == productId);
  }

  Future<void> clearCompare() async {
    await _sharedPreferences.setStringList(
      _compareShortlistKey,
      const <String>[],
    );
    state = state.copyWith(compareShortlist: const <ProductEntity>[]);
  }

  List<String> _encodeProducts(List<ProductEntity> products) {
    return products.map((product) => jsonEncode(_toJson(product))).toList();
  }

  List<ProductEntity> _decodeProducts(List<String>? raw) {
    if (raw == null || raw.isEmpty) {
      return const <ProductEntity>[];
    }

    final output = <ProductEntity>[];
    for (final item in raw) {
      try {
        final json = jsonDecode(item) as Map<String, dynamic>;
        output.add(_fromJson(json));
      } catch (_) {}
    }
    return output;
  }

  Map<String, dynamic> _toJson(ProductEntity product) {
    return <String, dynamic>{
      'id': product.id,
      'title': product.title,
      'description': product.description,
      'price': product.price,
      'category': product.category,
      'location': product.location,
      'mode': product.mode,
      'imageUrls': product.imageUrls,
      'sellerId': product.sellerId,
      'aiSuggestedPrice': product.aiSuggestedPrice,
      'aiCondition': product.aiCondition,
      'aiConfidence': product.aiConfidence,
      'aiVerified': product.aiVerified,
      'flagged': product.flagged,
      'createdAt': product.createdAt?.toIso8601String(),
      'updatedAt': product.updatedAt?.toIso8601String(),
    };
  }

  ProductEntity _fromJson(Map<String, dynamic> json) {
    return ProductEntity(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: json['price'] as num? ?? 0,
      category: json['category']?.toString(),
      location: json['location']?.toString(),
      mode: json['mode']?.toString(),
      imageUrls:
          (json['imageUrls'] as List?)
              ?.map((item) => item.toString())
              .toList() ??
          const <String>[],
      sellerId: json['sellerId']?.toString(),
      aiSuggestedPrice: json['aiSuggestedPrice'] as num?,
      aiCondition: json['aiCondition']?.toString(),
      aiConfidence: json['aiConfidence'] as num?,
      aiVerified: json['aiVerified'] == true,
      flagged: json['flagged'] == true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }
}
