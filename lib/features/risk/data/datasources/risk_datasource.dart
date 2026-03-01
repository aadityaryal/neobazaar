abstract interface class IRiskRemoteDatasource {
  Future<Map<String, dynamic>> getUserRiskScore(String userId);
}
