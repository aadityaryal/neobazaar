import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/api/api_client.dart';
import 'package:neobazaar/core/api/api_endpoints.dart';
import 'package:neobazaar/features/item/data/datasources/extension_datasource.dart';

final extensionRemoteDatasourceProvider = Provider<IExtensionRemoteDatasource>((
  ref,
) {
  return ExtensionRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class ExtensionRemoteDatasource implements IExtensionRemoteDatasource {
  final ApiClient _apiClient;

  ExtensionRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<Map<String, dynamic>> detect(Map<String, dynamic> payload) async {
    return _postWithAliasFallback(
      primaryPath: ApiEndpoints.detect,
      aliasPath: ApiEndpoints.aiDetect,
      payload: payload,
    );
  }

  @override
  Future<Map<String, dynamic>> price(Map<String, dynamic> payload) async {
    return _postWithAliasFallback(
      primaryPath: ApiEndpoints.price,
      aliasPath: ApiEndpoints.aiPrice,
      payload: payload,
    );
  }

  @override
  Future<Map<String, dynamic>> fraud(Map<String, dynamic> payload) async {
    final response = await _apiClient.post(ApiEndpoints.fraud, data: payload);
    return _apiClient.parseDataEnvelope<Map<String, dynamic>>(
      response,
      (data) => _asStringDynamicMap(data),
    );
  }

  @override
  Future<Map<String, dynamic>> recommend({
    Map<String, dynamic>? queryOrBody,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.recommend,
        queryParameters: queryOrBody,
      );

      return _apiClient.parseDataEnvelope<Map<String, dynamic>>(
        response,
        (data) => _asStringDynamicMap(data),
      );
    } on DioException catch (error) {
      if (_shouldFallbackToAlias(error)) {
        final aliasResponse = await _apiClient.post(
          ApiEndpoints.aiRecommend,
          data: queryOrBody ?? const <String, dynamic>{},
        );
        return _apiClient.parseDataEnvelope<Map<String, dynamic>>(
          aliasResponse,
          (data) => _asStringDynamicMap(data),
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> nlpSuggest(Map<String, dynamic> payload) async {
    final response = await _apiClient.post(
      ApiEndpoints.nlpSuggest,
      data: payload,
    );
    return _apiClient.parseDataEnvelope<Map<String, dynamic>>(
      response,
      (data) => _asStringDynamicMap(data),
    );
  }

  Future<Map<String, dynamic>> _postWithAliasFallback({
    required String primaryPath,
    required String aliasPath,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await _apiClient.post(primaryPath, data: payload);
      return _apiClient.parseDataEnvelope<Map<String, dynamic>>(
        response,
        (data) => _asStringDynamicMap(data),
      );
    } on DioException catch (error) {
      if (_shouldFallbackToAlias(error)) {
        final aliasResponse = await _apiClient.post(aliasPath, data: payload);
        return _apiClient.parseDataEnvelope<Map<String, dynamic>>(
          aliasResponse,
          (data) => _asStringDynamicMap(data),
        );
      }
      rethrow;
    }
  }

  bool _shouldFallbackToAlias(DioException error) {
    final statusCode = error.response?.statusCode;
    return statusCode == 404 || statusCode == 405 || statusCode == 501;
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
}
