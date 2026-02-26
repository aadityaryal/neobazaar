import 'package:neobazaar/core/state/async_status.dart';

class SellerStudioState {
  final AsyncStatus status;
  final List<Map<String, dynamic>> listingsAnalytics;
  final List<Map<String, dynamic>> payoutsLedger;
  final List<Map<String, dynamic>> bulkImportPreview;
  final List<String> bulkImportValidationErrors;
  final bool isImportSubmitting;
  final Map<String, dynamic>? lastBulkImportResult;
  final String? error;

  const SellerStudioState({
    this.status = AsyncStatus.initial,
    this.listingsAnalytics = const <Map<String, dynamic>>[],
    this.payoutsLedger = const <Map<String, dynamic>>[],
    this.bulkImportPreview = const <Map<String, dynamic>>[],
    this.bulkImportValidationErrors = const <String>[],
    this.isImportSubmitting = false,
    this.lastBulkImportResult,
    this.error,
  });

  SellerStudioState copyWith({
    AsyncStatus? status,
    List<Map<String, dynamic>>? listingsAnalytics,
    List<Map<String, dynamic>>? payoutsLedger,
    List<Map<String, dynamic>>? bulkImportPreview,
    List<String>? bulkImportValidationErrors,
    bool? isImportSubmitting,
    Map<String, dynamic>? lastBulkImportResult,
    bool clearLastBulkImportResult = false,
    String? error,
    bool clearError = false,
  }) {
    return SellerStudioState(
      status: status ?? this.status,
      listingsAnalytics: listingsAnalytics ?? this.listingsAnalytics,
      payoutsLedger: payoutsLedger ?? this.payoutsLedger,
      bulkImportPreview: bulkImportPreview ?? this.bulkImportPreview,
      bulkImportValidationErrors:
          bulkImportValidationErrors ?? this.bulkImportValidationErrors,
      isImportSubmitting: isImportSubmitting ?? this.isImportSubmitting,
      lastBulkImportResult: clearLastBulkImportResult
          ? null
          : (lastBulkImportResult ?? this.lastBulkImportResult),
      error: clearError ? null : (error ?? this.error),
    );
  }
}
