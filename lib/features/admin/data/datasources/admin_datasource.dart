abstract interface class IAdminRemoteDatasource {
  Future<Map<String, dynamic>> getHeatmap({Map<String, dynamic>? query});

  Future<List<Map<String, dynamic>>> listUsers({Map<String, dynamic>? query});

  Future<List<Map<String, dynamic>>> listProducts({
    Map<String, dynamic>? query,
  });

  Future<Map<String, dynamic>> getExport({Map<String, dynamic>? query});

  Future<Map<String, dynamic>> createExportJob(Map<String, dynamic> payload);

  Future<Map<String, dynamic>> getExportJob(String exportJobId);

  Future<List<Map<String, dynamic>>> listFlags({Map<String, dynamic>? query});

  Future<Map<String, dynamic>> updateFlag(
    String flagId,
    Map<String, dynamic> payload,
  );

  Future<List<Map<String, dynamic>>> listDisputes({
    Map<String, dynamic>? query,
  });

  Future<Map<String, dynamic>> decideDispute(
    String disputeId,
    Map<String, dynamic> payload,
  );

  Future<Map<String, dynamic>> undoModeration(
    String actionId,
    Map<String, dynamic> payload,
  );

  Future<List<Map<String, dynamic>>> listAuditLogs({
    Map<String, dynamic>? query,
  });

  Future<Map<String, dynamic>> runAuditRetention(Map<String, dynamic> payload);
}
