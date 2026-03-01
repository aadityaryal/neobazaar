import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/api/api_client.dart';
import 'package:neobazaar/core/api/api_endpoints.dart';
import 'package:neobazaar/core/models/offline_mutation.dart';
import 'package:neobazaar/core/services/connectivity/network_info.dart';
import 'package:neobazaar/core/services/sync/offline_mutation_queue_store.dart';

final offlineQueueReplayWorkerProvider = Provider<OfflineQueueReplayWorker>((
  ref,
) {
  return OfflineQueueReplayWorker(
    queueStore: ref.read(offlineMutationQueueStoreProvider),
    apiClient: ref.read(apiClientProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class OfflineQueueReplayWorker {
  final OfflineMutationQueueStore queueStore;
  final ApiClient apiClient;
  final INetworkInfo networkInfo;

  OfflineQueueReplayWorker({
    required this.queueStore,
    required this.apiClient,
    required this.networkInfo,
  });

  Future<void> replayPendingMutations() async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      return;
    }

    final pending = await queueStore.listPending();

    for (final mutation in pending) {
      final succeeded = await _replaySingleMutation(mutation);
      if (succeeded) {
        await queueStore.remove(mutation.id);
      }
    }
  }

  Future<void> onAppResumed() async {
    await replayPendingMutations();
  }

  Future<bool> _replaySingleMutation(OfflineMutation mutation) async {
    try {
      await apiClient.dio.request(
        mutation.path,
        data: mutation.body,
        queryParameters: mutation.queryParameters,
        options: Options(method: mutation.method, headers: mutation.headers),
      );
      return true;
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;

      if (statusCode == 409) {
        return _resolveConflict(mutation, error.response?.data);
      }

      if (statusCode != null && statusCode >= 400 && statusCode < 500) {
        return true;
      }

      final updated = mutation.copyWith(
        attemptCount: mutation.attemptCount + 1,
        updatedAt: DateTime.now(),
      );
      await queueStore.update(updated);
      return false;
    }
  }

  Future<bool> _resolveConflict(
    OfflineMutation mutation,
    dynamic conflictPayload,
  ) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.syncResolve,
        data: <String, dynamic>{
          'mutationId': mutation.id,
          'idempotencyKey': mutation.idempotencyKey,
          'path': mutation.path,
          'method': mutation.method,
          'payload': mutation.body,
          'conflict': conflictPayload,
        },
      );

      final statusCode = response.statusCode ?? 500;
      return statusCode >= 200 && statusCode < 300;
    } catch (_) {
      final updated = mutation.copyWith(
        attemptCount: mutation.attemptCount + 1,
        updatedAt: DateTime.now(),
      );
      await queueStore.update(updated);
      return false;
    }
  }
}
