class PaginationQuery {
  final int page;
  final int limit;
  final String? sortBy;
  final String? sortOrder;

  const PaginationQuery({
    this.page = 1,
    this.limit = 20,
    this.sortBy,
    this.sortOrder,
  });

  Map<String, dynamic> toQueryParameters() {
    final query = <String, dynamic>{'page': page, 'limit': limit};

    if (sortBy != null && sortBy!.isNotEmpty) {
      query['sortBy'] = sortBy;
    }

    if (sortOrder != null && sortOrder!.isNotEmpty) {
      query['sortOrder'] = sortOrder;
    }

    return query;
  }

  PaginationQuery copyWith({
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
  }) {
    return PaginationQuery(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

Map<String, dynamic> buildPaginationQuery({
  int page = 1,
  int limit = 20,
  String? sortBy,
  String? sortOrder,
  Map<String, dynamic>? extras,
}) {
  final query = PaginationQuery(
    page: page,
    limit: limit,
    sortBy: sortBy,
    sortOrder: sortOrder,
  ).toQueryParameters();

  if (extras != null && extras.isNotEmpty) {
    query.addAll(extras);
  }

  return query;
}
