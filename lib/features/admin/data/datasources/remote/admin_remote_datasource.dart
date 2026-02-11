import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/api/api_client.dart';
import 'package:neobazaar/core/api/api_endpoints.dart';
import 'package:neobazaar/features/admin/data/datasources/admin_datasource.dart';

final adminRemoteDatasourceProvider = Provider<IAdminRemoteDatasource>((ref) {
  return AdminRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class AdminRemoteDatasource implements IAdminRemoteDatasource {
  final ApiClient _apiClient;

  AdminRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<Map<String, dynamic>> getHeatmap({Map<String, dynamic>? query}) async {
    final response = await _apiClient.get(
      ApiEndpoints.adminHeatmap,
      queryParameters: query,
    );

    return _apiClient.parseDataEnvelope<Map<String, dynamic>>(response, _asMap);
  }

  @override
  Future<List<Map<String, dynamic>>> listUsers({
    Map<String, dynamic>? query,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.adminUsers,
      queryParameters: query,
    );

    return _apiClient.parseDataEnvelope<List<Map<String, dynamic>>>(
      response,
      _asListOfMaps,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> listProducts({
    Map<String, dynamic>? query,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.products,
      queryParameters: query,
    );

    return _apiClient.parseDataEnvelope<List<Map<String, dynamic>>>(
      response,
      _asListOfMaps,
    );
  }

  @override
  Future<Map<String, dynamic>> getExport({Map<String, dynamic>? query}) async {
    final response = await _apiClient.get(
      ApiEndpoints.adminExport,
      queryParameters: query,
    );

    return _apiClient.parseDataEnvelope<Map<String, dynamic>>(response, _asMap);
  }

  @override
  Future<Map<String, dynamic>> createExportJob(
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.adminExportJobs,
      data: payload,
    );

    return _apiClient.parseDataEnvelope<Map<String, dynamic>>(response, _asMap);
  }

  @override
  Future<Map<String, dynamic>> getExportJob(String exportJobId) async {
    final response = await _apiClient.get(
      ApiEndpoints.adminExportJobById(exportJobId),
    );

    return _apiClient.parseDataEnvelope<Map<String, dynamic>>(response, _asMap);
  }

  @override
  Future<List<Map<String, dynamic>>> listFlags({
    Map<String, dynamic>? query,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.adminFlags,
      queryParameters: query,
    );

    return _apiClient.parseDataEnvelope<List<Map<String, dynamic>>>(
      response,
      _asListOfMaps,
    );
  }

  @override
  Future<Map<String, dynamic>> updateFlag(
    String flagId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.patch(
      ApiEndpoints.adminFlagById(flagId),
      data: payload,
    );

    return _apiClient.parseDataEnvelope<Map<String, dynamic>>(response, _asMap);
  }

  @override
  Future<List<Map<String, dynamic>>> listDisputes({
    Map<String, dynamic>? query,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.adminDisputes,
      queryParameters: query,
    );

    return _apiClient.parseDataEnvelope<List<Map<String, dynamic>>>(
      response,
      _asListOfMaps,
    );
  }

  @override
  Future<Map<String, dynamic>> decideDispute(
    String disputeId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.patch(
      ApiEndpoints.adminDisputeDecide(disputeId),
      data: payload,
    );

    return _apiClient.parseDataEnvelope<Map<String, dynamic>>(response, _asMap);
  }

  @override
  Future<Map<String, dynamic>> undoModeration(
    String actionId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.adminModerationUndo(actionId),
      data: payload,
    );

    return _apiClient.parseDataEnvelope<Map<String, dynamic>>(response, _asMap);
  }

  @override
  Future<List<Map<String, dynamic>>> listAuditLogs({
    Map<String, dynamic>? query,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.adminAuditLogs,
      queryParameters: query,
    );

    return _apiClient.parseDataEnvelope<List<Map<String, dynamic>>>(
      response,
      _asListOfMaps,
    );
  }

  @override
  Future<Map<String, dynamic>> runAuditRetention(
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.adminAuditRetentionRun,
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
