import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/api/api_client.dart';
import 'package:neobazaar/core/api/api_endpoints.dart';
import 'package:neobazaar/features/chat/data/datasources/chat_datasource.dart';

final chatRemoteDatasourceProvider = Provider<IChatRemoteDatasource>((ref) {
  return ChatRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class ChatRemoteDatasource implements IChatRemoteDatasource {
  final ApiClient _apiClient;

  ChatRemoteDatasource({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<Map<String, dynamic>>> listMine({
    Map<String, dynamic>? query,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.chats,
      queryParameters: query,
    );
    return _apiClient.parseDataEnvelope<List<Map<String, dynamic>>>(
      response,
      _asListOfMaps,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> replay({
    Map<String, dynamic>? query,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.chatsReplay,
      queryParameters: query,
    );
    return _apiClient.parseDataEnvelope<List<Map<String, dynamic>>>(
      response,
      _asListOfMaps,
    );
  }

  @override
  Future<Map<String, dynamic>> createChat(Map<String, dynamic> payload) async {
    final response = await _apiClient.post(ApiEndpoints.chats, data: payload);
    return _apiClient.parseDataEnvelope<Map<String, dynamic>>(
      response,
      _asStringDynamicMap,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getMessages(
    String chatId, {
    Map<String, dynamic>? query,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.chatMessages(chatId),
      queryParameters: query,
    );
    return _apiClient.parseDataEnvelope<List<Map<String, dynamic>>>(
      response,
      _asListOfMaps,
    );
  }

  @override
  Future<Map<String, dynamic>> createMessage(
    String chatId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.chatMessages(chatId),
      data: payload,
    );
    return _apiClient.parseDataEnvelope<Map<String, dynamic>>(
      response,
      _asStringDynamicMap,
    );
  }

  @override
  Future<Map<String, dynamic>> markMessageRead(
    String chatId,
    String messageId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.chatReadReceipt(chatId, messageId),
      data: payload,
    );
    return _apiClient.parseDataEnvelope<Map<String, dynamic>>(
      response,
      _asStringDynamicMap,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> suggestReplies(
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.nlpSuggest,
      data: payload,
    );
    return _apiClient.parseDataEnvelope<List<Map<String, dynamic>>>(
      response,
      _asListOfMaps,
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
