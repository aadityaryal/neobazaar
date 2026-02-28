import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/services/connectivity/network_info.dart';
import 'package:neobazaar/features/trade/data/datasources/remote/trade_remote_datasource.dart';
import 'package:neobazaar/features/trade/data/datasources/trade_datasource.dart';
import 'package:neobazaar/features/trade/data/models/generated/trade_pilot_v1_mapper.dart';
import 'package:neobazaar/features/trade/domain/repositories/trade_repository.dart';

final tradeRepositoryProvider = Provider<ITradeRepository>((ref) {
  return TradeRepositoryImpl(
    remoteDatasource: ref.read(tradeRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class TradeRepositoryImpl implements ITradeRepository {
  final ITradeRemoteDatasource _remoteDatasource;
  final INetworkInfo _networkInfo;

  TradeRepositoryImpl({
    required ITradeRemoteDatasource remoteDatasource,
    required INetworkInfo networkInfo,
  }) : _remoteDatasource = remoteDatasource,
       _networkInfo = networkInfo;

  Future<Either<Failure, T>> _run<T>(Future<T> Function() operation) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        ApiFailure(message: 'Trade operations require network connectivity'),
      );
    }

    try {
      final result = await operation();
      return Right(result);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message:
              e.response?.data?['message']?.toString() ??
              'Trade request failed',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createTransaction(
    Map<String, dynamic> payload,
  ) {
    return _run(() async {
      final data = await _remoteDatasource.createTransaction(payload);
      return TradePilotV1Mapper.transactionToMap(data);
    });
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> listTransactions({
    Map<String, dynamic>? query,
  }) {
    return _run(() async {
      final items = await _remoteDatasource.listTransactions(query: query);
      return TradePilotV1Mapper.transactionListToMap(items);
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> confirmTransaction(
    String txnId,
    Map<String, dynamic> payload,
  ) {
    return _run(() async {
      final data = await _remoteDatasource.confirmTransaction(txnId, payload);
      return TradePilotV1Mapper.transactionToMap(data);
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> disputeTransaction(
    String txnId,
    Map<String, dynamic> payload,
  ) {
    return _run(() async {
      final data = await _remoteDatasource.disputeTransaction(txnId, payload);
      return TradePilotV1Mapper.transactionToMap(data);
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> appendDisputeEvidence(
    String txnId,
    Map<String, dynamic> payload,
  ) {
    return _run(() async {
      final data = await _remoteDatasource.appendDisputeEvidence(
        txnId,
        payload,
      );
      return TradePilotV1Mapper.transactionToMap(data);
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> placeBid(
    Map<String, dynamic> payload,
  ) {
    return _run(() => _remoteDatasource.placeBid(payload));
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> listOffers({
    Map<String, dynamic>? query,
  }) {
    return _run(() async {
      final items = await _remoteDatasource.listOffers(query: query);
      return TradePilotV1Mapper.offerListToMap(items);
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createOffer(
    Map<String, dynamic> payload,
  ) {
    return _run(() async {
      final data = await _remoteDatasource.createOffer(payload);
      return TradePilotV1Mapper.offerToMap(data);
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> counterOffer(
    String offerId,
    Map<String, dynamic> payload,
  ) {
    return _run(() async {
      final data = await _remoteDatasource.counterOffer(offerId, payload);
      return TradePilotV1Mapper.offerToMap(data);
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> acceptOffer(
    String offerId,
    Map<String, dynamic> payload,
  ) {
    return _run(() async {
      final data = await _remoteDatasource.acceptOffer(offerId, payload);
      return TradePilotV1Mapper.offerToMap(data);
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> rejectOffer(
    String offerId,
    Map<String, dynamic> payload,
  ) {
    return _run(() async {
      final data = await _remoteDatasource.rejectOffer(offerId, payload);
      return TradePilotV1Mapper.offerToMap(data);
    });
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> listOrders({
    Map<String, dynamic>? query,
  }) {
    return _run(() async {
      final items = await _remoteDatasource.listOrders(query: query);
      return TradePilotV1Mapper.orderListToMap(items);
    });
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getOrderTimeline(
    String orderId,
  ) {
    return _run(() async {
      final timeline = await _remoteDatasource.getOrderTimeline(orderId);
      return TradePilotV1Mapper.orderTimelineToMap(timeline);
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> appendOrderTimeline(
    String orderId,
    Map<String, dynamic> payload,
  ) {
    return _run(() async {
      final data = await _remoteDatasource.appendOrderTimeline(
        orderId,
        payload,
      );
      return TradePilotV1Mapper.orderToMap(data);
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createReview(
    Map<String, dynamic> payload,
  ) {
    return _run(() => _remoteDatasource.createReview(payload));
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> listProductReviews(
    String productId,
  ) {
    return _run(() => _remoteDatasource.listProductReviews(productId));
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> flagReview(
    String reviewId,
    Map<String, dynamic> payload,
  ) {
    return _run(() => _remoteDatasource.flagReview(reviewId, payload));
  }
}
