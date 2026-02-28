abstract interface class ITradeRemoteDatasource {
  Future<Map<String, dynamic>> createTransaction(Map<String, dynamic> payload);
  Future<List<Map<String, dynamic>>> listTransactions({
    Map<String, dynamic>? query,
  });
  Future<Map<String, dynamic>> confirmTransaction(
    String txnId,
    Map<String, dynamic> payload,
  );
  Future<Map<String, dynamic>> disputeTransaction(
    String txnId,
    Map<String, dynamic> payload,
  );
  Future<Map<String, dynamic>> appendDisputeEvidence(
    String txnId,
    Map<String, dynamic> payload,
  );

  Future<Map<String, dynamic>> placeBid(Map<String, dynamic> payload);

  Future<List<Map<String, dynamic>>> listOffers({Map<String, dynamic>? query});
  Future<Map<String, dynamic>> createOffer(Map<String, dynamic> payload);
  Future<Map<String, dynamic>> counterOffer(
    String offerId,
    Map<String, dynamic> payload,
  );
  Future<Map<String, dynamic>> acceptOffer(
    String offerId,
    Map<String, dynamic> payload,
  );
  Future<Map<String, dynamic>> rejectOffer(
    String offerId,
    Map<String, dynamic> payload,
  );

  Future<List<Map<String, dynamic>>> listOrders({Map<String, dynamic>? query});
  Future<List<Map<String, dynamic>>> getOrderTimeline(String orderId);
  Future<Map<String, dynamic>> appendOrderTimeline(
    String orderId,
    Map<String, dynamic> payload,
  );

  Future<Map<String, dynamic>> createReview(Map<String, dynamic> payload);
  Future<List<Map<String, dynamic>>> listProductReviews(String productId);
  Future<Map<String, dynamic>> flagReview(
    String reviewId,
    Map<String, dynamic> payload,
  );
}
