import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/api/api_client.dart';
import 'package:neobazaar/core/api/api_endpoints.dart';
import 'package:neobazaar/features/campaigns/data/datasources/campaigns_datasource.dart';

final campaignsRemoteDatasourceProvider = Provider<ICampaignsRemoteDatasource>((
  ref,
) {
  return CampaignsRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class CampaignsRemoteDatasource implements ICampaignsRemoteDatasource {
  final ApiClient _apiClient;

  CampaignsRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<Map<String, dynamic>>> listCampaigns({
    Map<String, dynamic>? query,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.campaigns,
      queryParameters: query,
    );

    return _apiClient.parseDataEnvelope<List<Map<String, dynamic>>>(
      response,
      _asListOfMaps,
    );
  }

  @override
  Future<Map<String, dynamic>> createCampaign(
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.campaigns,
      data: payload,
    );

    return _apiClient.parseDataEnvelope<Map<String, dynamic>>(response, _asMap);
  }

  @override
  Future<Map<String, dynamic>> updateCampaignStatus(
    String campaignId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.patch(
      ApiEndpoints.campaignStatus(campaignId),
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
