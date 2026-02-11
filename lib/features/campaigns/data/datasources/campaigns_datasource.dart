abstract interface class ICampaignsRemoteDatasource {
  Future<List<Map<String, dynamic>>> listCampaigns({
    Map<String, dynamic>? query,
  });

  Future<Map<String, dynamic>> createCampaign(Map<String, dynamic> payload);

  Future<Map<String, dynamic>> updateCampaignStatus(
    String campaignId,
    Map<String, dynamic> payload,
  );
}
