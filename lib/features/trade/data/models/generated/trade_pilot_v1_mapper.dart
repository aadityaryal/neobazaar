import 'package:neobazaar/features/trade/data/models/generated/trade_pilot_v1_dto.dart';

class TradePilotV1Mapper {
  TradePilotV1Mapper._();

  static Map<String, dynamic> transactionToMap(Map<String, dynamic> source) {
    final dto = TradeTransactionDto.fromJson(source);
    return <String, dynamic>{
      ...source,
      ...dto.toJson(),
      '_id': dto.id,
      'id': dto.id,
      'transactionId': dto.id,
    };
  }

  static List<Map<String, dynamic>> transactionListToMap(
    List<Map<String, dynamic>> source,
  ) {
    return source.map(transactionToMap).toList(growable: false);
  }

  static Map<String, dynamic> offerToMap(Map<String, dynamic> source) {
    final dto = TradeOfferDto.fromJson(source);
    return <String, dynamic>{
      ...source,
      ...dto.toJson(),
      '_id': dto.id,
      'id': dto.id,
      'offerId': dto.id,
    };
  }

  static List<Map<String, dynamic>> offerListToMap(
    List<Map<String, dynamic>> source,
  ) {
    return source.map(offerToMap).toList(growable: false);
  }

  static Map<String, dynamic> orderToMap(Map<String, dynamic> source) {
    final dto = TradeOrderDto.fromJson(source);
    return <String, dynamic>{
      ...source,
      ...dto.toJson(),
      '_id': dto.id,
      'id': dto.id,
      'orderId': dto.id,
    };
  }

  static List<Map<String, dynamic>> orderListToMap(
    List<Map<String, dynamic>> source,
  ) {
    return source.map(orderToMap).toList(growable: false);
  }

  static List<Map<String, dynamic>> orderTimelineToMap(
    List<Map<String, dynamic>> source,
  ) {
    return source
        .map(TradeOrderTimelineEntryDto.fromJson)
        .map((dto) => dto.toJson())
        .toList(growable: false);
  }
}
