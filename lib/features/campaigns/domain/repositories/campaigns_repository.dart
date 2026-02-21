import 'package:dartz/dartz.dart';
import 'package:neobazaar/core/error/failures.dart';

abstract interface class ICampaignsRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> listCampaigns({
    Map<String, dynamic>? query,
  });

  Future<Either<Failure, Map<String, dynamic>>> createCampaign(
    Map<String, dynamic> payload,
  );

  Future<Either<Failure, Map<String, dynamic>>> updateCampaignStatus(
    String campaignId,
    Map<String, dynamic> payload,
  );
}
