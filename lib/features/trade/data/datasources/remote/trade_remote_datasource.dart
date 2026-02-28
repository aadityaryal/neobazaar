import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/api/api_client.dart';
import 'package:neobazaar/core/api/api_endpoints.dart';
import 'package:neobazaar/features/trade/data/datasources/remote/trade_pilot_v1_client.dart';
import 'package:neobazaar/features/trade/data/datasources/trade_datasource.dart';

final tradeRemoteDatasourceProvider = Provider<ITradeRemoteDatasource>((ref) {
  return TradeRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class TradeRemoteDatasource implements ITradeRemoteDatasource {
  final ApiClient _apiClient;
  late final TradePilotV1Client _pilotClient;

  TradeRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient {
    _pilotClient = TradePilotV1Client(apiClient: _apiClient);
  }

  @override
  Future<Map<String, dynamic>> createTransaction(
    Map<String, dynamic> payload,
  ) async {
    final dto = await _pilotClient.createTransaction(payload);
    return dto.toJson();
  }

  @override
  Future<List<Map<String, dynamic>>> listTransactions({
    Map<String, dynamic>? query,
  }) async {
    final items = await _pilotClient.listTransactions(query: query);
    return items.map((item) => item.toJson()).toList(growable: false);
  }

  @override
  Future<Map<String, dynamic>> confirmTransaction(
    String txnId,
    Map<String, dynamic> payload,
  ) async {
    final dto = await _pilotClient.confirmTransaction(txnId, payload);
    return dto.toJson();
  }

  @override
  Future<Map<String, dynamic>> disputeTransaction(
    String txnId,
    Map<String, dynamic> payload,
  ) async {
    final dto = await _pilotClient.disputeTransaction(txnId, payload);
    return dto.toJson();
  }

  @override
  Future<Map<String, dynamic>> appendDisputeEvidence(
    String txnId,
    Map<String, dynamic> payload,
  ) async {
    final dto = await _pilotClient.appendDisputeEvidence(txnId, payload);
    return dto.toJson();
  }

  @override
  Future<Map<String, dynamic>> placeBid(Map<String, dynamic> payload) async {
    final response = await _apiClient.post(ApiEndpoints.bids, data: payload);
    return _apiClient.parseDataEnvelope<Map<String, dynamic>>(
      response,
      _asStringDynamicMap,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> listOffers({
    Map<String, dynamic>? query,
  }) async {
    final items = await _pilotClient.listOffers(query: query);
    return items.map((item) => item.toJson()).toList(growable: false);
  }

  @override
  Future<Map<String, dynamic>> createOffer(Map<String, dynamic> payload) async {
    final dto = await _pilotClient.createOffer(payload);
    return dto.toJson();
  }

  @override
  Future<Map<String, dynamic>> counterOffer(
    String offerId,
    Map<String, dynamic> payload,
  ) async {
    final dto = await _pilotClient.counterOffer(offerId, payload);
    return dto.toJson();
  }

  @override
  Future<Map<String, dynamic>> acceptOffer(
    String offerId,
    Map<String, dynamic> payload,
  ) async {
    final dto = await _pilotClient.acceptOffer(offerId, payload);
    return dto.toJson();
  }

  @override
  Future<Map<String, dynamic>> rejectOffer(
    String offerId,
    Map<String, dynamic> payload,
  ) async {
    final dto = await _pilotClient.rejectOffer(offerId, payload);
    return dto.toJson();
  }

  @override
  Future<List<Map<String, dynamic>>> listOrders({
    Map<String, dynamic>? query,
  }) async {
    final items = await _pilotClient.listOrders(query: query);
    return items.map((item) => item.toJson()).toList(growable: false);
  }

  @override
  Future<List<Map<String, dynamic>>> getOrderTimeline(String orderId) async {
    final items = await _pilotClient.getOrderTimeline(orderId);
    return items.map((item) => item.toJson()).toList(growable: false);
  }

  @override
  Future<Map<String, dynamic>> appendOrderTimeline(
    String orderId,
    Map<String, dynamic> payload,
  ) async {
    final dto = await _pilotClient.appendOrderTimeline(orderId, payload);
    return dto.toJson();
  }

  @override
  Future<Map<String, dynamic>> createReview(
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.post(ApiEndpoints.reviews, data: payload);
    return _apiClient.parseDataEnvelope<Map<String, dynamic>>(
      response,
      _asStringDynamicMap,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> listProductReviews(
    String productId,
  ) async {
    final response = await _apiClient.get(
      ApiEndpoints.reviewsByProduct(productId),
    );
    return _apiClient.parseDataEnvelope<List<Map<String, dynamic>>>(
      response,
      _asListOfMaps,
    );
  }

  @override
  Future<Map<String, dynamic>> flagReview(
    String reviewId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.patch(
      ApiEndpoints.reviewFlag(reviewId),
      data: payload,
    );
    return _apiClient.parseDataEnvelope<Map<String, dynamic>>(
      response,
      _asStringDynamicMap,
    );
  }

  Map<String, dynamic> _asStringDynamicMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{'value': data};
  }

  List<Map<String, dynamic>> _asListOfMaps(dynamic data) {
    final list = data is List ? data : <dynamic>[];
    return list
        .whereType<Map>()
        .map(
          (item) => item.map((key, value) => MapEntry(key.toString(), value)),
        )
        .toList();
  }
}
