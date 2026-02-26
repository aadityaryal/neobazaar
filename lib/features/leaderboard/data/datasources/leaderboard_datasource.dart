abstract interface class ILeaderboardRemoteDatasource {
  Future<List<Map<String, dynamic>>> listLeaderboard({required String tab});
}
