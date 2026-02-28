import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/trade/domain/entities/offer_entity.dart';

class OfferState {
  final AsyncStatus status;
  final AsyncStatus createStatus;
  final AsyncStatus mutateStatus;
  final List<OfferEntity> offers;
  final String? errorMessage;

  const OfferState({
    this.status = AsyncStatus.initial,
    this.createStatus = AsyncStatus.initial,
    this.mutateStatus = AsyncStatus.initial,
    this.offers = const <OfferEntity>[],
    this.errorMessage,
  });

  OfferState copyWith({
    AsyncStatus? status,
    AsyncStatus? createStatus,
    AsyncStatus? mutateStatus,
    List<OfferEntity>? offers,
    Object? errorMessage = _offerStateSentinel,
  }) {
    return OfferState(
      status: status ?? this.status,
      createStatus: createStatus ?? this.createStatus,
      mutateStatus: mutateStatus ?? this.mutateStatus,
      offers: offers ?? this.offers,
      errorMessage: errorMessage == _offerStateSentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

const Object _offerStateSentinel = Object();
