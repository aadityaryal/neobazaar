import 'dart:async';
import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neobazaar/core/services/analytics/analytics_service.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/item/data/datasources/local/listing_draft_local_store.dart';
import 'package:neobazaar/features/item/data/models/listing_draft_local_model.dart';
import 'package:neobazaar/features/item/data/models/listing_media_local_model.dart';
import 'package:neobazaar/features/item/domain/usecases/create_product_usecase.dart';
import 'package:neobazaar/features/item/domain/usecases/detect_condition_usecase.dart';
import 'package:neobazaar/features/item/domain/usecases/fraud_precheck_usecase.dart';
import 'package:neobazaar/features/item/domain/usecases/price_suggestion_usecase.dart';
import 'package:neobazaar/features/item/presentation/state/listing_composer_state.dart';
import 'package:path/path.dart' as path_util;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

final listingComposerNotifierProvider =
    NotifierProvider<ListingComposerNotifier, ListingComposerState>(
      ListingComposerNotifier.new,
    );

class ListingComposerNotifier extends Notifier<ListingComposerState> {
  static const String _defaultDraftId = 'listing-draft-current';

  late final DetectConditionUsecase _detectConditionUsecase;
  late final PriceSuggestionUsecase _priceSuggestionUsecase;
  late final FraudPrecheckUsecase _fraudPrecheckUsecase;
  late final CreateProductUsecase _createProductUsecase;
  late final ListingDraftLocalStore _listingDraftLocalStore;
  late final AnalyticsService _analyticsService;
  late final ImagePicker _imagePicker;
  late final Uuid _uuid;

  @override
  ListingComposerState build() {
    _detectConditionUsecase = ref.read(detectConditionUsecaseProvider);
    _priceSuggestionUsecase = ref.read(priceSuggestionUsecaseProvider);
    _fraudPrecheckUsecase = ref.read(fraudPrecheckUsecaseProvider);
    _createProductUsecase = ref.read(createProductUsecaseProvider);
    _listingDraftLocalStore = ref.read(listingDraftLocalStoreProvider);
    _analyticsService = ref.read(analyticsServiceProvider);
    _imagePicker = ImagePicker();
    _uuid = const Uuid();
    return const ListingComposerState();
  }

  void updateDraftFields({
    String? title,
    String? description,
    num? price,
    String? category,
    String? location,
    String? mode,
  }) {
    final draft = _ensureDraft();
    final updated = ListingDraftLocalModel(
      draftId: draft.draftId,
      title: title ?? draft.title,
      description: description ?? draft.description,
      price: price ?? draft.price,
      category: category ?? draft.category,
      location: location ?? draft.location,
      mode: mode ?? draft.mode,
      media: draft.media,
      aiSummary: draft.aiSummary,
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(draft: updated);
  }

  Future<void> pickMedia() async {
    final pickedImages = await _imagePicker.pickMultiImage();
    if (pickedImages.isEmpty) {
      _analyticsService.track('listing_media_pick_skipped');
      return;
    }

    final draft = _ensureDraft();
    final existingMedia = List<ListingMediaLocalModel>.from(draft.media);
    final newMedia = <ListingMediaLocalModel>[];

    for (final file in pickedImages) {
      final media = await _compressAndMapMedia(file);
      newMedia.add(media);
    }

    final updated = ListingDraftLocalModel(
      draftId: draft.draftId,
      title: draft.title,
      description: draft.description,
      price: draft.price,
      category: draft.category,
      location: draft.location,
      mode: draft.mode,
      media: <ListingMediaLocalModel>[...existingMedia, ...newMedia],
      aiSummary: draft.aiSummary,
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(draft: updated, errorMessage: null);
    _analyticsService.track(
      'listing_media_picked',
      properties: {
        'addedCount': newMedia.length,
        'totalCount': updated.media.length,
      },
    );
  }

  Future<void> analyzeWithAi() async {
    final draft = _ensureDraft();
    state = state.copyWith(
      status: AsyncStatus.loading,
      errorMessage: null,
      aiSummary: null,
      createdProductId: null,
      fallbackUsed: false,
    );

    final imagePaths = draft.media
        .map((item) => item.compressedPath)
        .where((path) => path.isNotEmpty)
        .toList();
    final primaryImage = imagePaths.isNotEmpty ? imagePaths.first : '';
    final primaryImageHash = primaryImage.isNotEmpty
      ? primaryImage.hashCode.toString()
      : '';

    if (primaryImage.isEmpty) {
      _applyAiFallback(draft: draft, reason: 'At least one image is required for AI analysis');
      return;
    }

    final fraudResult = await _fraudPrecheckUsecase(
      FraudPrecheckParams(
        payload: <String, dynamic>{
          'productId': draft.draftId,
          'imageHash': primaryImageHash,
        },
      ),
    );

    final isDuplicate = fraudResult.fold<bool>(
      (_) => false,
      (fraudPayload) => _isDuplicateListing(fraudPayload),
    );

    if (isDuplicate) {
      _analyticsService.track(
        'listing_duplicate_detected',
        properties: {'draftId': draft.draftId},
      );
      state = state.copyWith(
        status: AsyncStatus.error,
        errorMessage: 'Duplicate Listing Detected',
      );
      return;
    }

    final detectResult = await _detectConditionUsecase(
      DetectConditionParams(
        payload: <String, dynamic>{
          'productId': draft.draftId,
          'image': primaryImage,
        },
      ),
    );

    final detectPayload = detectResult.fold<Map<String, dynamic>?>((failure) {
      _analyticsService.track(
        'listing_ai_detect_error',
        properties: {'draftId': draft.draftId, 'message': failure.message},
      );
      _applyAiFallback(draft: draft, reason: failure.message);
      return null;
    }, (payload) => payload);

    if (detectPayload == null) {
      return;
    }

    final priceResult = await _priceSuggestionUsecase(
      PriceSuggestionParams(
        payload: <String, dynamic>{
          'productId': draft.draftId,
          'category': draft.category ?? 'electronics',
          'condition':
              (detectPayload['condition'] ?? 'good').toString(),
          'location': (draft.location == null || draft.location!.isEmpty)
              ? 'kathmandu'
              : draft.location,
        },
      ),
    );

    priceResult.fold(
      (failure) {
        _analyticsService.track(
          'listing_ai_price_error',
          properties: {'draftId': draft.draftId, 'message': failure.message},
        );
        _applyAiFallback(draft: draft, reason: failure.message);
      },
      (pricePayload) {
        final aiSummary = <String, dynamic>{
          'detect': detectPayload,
          'price': pricePayload,
        };

        final suggestedPrice =
          (pricePayload['aiSuggestedPrice'] ??
            pricePayload['suggestedPrice'] ??
            pricePayload['price']) as num?;
        final suggestedCategory = _deriveCategoryFromDetect(detectPayload);
        final resolvedCategory =
            (draft.category == null || draft.category!.isEmpty)
            ? suggestedCategory
            : draft.category;

        final updatedDraft = ListingDraftLocalModel(
          draftId: draft.draftId,
          title: draft.title,
          description: draft.description,
          price: suggestedPrice ?? draft.price,
          category: resolvedCategory,
          location: draft.location,
          mode: draft.mode,
          media: draft.media,
          aiSummary: aiSummary,
          updatedAt: DateTime.now(),
        );

        state = state.copyWith(
          status: AsyncStatus.success,
          draft: updatedDraft,
          aiSummary: aiSummary,
          errorMessage: null,
          fallbackUsed: false,
        );
        _analyticsService.track(
          'listing_ai_analysis_success',
          properties: {
            'draftId': updatedDraft.draftId,
            'hasSuggestedPrice': suggestedPrice != null,
            'category': updatedDraft.category,
          },
        );
      },
    );
  }

  Future<void> submitListing() async {
    final draft = state.draft;
    if (draft == null) {
      _analyticsService.track(
        'listing_submit_error',
        properties: {'reason': 'missing_draft'},
      );
      state = state.copyWith(
        status: AsyncStatus.error,
        errorMessage: 'No draft available to submit',
      );
      return;
    }

    final title = draft.title.trim();
    final description = draft.description.trim();
    final category = draft.category?.trim();
    final location = draft.location?.trim();
    final mode = draft.mode?.trim();
    final priceListed = draft.price.round();

    if (title.isEmpty ||
        description.isEmpty ||
        category == null ||
        category.isEmpty ||
        location == null ||
        location.isEmpty ||
        mode == null ||
        mode.isEmpty ||
        priceListed < 0) {
      _analyticsService.track(
        'listing_submit_error',
        properties: {
          'reason': 'missing_required_fields',
          'hasTitle': title.isNotEmpty,
          'hasDescription': description.isNotEmpty,
          'hasCategory': category != null && category.isNotEmpty,
          'hasLocation': location != null && location.isNotEmpty,
          'hasMode': mode != null && mode.isNotEmpty,
          'priceListed': priceListed,
        },
      );
      state = state.copyWith(
        status: AsyncStatus.error,
        errorMessage:
            'Please complete title, description, category, location, mode, and a valid price.',
      );
      return;
    }

    state = state.copyWith(
      status: AsyncStatus.loading,
      errorMessage: null,
      createdProductId: null,
    );

    final detect = state.aiSummary?['detect'] as Map<String, dynamic>?;
    final price = state.aiSummary?['price'] as Map<String, dynamic>?;

    final payload = <String, dynamic>{
      'title': title,
      'description': description,
      'priceListed': priceListed,
      'category': category,
      'location': location,
      'mode': mode,
      'images': draft.media
          .map((item) => item.compressedPath)
          .where((path) => path.isNotEmpty)
          .toList(),
      if (price != null)
        'aiSuggestedPrice': price['suggestedPrice'] ?? price['price'],
      if (detect != null)
        'aiCondition':
            detect['condition'] ?? detect['category'] ?? detect['label'],
      if (detect != null)
        'aiConfidence': detect['confidence'] ?? detect['score'],
      'aiVerified': state.fallbackUsed ? false : true,
    };

    final result = await _createProductUsecase(
      CreateProductParams(payload: payload),
    );

    result.fold(
      (failure) {
        _analyticsService.track(
          'listing_submit_error',
          properties: {'draftId': draft.draftId, 'message': failure.message},
        );
        state = state.copyWith(
          status: AsyncStatus.error,
          errorMessage: failure.message,
        );
      },
      (product) {
        unawaited(_listingDraftLocalStore.clearDraft(draft.draftId));
        _analyticsService.track(
          'listing_submit_success',
          properties: {
            'draftId': draft.draftId,
            'productId': product.id,
            'price': draft.price,
            'mediaCount': draft.media.length,
          },
        );
        state = state.copyWith(
          status: AsyncStatus.success,
          draft: null,
          aiSummary: null,
          errorMessage: null,
          createdProductId: product.id,
        );
      },
    );
  }

  Future<void> saveDraftOnPause() async {
    final draft = state.draft;
    if (draft == null) {
      return;
    }
    await _listingDraftLocalStore.saveDraft(draft);
  }

  Future<ListingDraftLocalModel?> restoreDraftOnResume() async {
    try {
      final restored = await _listingDraftLocalStore.getDraft(_defaultDraftId);
      if (restored == null) {
        return null;
      }

      state = state.copyWith(
        draft: restored,
        aiSummary: restored.aiSummary,
        errorMessage: null,
      );
      return restored;
    } catch (_) {
      return null;
    }
  }

  ListingDraftLocalModel _ensureDraft() {
    final existing = state.draft;
    if (existing != null) {
      return existing;
    }

    final created = ListingDraftLocalModel(
      draftId: _defaultDraftId,
      updatedAt: DateTime.now(),
    );
    state = state.copyWith(draft: created);
    return created;
  }

  Future<ListingMediaLocalModel> _compressAndMapMedia(XFile file) async {
    final original = File(file.path);
    final originalBytes = await original.length();

    final tempDir = await getTemporaryDirectory();
    final extension = path_util.extension(file.path).toLowerCase();
    final targetPath = path_util.join(
      tempDir.path,
      '${_uuid.v4()}_compressed${extension.isEmpty ? '.jpg' : extension}',
    );

    final compressed = await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      quality: 72,
      minWidth: 1280,
      minHeight: 1280,
    );

    final compressedPath = compressed?.path ?? file.path;
    final compressedBytes = await File(compressedPath).length();

    return ListingMediaLocalModel(
      id: _uuid.v4(),
      originalPath: file.path,
      compressedPath: compressedPath,
      originalBytes: originalBytes,
      compressedBytes: compressedBytes,
      width: 0,
      height: 0,
      mimeType: extension == '.png' ? 'image/png' : 'image/jpeg',
      createdAt: DateTime.now(),
    );
  }

  String? _deriveCategoryFromDetect(Map<String, dynamic> detectPayload) {
    final rawCategory =
        (detectPayload['category'] ?? detectPayload['suggestedCategory'])
            ?.toString();
    if (rawCategory != null && rawCategory.isNotEmpty) {
      return rawCategory;
    }

    final condition = detectPayload['condition']?.toString().toLowerCase();
    if (condition == null || condition.isEmpty) {
      return null;
    }

    if (condition.contains('electronic') || condition.contains('phone')) {
      return 'electronics';
    }
    if (condition.contains('cloth') || condition.contains('fashion')) {
      return 'fashion';
    }
    if (condition.contains('vehicle') || condition.contains('bike')) {
      return 'vehicles';
    }
    return 'other';
  }

  bool _isDuplicateListing(Map<String, dynamic> payload) {
    final duplicateFlag =
        payload['duplicate'] == true ||
        payload['isDuplicate'] == true ||
        payload['flaggedAsDuplicate'] == true;
    if (duplicateFlag) {
      return true;
    }

    final code = payload['code']?.toString().toUpperCase();
    return code == 'DUPLICATE_LISTING' || code == 'DUPLICATE_LISTING_DETECTED';
  }

  void _applyAiFallback({
    required ListingDraftLocalModel draft,
    required String reason,
  }) {
    state = state.copyWith(
      status: AsyncStatus.success,
      draft: draft,
      aiSummary: <String, dynamic>{
        'source': 'fallback_proxy_unavailable',
        'reason': reason,
      },
      fallbackUsed: true,
      errorMessage:
          'AI unavailable at the moment. Continuing with manual listing details.',
    );
    _analyticsService.track(
      'listing_ai_fallback_used',
      properties: {'draftId': draft.draftId, 'reason': reason},
    );
  }
}
