import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/api/api_client.dart';
import 'package:neobazaar/core/api/api_endpoints.dart';
import 'package:neobazaar/features/referrals/data/datasources/referrals_datasource.dart';

final referralsRemoteDatasourceProvider = Provider<IReferralsRemoteDatasource>((
  ref,
) {
  return ReferralsRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class ReferralsRemoteDatasource implements IReferralsRemoteDatasource {
  final ApiClient _apiClient;

  ReferralsRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<Map<String, dynamic>>> listReferrals({
    Map<String, dynamic>? query,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.referrals,
      queryParameters: query,
    );

    return _apiClient.parseDataEnvelope<List<Map<String, dynamic>>>(
      response,
      _asListOfMaps,
    );
  }

  @override
  Future<Map<String, dynamic>> createReferral(
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.referrals,
      data: payload,
    );

    return _apiClient.parseDataEnvelope<Map<String, dynamic>>(response, _asMap);
  }

  @override
  Future<Map<String, dynamic>> qualifyReferral(
    String referralId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.referralQualify(referralId),
      data: payload,
    );

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

  List<Map<String, dynamic>> _asListOfMaps(dynamic value) {
    final list = value is List ? value : <dynamic>[];
    return list.whereType<Map>().map((item) => _asMap(item)).toList();
  }
}
