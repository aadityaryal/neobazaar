import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/api/api_client.dart';
import 'package:neobazaar/core/api/api_endpoints.dart';
import 'package:neobazaar/features/leaderboard/data/datasources/leaderboard_datasource.dart';

final leaderboardRemoteDatasourceProvider =
    Provider<ILeaderboardRemoteDatasource>((ref) {
      return LeaderboardRemoteDatasource(
        apiClient: ref.read(apiClientProvider),
      );
    });

class LeaderboardRemoteDatasource implements ILeaderboardRemoteDatasource {
  final ApiClient _apiClient;

  LeaderboardRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<Map<String, dynamic>>> listLeaderboard({
    required String tab,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.leaderboard,
      queryParameters: <String, dynamic>{'tab': tab},
    );

    return _apiClient.parseDataEnvelope<List<Map<String, dynamic>>>(
      response,
      _asListOfMaps,
    );
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
