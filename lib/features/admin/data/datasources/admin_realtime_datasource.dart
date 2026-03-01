abstract interface class IAdminRealtimeDatasource {
  Stream<Map<String, dynamic>> watchFlagUpdatedEvents();

  Stream<Map<String, dynamic>> watchDisputeDecidedEvents();
}
