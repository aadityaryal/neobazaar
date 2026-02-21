import 'package:neobazaar/features/item/domain/entities/product_entity.dart';

class LocalProductState {
  final Set<String> bookmarkedProductIds;
  final List<ProductEntity> recentlyViewed;
  final List<ProductEntity> compareShortlist;

  const LocalProductState({
    this.bookmarkedProductIds = const <String>{},
    this.recentlyViewed = const <ProductEntity>[],
    this.compareShortlist = const <ProductEntity>[],
  });

  LocalProductState copyWith({
    Set<String>? bookmarkedProductIds,
    List<ProductEntity>? recentlyViewed,
    List<ProductEntity>? compareShortlist,
  }) {
    return LocalProductState(
      bookmarkedProductIds: bookmarkedProductIds ?? this.bookmarkedProductIds,
      recentlyViewed: recentlyViewed ?? this.recentlyViewed,
      compareShortlist: compareShortlist ?? this.compareShortlist,
    );
  }
}
