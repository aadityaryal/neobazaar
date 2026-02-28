import 'package:neobazaar/core/api/api_client.dart';
import 'package:neobazaar/core/api/api_endpoints.dart';
import 'package:neobazaar/features/trade/data/models/generated/trade_pilot_v1_dto.dart';

class TradePilotV1Client {
  final ApiClient _apiClient;

  TradePilotV1Client({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<TradeTransactionDto> createTransaction(
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.transactions,
      data: payload,
    );
    final data = _apiClient.parseDataEnvelope<Map<String, dynamic>>(
      response,
      _asMap,
    );
    return TradeTransactionDto.fromJson(data);
  }

  Future<List<TradeTransactionDto>> listTransactions({
    Map<String, dynamic>? query,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.transactions,
      queryParameters: query,
    );
    final data = _apiClient.parseDataEnvelope<List<Map<String, dynamic>>>(
      response,
      _asList,
    );
    return data.map(TradeTransactionDto.fromJson).toList(growable: false);
  }

  Future<TradeTransactionDto> confirmTransaction(
    String txnId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.transactionConfirm(txnId),
      data: payload,
    );
    final data = _apiClient.parseDataEnvelope<Map<String, dynamic>>(
      response,
      _asMap,
    );
    return TradeTransactionDto.fromJson(data);
  }

  Future<TradeTransactionDto> disputeTransaction(
    String txnId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.transactionDispute(txnId),
      data: payload,
    );
    final data = _apiClient.parseDataEnvelope<Map<String, dynamic>>(
      response,
      _asMap,
    );
    return TradeTransactionDto.fromJson(data);
  }

  Future<TradeTransactionDto> appendDisputeEvidence(
    String txnId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.transactionDisputeEvidence(txnId),
      data: payload,
    );
    final data = _apiClient.parseDataEnvelope<Map<String, dynamic>>(
      response,
      _asMap,
    );
    return TradeTransactionDto.fromJson(data);
  }

  Future<List<TradeOfferDto>> listOffers({Map<String, dynamic>? query}) async {
    final response = await _apiClient.get(
      ApiEndpoints.offers,
      queryParameters: query,
    );
    final data = _apiClient.parseDataEnvelope<List<Map<String, dynamic>>>(
      response,
      _asList,
    );
    return data.map(TradeOfferDto.fromJson).toList(growable: false);
  }

  Future<TradeOfferDto> createOffer(Map<String, dynamic> payload) async {
    final response = await _apiClient.post(ApiEndpoints.offers, data: payload);
    final data = _apiClient.parseDataEnvelope<Map<String, dynamic>>(
      response,
      _asMap,
    );
    return TradeOfferDto.fromJson(data);
  }

  Future<TradeOfferDto> counterOffer(
    String offerId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.offerCounter(offerId),
      data: payload,
    );
    final data = _apiClient.parseDataEnvelope<Map<String, dynamic>>(
      response,
      _asMap,
    );
    return TradeOfferDto.fromJson(data);
  }

  Future<TradeOfferDto> acceptOffer(
    String offerId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.offerAccept(offerId),
      data: payload,
    );
    final data = _apiClient.parseDataEnvelope<Map<String, dynamic>>(
      response,
      _asMap,
    );
    return TradeOfferDto.fromJson(data);
  }

  Future<TradeOfferDto> rejectOffer(
    String offerId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.offerReject(offerId),
      data: payload,
    );
    final data = _apiClient.parseDataEnvelope<Map<String, dynamic>>(
      response,
      _asMap,
    );
    return TradeOfferDto.fromJson(data);
  }

  Future<List<TradeOrderDto>> listOrders({Map<String, dynamic>? query}) async {
    final response = await _apiClient.get(
      ApiEndpoints.orders,
      queryParameters: query,
    );
    final data = _apiClient.parseDataEnvelope<List<Map<String, dynamic>>>(
      response,
      _asList,
    );
    return data.map(TradeOrderDto.fromJson).toList(growable: false);
  }

  Future<List<TradeOrderTimelineEntryDto>> getOrderTimeline(
    String orderId,
  ) async {
    final response = await _apiClient.get(ApiEndpoints.orderTimeline(orderId));
    final data = _apiClient.parseDataEnvelope<List<Map<String, dynamic>>>(
      response,
      _asList,
    );
    return data
        .map(TradeOrderTimelineEntryDto.fromJson)
        .toList(growable: false);
  }

  Future<TradeOrderDto> appendOrderTimeline(
    String orderId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.orderTimeline(orderId),
      data: payload,
    );
    final data = _apiClient.parseDataEnvelope<Map<String, dynamic>>(
      response,
      _asMap,
    );
    return TradeOrderDto.fromJson(data);
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{'value': data};
  }

  List<Map<String, dynamic>> _asList(dynamic data) {
    final list = data is List ? data : const <dynamic>[];
    return list
        .whereType<Map>()
        .map(
          (item) => item.map((key, value) => MapEntry(key.toString(), value)),
        )
        .toList(growable: false);
  }
}
