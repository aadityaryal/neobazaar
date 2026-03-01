abstract interface class IWalletRemoteDatasource {
  Future<Map<String, dynamic>> topup(Map<String, dynamic> payload);

  Future<Map<String, dynamic>> topupViaUserAlias(Map<String, dynamic> payload);
}
