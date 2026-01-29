import 'package:neobazaar/core/state/async_status.dart';

class PaginatedState<T> {
  final AsyncStatus status;
  final List<T> items;
  final String? errorMessage;
  final int page;
  final int limit;
  final bool hasMore;

  const PaginatedState({
    this.status = AsyncStatus.initial,
    this.items = const [],
    this.errorMessage,
    this.page = 1,
    this.limit = 20,
    this.hasMore = true,
  });

  PaginatedState<T> copyWith({
    AsyncStatus? status,
    List<T>? items,
    String? errorMessage,
    int? page,
    int? limit,
    bool? hasMore,
  }) {
    return PaginatedState<T>(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
