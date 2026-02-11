import 'package:neobazaar/core/state/async_status.dart';

class AdminOperationsState {
  final AsyncStatus status;
  final Map<String, dynamic>? heatmap;
  final Map<String, dynamic>? exportSnapshot;
  final Map<String, Map<String, dynamic>> exportJobsById;
  final List<Map<String, dynamic>> users;
  final List<Map<String, dynamic>> products;
  final List<Map<String, dynamic>> flags;
  final List<Map<String, dynamic>> disputes;
  final List<Map<String, dynamic>> auditLogs;
  final String? error;

  const AdminOperationsState({
    this.status = AsyncStatus.initial,
    this.heatmap,
    this.exportSnapshot,
    this.exportJobsById = const <String, Map<String, dynamic>>{},
    this.users = const <Map<String, dynamic>>[],
    this.products = const <Map<String, dynamic>>[],
    this.flags = const <Map<String, dynamic>>[],
    this.disputes = const <Map<String, dynamic>>[],
    this.auditLogs = const <Map<String, dynamic>>[],
    this.error,
  });

  AdminOperationsState copyWith({
    AsyncStatus? status,
    Map<String, dynamic>? heatmap,
    bool clearHeatmap = false,
    Map<String, dynamic>? exportSnapshot,
    bool clearExportSnapshot = false,
    Map<String, Map<String, dynamic>>? exportJobsById,
    List<Map<String, dynamic>>? users,
    List<Map<String, dynamic>>? products,
    List<Map<String, dynamic>>? flags,
    List<Map<String, dynamic>>? disputes,
    List<Map<String, dynamic>>? auditLogs,
    String? error,
    bool clearError = false,
  }) {
    return AdminOperationsState(
      status: status ?? this.status,
      heatmap: clearHeatmap ? null : (heatmap ?? this.heatmap),
      exportSnapshot: clearExportSnapshot
          ? null
          : (exportSnapshot ?? this.exportSnapshot),
      exportJobsById: exportJobsById ?? this.exportJobsById,
      users: users ?? this.users,
      products: products ?? this.products,
      flags: flags ?? this.flags,
      disputes: disputes ?? this.disputes,
      auditLogs: auditLogs ?? this.auditLogs,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
