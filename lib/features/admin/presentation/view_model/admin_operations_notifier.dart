import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/services/analytics/analytics_service.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/admin/data/datasources/remote/admin_realtime_remote_datasource.dart';
import 'package:neobazaar/features/admin/data/datasources/remote/admin_remote_datasource.dart';
import 'package:neobazaar/features/admin/presentation/state/admin_operations_state.dart';

final adminOperationsNotifierProvider =
    NotifierProvider<AdminOperationsNotifier, AdminOperationsState>(
      AdminOperationsNotifier.new,
    );

class AdminOperationsNotifier extends Notifier<AdminOperationsState> {
  StreamSubscription<Map<String, dynamic>>? _flagUpdatedSubscription;
  StreamSubscription<Map<String, dynamic>>? _disputeDecidedSubscription;
  late final AnalyticsService _analyticsService;

  @override
  AdminOperationsState build() {
    _analyticsService = ref.read(analyticsServiceProvider);
    final realtimeDatasource = ref.read(adminRealtimeDatasourceProvider);

    _flagUpdatedSubscription?.cancel();
    _flagUpdatedSubscription = realtimeDatasource
        .watchFlagUpdatedEvents()
        .listen(_onFlagUpdatedEvent);

    _disputeDecidedSubscription?.cancel();
    _disputeDecidedSubscription = realtimeDatasource
        .watchDisputeDecidedEvents()
        .listen(_onDisputeDecidedEvent);

    ref.onDispose(() {
      _flagUpdatedSubscription?.cancel();
      _flagUpdatedSubscription = null;
      _disputeDecidedSubscription?.cancel();
      _disputeDecidedSubscription = null;
    });

    return const AdminOperationsState();
  }

  Future<void> loadHeatmap() async {
    state = state.copyWith(status: AsyncStatus.loading, clearError: true);
    _analyticsService.track('admin_heatmap_load_started');
    try {
      final datasource = ref.read(adminRemoteDatasourceProvider);
      final heatmap = await datasource.getHeatmap();
      state = state.copyWith(
        status: AsyncStatus.success,
        heatmap: heatmap,
        clearError: true,
      );
      _analyticsService.track('admin_heatmap_load_success');
    } catch (error) {
      _analyticsService.track(
        'admin_heatmap_load_error',
        properties: {'message': error.toString()},
      );
      state = state.copyWith(
        status: AsyncStatus.error,
        error: error.toString(),
      );
    }
  }

  Future<void> loadUsers() async {
    try {
      _analyticsService.track('admin_users_load_started');
      final datasource = ref.read(adminRemoteDatasourceProvider);
      final users = await datasource.listUsers(
        query: const <String, dynamic>{'limit': 20, 'page': 1},
      );
      state = state.copyWith(users: users, clearError: true);
      _analyticsService.track(
        'admin_users_load_success',
        properties: {'count': users.length},
      );
    } catch (error) {
      _analyticsService.track(
        'admin_users_load_error',
        properties: {'message': error.toString()},
      );
      state = state.copyWith(
        status: AsyncStatus.error,
        error: error.toString(),
      );
    }
  }

  Future<void> loadProducts() async {
    try {
      _analyticsService.track('admin_products_load_started');
      final datasource = ref.read(adminRemoteDatasourceProvider);
      final products = await datasource.listProducts(
        query: const <String, dynamic>{'limit': 20, 'page': 1},
      );
      state = state.copyWith(products: products, clearError: true);
      _analyticsService.track(
        'admin_products_load_success',
        properties: {'count': products.length},
      );
    } catch (error) {
      _analyticsService.track(
        'admin_products_load_error',
        properties: {'message': error.toString()},
      );
      state = state.copyWith(
        status: AsyncStatus.error,
        error: error.toString(),
      );
    }
  }

  Future<void> loadExportSnapshot() async {
    try {
      _analyticsService.track('admin_export_snapshot_load_started');
      final datasource = ref.read(adminRemoteDatasourceProvider);
      final snapshot = await datasource.getExport();
      state = state.copyWith(exportSnapshot: snapshot, clearError: true);
      _analyticsService.track('admin_export_snapshot_load_success');
    } catch (error) {
      _analyticsService.track(
        'admin_export_snapshot_load_error',
        properties: {'message': error.toString()},
      );
      state = state.copyWith(
        status: AsyncStatus.error,
        error: error.toString(),
      );
    }
  }

  Future<String?> createExportJob(Map<String, dynamic> payload) async {
    try {
      _analyticsService.track('admin_export_job_create_started');
      final datasource = ref.read(adminRemoteDatasourceProvider);
      final created = await datasource.createExportJob(payload);
      final id =
          created['exportJobId']?.toString() ?? created['id']?.toString();
      if (id == null || id.isEmpty) {
        return null;
      }

      final nextJobs = <String, Map<String, dynamic>>{
        ...state.exportJobsById,
        id: created,
      };
      state = state.copyWith(exportJobsById: nextJobs, clearError: true);
      _analyticsService.track(
        'admin_export_job_create_success',
        properties: {'exportJobId': id},
      );
      return id;
    } catch (error) {
      _analyticsService.track(
        'admin_export_job_create_error',
        properties: {'message': error.toString()},
      );
      state = state.copyWith(
        status: AsyncStatus.error,
        error: error.toString(),
      );
      return null;
    }
  }

  Future<void> refreshExportJob(String exportJobId) async {
    try {
      _analyticsService.track(
        'admin_export_job_refresh_started',
        properties: {'exportJobId': exportJobId},
      );
      final datasource = ref.read(adminRemoteDatasourceProvider);
      final job = await datasource.getExportJob(exportJobId);
      final nextJobs = <String, Map<String, dynamic>>{
        ...state.exportJobsById,
        exportJobId: job,
      };
      state = state.copyWith(exportJobsById: nextJobs, clearError: true);
      _analyticsService.track(
        'admin_export_job_refresh_success',
        properties: {'exportJobId': exportJobId, 'status': job['status']},
      );
    } catch (error) {
      _analyticsService.track(
        'admin_export_job_refresh_error',
        properties: {'exportJobId': exportJobId, 'message': error.toString()},
      );
      state = state.copyWith(
        status: AsyncStatus.error,
        error: error.toString(),
      );
    }
  }

  Future<void> loadFlags() async {
    try {
      _analyticsService.track('admin_flags_load_started');
      final datasource = ref.read(adminRemoteDatasourceProvider);
      final flags = await datasource.listFlags(
        query: const <String, dynamic>{'limit': 50},
      );
      state = state.copyWith(flags: flags, clearError: true);
      _analyticsService.track(
        'admin_flags_load_success',
        properties: {'count': flags.length},
      );
    } catch (error) {
      _analyticsService.track(
        'admin_flags_load_error',
        properties: {'message': error.toString()},
      );
      state = state.copyWith(
        status: AsyncStatus.error,
        error: error.toString(),
      );
    }
  }

  Future<void> updateFlag(String flagId, String decision) async {
    try {
      _analyticsService.track(
        'admin_flag_update_started',
        properties: {'flagId': flagId, 'decision': decision},
      );
      final datasource = ref.read(adminRemoteDatasourceProvider);
      final updated = await datasource.updateFlag(flagId, <String, dynamic>{
        'decision': decision,
      });

      final next = state.flags
          .map((flag) {
            final id = flag['flagId']?.toString() ?? flag['id']?.toString();
            if (id != flagId) {
              return flag;
            }
            return <String, dynamic>{...flag, ...updated};
          })
          .toList(growable: false);

      state = state.copyWith(flags: next, clearError: true);
      _analyticsService.track(
        'admin_flag_update_success',
        properties: {'flagId': flagId},
      );
    } catch (error) {
      _analyticsService.track(
        'admin_flag_update_error',
        properties: {'flagId': flagId, 'message': error.toString()},
      );
      state = state.copyWith(
        status: AsyncStatus.error,
        error: error.toString(),
      );
    }
  }

  Future<void> decideDispute(String disputeId, String decision) async {
    try {
      _analyticsService.track(
        'admin_dispute_decide_started',
        properties: {'disputeId': disputeId, 'decision': decision},
      );
      final datasource = ref.read(adminRemoteDatasourceProvider);
      await datasource.decideDispute(disputeId, <String, dynamic>{
        'outcome': decision,
      });
      state = state.copyWith(clearError: true);
      _analyticsService.track(
        'admin_dispute_decide_success',
        properties: {'disputeId': disputeId},
      );
    } catch (error) {
      _analyticsService.track(
        'admin_dispute_decide_error',
        properties: {'disputeId': disputeId, 'message': error.toString()},
      );
      state = state.copyWith(
        status: AsyncStatus.error,
        error: error.toString(),
      );
    }
  }

  Future<void> loadDisputes({String status = 'open'}) async {
    try {
      _analyticsService.track(
        'admin_disputes_load_started',
        properties: {'status': status},
      );
      final datasource = ref.read(adminRemoteDatasourceProvider);
      final disputes = await datasource.listDisputes(
        query: <String, dynamic>{'limit': 50, 'page': 1, 'status': status},
      );
      state = state.copyWith(disputes: disputes, clearError: true);
      _analyticsService.track(
        'admin_disputes_load_success',
        properties: {'count': disputes.length, 'status': status},
      );
    } catch (error) {
      _analyticsService.track(
        'admin_disputes_load_error',
        properties: {'message': error.toString(), 'status': status},
      );
      state = state.copyWith(
        status: AsyncStatus.error,
        error: error.toString(),
      );
    }
  }

  Future<void> undoModerationAction(String actionId, String reason) async {
    try {
      _analyticsService.track(
        'admin_moderation_undo_started',
        properties: {'actionId': actionId},
      );
      final datasource = ref.read(adminRemoteDatasourceProvider);
      await datasource.undoModeration(actionId, <String, dynamic>{
        'reason': reason,
      });
      state = state.copyWith(clearError: true);
      _analyticsService.track(
        'admin_moderation_undo_success',
        properties: {'actionId': actionId},
      );
    } catch (error) {
      _analyticsService.track(
        'admin_moderation_undo_error',
        properties: {'actionId': actionId, 'message': error.toString()},
      );
      state = state.copyWith(
        status: AsyncStatus.error,
        error: error.toString(),
      );
    }
  }

  Future<void> loadAuditLogs() async {
    try {
      _analyticsService.track('admin_audit_logs_load_started');
      final datasource = ref.read(adminRemoteDatasourceProvider);
      final logs = await datasource.listAuditLogs(
        query: const <String, dynamic>{'limit': 100},
      );
      state = state.copyWith(auditLogs: logs, clearError: true);
      _analyticsService.track(
        'admin_audit_logs_load_success',
        properties: {'count': logs.length},
      );
    } catch (error) {
      _analyticsService.track(
        'admin_audit_logs_load_error',
        properties: {'message': error.toString()},
      );
      state = state.copyWith(
        status: AsyncStatus.error,
        error: error.toString(),
      );
    }
  }

  Future<void> runAuditRetention() async {
    try {
      _analyticsService.track('admin_audit_retention_started');
      final datasource = ref.read(adminRemoteDatasourceProvider);
      await datasource.runAuditRetention(const <String, dynamic>{});
      state = state.copyWith(clearError: true);
      _analyticsService.track('admin_audit_retention_success');
    } catch (error) {
      _analyticsService.track(
        'admin_audit_retention_error',
        properties: {'message': error.toString()},
      );
      state = state.copyWith(
        status: AsyncStatus.error,
        error: error.toString(),
      );
    }
  }

  void _onFlagUpdatedEvent(Map<String, dynamic> eventEnvelope) {
    final payload = _payload(eventEnvelope);
    final updatedFlag = _asMap(payload['flag'] ?? payload);
    final flagId =
        updatedFlag['flagId']?.toString() ?? updatedFlag['id']?.toString();

    if (flagId == null || flagId.isEmpty) {
      return;
    }

    final nextFlags = state.flags
        .map((flag) {
          final id = flag['flagId']?.toString() ?? flag['id']?.toString();
          if (id != flagId) {
            return flag;
          }
          return <String, dynamic>{...flag, ...updatedFlag};
        })
        .toList(growable: false);

    state = state.copyWith(flags: nextFlags, clearError: true);
    _analyticsService.track(
      'admin_realtime_flag_updated',
      properties: {'flagId': flagId},
    );
  }

  void _onDisputeDecidedEvent(Map<String, dynamic> eventEnvelope) {
    final payload = _payload(eventEnvelope);
    final disputeId =
        payload['disputeId']?.toString() ?? payload['id']?.toString();
    if (disputeId == null || disputeId.isEmpty) {
      return;
    }

    final nextFlags = state.flags
        .map((flag) {
          final linkedDisputeId =
              flag['disputeId']?.toString() ?? flag['dispute_id']?.toString();
          if (linkedDisputeId != disputeId) {
            return flag;
          }
          return <String, dynamic>{
            ...flag,
            'disputeDecision': payload['decision'],
            'disputeStatus': payload['status'] ?? 'decided',
          };
        })
        .toList(growable: false);

    state = state.copyWith(flags: nextFlags, clearError: true);
    _analyticsService.track(
      'admin_realtime_dispute_decided',
      properties: {'disputeId': disputeId, 'decision': payload['decision']},
    );
  }

  Map<String, dynamic> _payload(Map<String, dynamic> eventEnvelope) {
    final value = eventEnvelope['payload'];
    return _asMap(value);
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }

    return <String, dynamic>{};
  }
}
