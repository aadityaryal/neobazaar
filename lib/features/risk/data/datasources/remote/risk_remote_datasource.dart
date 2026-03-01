import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/api/api_client.dart';
import 'package:neobazaar/core/api/api_endpoints.dart';
import 'package:neobazaar/features/risk/data/datasources/risk_datasource.dart';

final riskRemoteDatasourceProvider = Provider<IRiskRemoteDatasource>((ref) {
  return RiskRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class RiskRemoteDatasource implements IRiskRemoteDatasource {
  final ApiClient _apiClient;

  RiskRemoteDatasource({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<Map<String, dynamic>> getUserRiskScore(String userId) async {
    final response = await _apiClient.get(ApiEndpoints.riskUserScore(userId));
    return _apiClient.parseDataEnvelope<Map<String, dynamic>>(response, _asMap);
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
}
