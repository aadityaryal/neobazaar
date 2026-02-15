abstract interface class IChatRealtimeDatasource {
  Future<void> subscribeToChatChannel(String chatId);

  Future<void> unsubscribeFromChatChannel(String chatId);

  Stream<Map<String, dynamic>> watchChatMessageAliasEvents();

  Stream<Map<String, dynamic>> watchChatMessageCreatedV1Events();

  Stream<Map<String, dynamic>> watchChatSuggestionCreatedV1Events();

  Stream<Map<String, dynamic>> watchChatMessageReceiptUpdatedV1Events();

  Stream<Map<String, dynamic>> watchAuctionBidAliasEvents();

  Stream<Map<String, dynamic>> watchAuctionBidPlacedV1Events();

  Stream<List<Map<String, dynamic>>> watchMessageFeed({String? chatId});

  List<Map<String, dynamic>> deduplicateMessagesById(
    Iterable<Map<String, dynamic>> messages,
  );

  List<Map<String, dynamic>> stabilizeMessageOrderByTimestamp(
    Iterable<Map<String, dynamic>> messages,
  );
}
