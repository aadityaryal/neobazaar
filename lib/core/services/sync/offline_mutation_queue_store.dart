import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:neobazaar/core/constants/hive_table_constant.dart';
import 'package:neobazaar/core/models/offline_mutation.dart';

final offlineMutationQueueStoreProvider = Provider<OfflineMutationQueueStore>(
  (ref) => OfflineMutationQueueStore(),
);

class OfflineMutationQueueStore {
  Future<Box<String>> _box() async {
    if (Hive.isBoxOpen(HiveTableConstant.offlineMutationQueueTable)) {
      return Hive.box<String>(HiveTableConstant.offlineMutationQueueTable);
    }
    return Hive.openBox<String>(HiveTableConstant.offlineMutationQueueTable);
  }

  Future<void> enqueue(OfflineMutation mutation) async {
    final box = await _box();
    final hasDuplicate = box.values
        .map(OfflineMutation.fromStorageValue)
        .any((item) => item.idempotencyKey == mutation.idempotencyKey);

    if (hasDuplicate) {
      return;
    }

    await box.put(mutation.id, mutation.toStorageValue());
  }

  Future<List<OfflineMutation>> listPending() async {
    final box = await _box();
    final items = box.values.map(OfflineMutation.fromStorageValue).toList();
    items.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return items;
  }

  Future<void> remove(String id) async {
    final box = await _box();
    await box.delete(id);
  }

  Future<void> update(OfflineMutation mutation) async {
    final box = await _box();
    await box.put(mutation.id, mutation.toStorageValue());
  }

  Future<void> clear() async {
    final box = await _box();
    await box.clear();
  }
}
