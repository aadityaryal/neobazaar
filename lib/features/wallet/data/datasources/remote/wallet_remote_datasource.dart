import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/api/api_client.dart';
import 'package:neobazaar/core/api/api_endpoints.dart';
import 'package:neobazaar/features/wallet/data/datasources/wallet_datasource.dart';

final walletRemoteDatasourceProvider = Provider<IWalletRemoteDatasource>((ref) {
  return WalletRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class WalletRemoteDatasource implements IWalletRemoteDatasource {
  final ApiClient _apiClient;

  WalletRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<Map<String, dynamic>> topup(Map<String, dynamic> payload) async {
    final response = await _apiClient.post(
      ApiEndpoints.walletTopup,
      data: payload,
    );
    return _apiClient.parseDataEnvelope<Map<String, dynamic>>(response, _asMap);
  }

  @override
  Future<Map<String, dynamic>> topupViaUserAlias(
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.userWalletTopupAlias,
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
}
