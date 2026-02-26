abstract interface class ISellerRemoteDatasource {
  Future<List<Map<String, dynamic>>> getListingsAnalytics({
    Map<String, dynamic>? query,
  });

  Future<Map<String, dynamic>> bulkImport(Map<String, dynamic> payload);

  Future<List<Map<String, dynamic>>> getPayoutLedger({
    Map<String, dynamic>? query,
  });
}
