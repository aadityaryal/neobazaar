import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:neobazaar/core/constants/hive_table_constant.dart';
import 'package:neobazaar/features/item/data/models/listing_draft_local_model.dart';

final listingDraftLocalStoreProvider = Provider<ListingDraftLocalStore>(
  (ref) => ListingDraftLocalStore(),
);

class ListingDraftLocalStore {
  Future<Box<String>> _box() async {
    if (Hive.isBoxOpen(HiveTableConstant.listingDraftTable)) {
      return Hive.box<String>(HiveTableConstant.listingDraftTable);
    }
    return Hive.openBox<String>(HiveTableConstant.listingDraftTable);
  }

  Future<void> saveDraft(ListingDraftLocalModel draft) async {
    final box = await _box();
    await box.put(draft.draftId, draft.toStorageValue());
  }

  Future<ListingDraftLocalModel?> getDraft(String draftId) async {
    final box = await _box();
    final value = box.get(draftId);
    if (value == null) {
      return null;
    }
    return ListingDraftLocalModel.fromStorageValue(value);
  }

  Future<void> clearDraft(String draftId) async {
    final box = await _box();
    await box.delete(draftId);
  }
}
