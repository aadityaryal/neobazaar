import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/services/analytics/analytics_service.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/trade/domain/entities/offer_entity.dart';
import 'package:neobazaar/features/trade/domain/usecases/accept_offer_usecase.dart';
import 'package:neobazaar/features/trade/domain/usecases/counter_offer_usecase.dart';
import 'package:neobazaar/features/trade/domain/usecases/create_offer_usecase.dart';
import 'package:neobazaar/features/trade/domain/usecases/list_offers_usecase.dart';
import 'package:neobazaar/features/trade/domain/usecases/reject_offer_usecase.dart';
import 'package:neobazaar/features/trade/presentation/state/offer_state.dart';

final offerNotifierProvider = NotifierProvider<OfferNotifier, OfferState>(
  OfferNotifier.new,
);

class OfferNotifier extends Notifier<OfferState> {
  late final ListOffersUsecase _listOffersUsecase;
  late final CreateOfferUsecase _createOfferUsecase;
  late final CounterOfferUsecase _counterOfferUsecase;
  late final AcceptOfferUsecase _acceptOfferUsecase;
  late final RejectOfferUsecase _rejectOfferUsecase;
  late final AnalyticsService _analyticsService;

  @override
  OfferState build() {
    _listOffersUsecase = ref.read(listOffersUsecaseProvider);
    _createOfferUsecase = ref.read(createOfferUsecaseProvider);
    _counterOfferUsecase = ref.read(counterOfferUsecaseProvider);
    _acceptOfferUsecase = ref.read(acceptOfferUsecaseProvider);
    _rejectOfferUsecase = ref.read(rejectOfferUsecaseProvider);
    _analyticsService = ref.read(analyticsServiceProvider);
    return const OfferState();
  }

  Future<void> fetchInbox() async {
    state = state.copyWith(status: AsyncStatus.loading, errorMessage: null);
    final result = await _listOffersUsecase(const ListOffersParams());

    result.fold(
      (failure) {
        _analyticsService.track(
          'offer_inbox_fetch_error',
          properties: {'message': failure.message},
        );
        state = state.copyWith(
          status: AsyncStatus.error,
          errorMessage: failure.message,
        );
      },
      (items) {
        final offers = items.map(_toEntity).toList();
        state = state.copyWith(
          status: AsyncStatus.success,
          offers: offers,
          errorMessage: null,
        );
        _analyticsService.track(
          'offer_inbox_fetch_success',
          properties: {'count': offers.length},
        );
      },
    );
  }

  Future<void> create({required String productId, required num amount}) async {
    state = state.copyWith(
      createStatus: AsyncStatus.loading,
      errorMessage: null,
    );
    final result = await _createOfferUsecase(
      CreateOfferParams(
        payload: <String, dynamic>{'productId': productId, 'amount': amount},
      ),
    );

    result.fold(
      (failure) {
        _analyticsService.track(
          'offer_create_error',
          properties: {
            'productId': productId,
            'amount': amount,
            'message': failure.message,
          },
        );
        state = state.copyWith(
          createStatus: AsyncStatus.error,
          errorMessage: failure.message,
        );
      },
      (payload) {
        final created = _toEntity(payload);
        state = state.copyWith(
          createStatus: AsyncStatus.success,
          offers: <OfferEntity>[created, ...state.offers],
          errorMessage: null,
        );
        _analyticsService.track(
          'offer_create_success',
          properties: {
            'offerId': created.id,
            'productId': created.productId,
            'amount': created.amount,
          },
        );
      },
    );
  }

  Future<void> counter({required String offerId, required num amount}) async {
    await _mutate(
      () => _counterOfferUsecase(
        CounterOfferParams(
          offerId: offerId,
          payload: <String, dynamic>{'counterAmount': amount},
        ),
      ),
      offerId,
    );
  }

  Future<void> accept({required String offerId}) async {
    await _mutate(
      () => _acceptOfferUsecase(AcceptOfferParams(offerId: offerId)),
      offerId,
    );
  }

  Future<void> reject({required String offerId}) async {
    await _mutate(
      () => _rejectOfferUsecase(RejectOfferParams(offerId: offerId)),
      offerId,
    );
  }

  Future<void> _mutate(
    Future<Either<Failure, Map<String, dynamic>>> Function() action,
    String offerId,
  ) async {
    state = state.copyWith(
      mutateStatus: AsyncStatus.loading,
      errorMessage: null,
    );
    final result = await action();
    result.fold(
      (failure) {
        _analyticsService.track(
          'offer_mutate_error',
          properties: {'offerId': offerId, 'message': failure.message},
        );
        state = state.copyWith(
          mutateStatus: AsyncStatus.error,
          errorMessage: failure.message,
        );
      },
      (payload) {
        final updated = _toEntity(payload);
        final offers = state.offers
            .map((item) => item.id == offerId ? updated : item)
            .toList();
        state = state.copyWith(
          mutateStatus: AsyncStatus.success,
          offers: offers,
          errorMessage: null,
        );
        _analyticsService.track(
          'offer_mutate_success',
          properties: {'offerId': updated.id, 'status': updated.status},
        );
      },
    );
  }

  OfferEntity _toEntity(Map<String, dynamic> json) {
    return OfferEntity(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      productId: json['productId']?.toString(),
      buyerId: json['buyerId']?.toString(),
      sellerId: json['sellerId']?.toString(),
      amount: json['amount'] as num? ?? 0,
      status: json['status']?.toString() ?? 'pending',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}
