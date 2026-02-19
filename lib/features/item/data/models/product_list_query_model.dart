class ProductListQueryModel {
  final String? category;
  final String? location;
  final String? mode;
  final num? minPrice;
  final num? maxPrice;
  final String? sort;
  final int page;
  final int limit;

  const ProductListQueryModel({
    this.category,
    this.location,
    this.mode,
    this.minPrice,
    this.maxPrice,
    this.sort,
    this.page = 1,
    this.limit = 20,
  });

  Map<String, dynamic> toQueryParameters() {
    return <String, dynamic>{
      if (category != null && category!.isNotEmpty) 'category': category,
      if (location != null && location!.isNotEmpty) 'location': location,
      if (mode != null && mode!.isNotEmpty) 'mode': mode,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (sort != null && sort!.isNotEmpty) 'sort': sort,
      'page': page,
      'limit': limit,
    };
  }
}
