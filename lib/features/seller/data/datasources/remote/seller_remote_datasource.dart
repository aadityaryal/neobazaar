import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/api/api_client.dart';
import 'package:neobazaar/core/api/api_endpoints.dart';
import 'package:neobazaar/features/seller/data/datasources/seller_datasource.dart';

final sellerRemoteDatasourceProvider = Provider<ISellerRemoteDatasource>((ref) {
  return SellerRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class SellerRemoteDatasource implements ISellerRemoteDatasource {
  final ApiClient _apiClient;

  SellerRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<Map<String, dynamic>>> getListingsAnalytics({
    Map<String, dynamic>? query,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.sellerListingsAnalytics,
      queryParameters: query,
    );

    return _apiClient.parseDataEnvelope<List<Map<String, dynamic>>>(response, (
      data,
    ) {
      final root = _asMap(data);
      return _asListOfMaps(root['byProduct']);
    });
  }

  @override
  Future<Map<String, dynamic>> bulkImport(Map<String, dynamic> payload) async {
    final response = await _apiClient.post(
      ApiEndpoints.sellerBulkImport,
      data: payload,
    );

    return _apiClient.parseDataEnvelope<Map<String, dynamic>>(response, _asMap);
  }

  @override
  Future<List<Map<String, dynamic>>> getPayoutLedger({
    Map<String, dynamic>? query,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.sellerPayoutLedger,
      queryParameters: query,
    );

    return _apiClient.parseDataEnvelope<List<Map<String, dynamic>>>(response, (
      data,
    ) {
      final root = _asMap(data);
      return _asListOfMaps(root['entries']);
    });
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }

    return <String, dynamic>{'value': value};
  }

  List<Map<String, dynamic>> _asListOfMaps(dynamic value) {
    final list = value is List ? value : <dynamic>[];
    return list.whereType<Map>().map((item) => _asMap(item)).toList();
  }
}
