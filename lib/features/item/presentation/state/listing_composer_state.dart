import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/item/data/models/listing_draft_local_model.dart';

class ListingComposerState {
  final AsyncStatus status;
  final ListingDraftLocalModel? draft;
  final String? errorMessage;
  final Map<String, dynamic>? aiSummary;
  final bool fallbackUsed;
  final String? createdProductId;

  const ListingComposerState({
    this.status = AsyncStatus.initial,
    this.draft,
    this.errorMessage,
    this.aiSummary,
    this.fallbackUsed = false,
    this.createdProductId,
  });

  ListingComposerState copyWith({
    AsyncStatus? status,
    Object? draft = _listingComposerSentinel,
    Object? errorMessage = _listingComposerSentinel,
    Object? aiSummary = _listingComposerSentinel,
    Object? createdProductId = _listingComposerSentinel,
    bool? fallbackUsed,
  }) {
    return ListingComposerState(
      status: status ?? this.status,
      draft: draft == _listingComposerSentinel
          ? this.draft
          : draft as ListingDraftLocalModel?,
      errorMessage: errorMessage == _listingComposerSentinel
          ? this.errorMessage
          : errorMessage as String?,
      aiSummary: aiSummary == _listingComposerSentinel
          ? this.aiSummary
          : aiSummary as Map<String, dynamic>?,
      createdProductId: createdProductId == _listingComposerSentinel
          ? this.createdProductId
          : createdProductId as String?,
      fallbackUsed: fallbackUsed ?? this.fallbackUsed,
    );
  }
}

const Object _listingComposerSentinel = Object();
