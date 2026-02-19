abstract interface class IExtensionRemoteDatasource {
  Future<Map<String, dynamic>> detect(Map<String, dynamic> payload);
  Future<Map<String, dynamic>> price(Map<String, dynamic> payload);
  Future<Map<String, dynamic>> fraud(Map<String, dynamic> payload);
  Future<Map<String, dynamic>> recommend({Map<String, dynamic>? queryOrBody});
  Future<Map<String, dynamic>> nlpSuggest(Map<String, dynamic> payload);
}
