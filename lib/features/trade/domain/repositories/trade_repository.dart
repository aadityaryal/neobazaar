import 'package:dartz/dartz.dart';
import 'package:neobazaar/core/error/failures.dart';

abstract interface class ITradeRepository {
  Future<Either<Failure, Map<String, dynamic>>> createTransaction(
    Map<String, dynamic> payload,
  );
  Future<Either<Failure, List<Map<String, dynamic>>>> listTransactions({
    Map<String, dynamic>? query,
  });
  Future<Either<Failure, Map<String, dynamic>>> confirmTransaction(
    String txnId,
    Map<String, dynamic> payload,
  );
  Future<Either<Failure, Map<String, dynamic>>> disputeTransaction(
    String txnId,
    Map<String, dynamic> payload,
  );
  Future<Either<Failure, Map<String, dynamic>>> appendDisputeEvidence(
    String txnId,
    Map<String, dynamic> payload,
  );

  Future<Either<Failure, Map<String, dynamic>>> placeBid(
    Map<String, dynamic> payload,
  );

  Future<Either<Failure, List<Map<String, dynamic>>>> listOffers({
    Map<String, dynamic>? query,
  });
  Future<Either<Failure, Map<String, dynamic>>> createOffer(
    Map<String, dynamic> payload,
  );
  Future<Either<Failure, Map<String, dynamic>>> counterOffer(
    String offerId,
    Map<String, dynamic> payload,
  );
  Future<Either<Failure, Map<String, dynamic>>> acceptOffer(
    String offerId,
    Map<String, dynamic> payload,
  );
  Future<Either<Failure, Map<String, dynamic>>> rejectOffer(
    String offerId,
    Map<String, dynamic> payload,
  );

  Future<Either<Failure, List<Map<String, dynamic>>>> listOrders({
    Map<String, dynamic>? query,
  });
  Future<Either<Failure, List<Map<String, dynamic>>>> getOrderTimeline(
    String orderId,
  );
  Future<Either<Failure, Map<String, dynamic>>> appendOrderTimeline(
    String orderId,
    Map<String, dynamic> payload,
  );

  Future<Either<Failure, Map<String, dynamic>>> createReview(
    Map<String, dynamic> payload,
  );
  Future<Either<Failure, List<Map<String, dynamic>>>> listProductReviews(
    String productId,
  );
  Future<Either<Failure, Map<String, dynamic>>> flagReview(
    String reviewId,
    Map<String, dynamic> payload,
  );
}
