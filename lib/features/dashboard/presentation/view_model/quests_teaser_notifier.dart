import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/api/api_client.dart';
import 'package:neobazaar/core/api/api_endpoints.dart';
import 'package:neobazaar/core/state/async_status.dart';

class QuestsTeaserState {
  final AsyncStatus status;
  final List<Map<String, dynamic>> items;
  final String? errorMessage;

  const QuestsTeaserState({
    this.status = AsyncStatus.initial,
    this.items = const <Map<String, dynamic>>[],
    this.errorMessage,
  });

  QuestsTeaserState copyWith({
    AsyncStatus? status,
    List<Map<String, dynamic>>? items,
    String? errorMessage,
  }) {
    return QuestsTeaserState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final questsTeaserNotifierProvider =
    NotifierProvider<QuestsTeaserNotifier, QuestsTeaserState>(
      QuestsTeaserNotifier.new,
    );

class QuestsTeaserNotifier extends Notifier<QuestsTeaserState> {
  late final ApiClient _apiClient;

  @override
  QuestsTeaserState build() {
    _apiClient = ref.read(apiClientProvider);
    return const QuestsTeaserState();
  }

  Future<void> fetchActiveTeasers() async {
    state = state.copyWith(status: AsyncStatus.loading, errorMessage: null);

    try {
      final response = await _apiClient.get(ApiEndpoints.quests);
      final parsed = _apiClient.parseDataEnvelope<List<Map<String, dynamic>>>(
        response,
        (data) {
          final list = data is List ? data : <dynamic>[];
          return list
              .whereType<Map>()
              .map((item) => item.map((k, v) => MapEntry(k.toString(), v)))
              .toList();
        },
      );

      state = state.copyWith(status: AsyncStatus.success, items: parsed);
    } catch (e) {
      state = state.copyWith(
        status: AsyncStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}
