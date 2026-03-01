abstract interface class IReferralsRemoteDatasource {
  Future<List<Map<String, dynamic>>> listReferrals({
    Map<String, dynamic>? query,
  });

  Future<Map<String, dynamic>> createReferral(Map<String, dynamic> payload);

  Future<Map<String, dynamic>> qualifyReferral(
    String referralId,
    Map<String, dynamic> payload,
  );
}
