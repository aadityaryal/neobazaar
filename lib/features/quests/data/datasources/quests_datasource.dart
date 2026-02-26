abstract interface class IQuestsRemoteDatasource {
  Future<List<Map<String, dynamic>>> listQuests({Map<String, dynamic>? query});

  Future<Map<String, dynamic>> createQuest(Map<String, dynamic> payload);

  Future<Map<String, dynamic>> completeQuest(
    String questId,
    Map<String, dynamic> payload,
  );
}
