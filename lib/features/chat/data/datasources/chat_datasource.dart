abstract interface class IChatRemoteDatasource {
  Future<List<Map<String, dynamic>>> listMine({Map<String, dynamic>? query});

  Future<List<Map<String, dynamic>>> replay({Map<String, dynamic>? query});

  Future<Map<String, dynamic>> createChat(Map<String, dynamic> payload);

  Future<List<Map<String, dynamic>>> getMessages(
    String chatId, {
    Map<String, dynamic>? query,
  });

  Future<Map<String, dynamic>> createMessage(
    String chatId,
    Map<String, dynamic> payload,
  );

  Future<Map<String, dynamic>> markMessageRead(
    String chatId,
    String messageId,
    Map<String, dynamic> payload,
  );

  Future<List<Map<String, dynamic>>> suggestReplies(
    Map<String, dynamic> payload,
  );
}
