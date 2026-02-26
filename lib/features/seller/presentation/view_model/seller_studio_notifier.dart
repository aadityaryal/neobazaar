import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/seller/data/datasources/remote/seller_remote_datasource.dart';
import 'package:neobazaar/features/seller/presentation/state/seller_studio_state.dart';

final sellerStudioNotifierProvider =
    NotifierProvider<SellerStudioNotifier, SellerStudioState>(
      SellerStudioNotifier.new,
    );

class SellerStudioNotifier extends Notifier<SellerStudioState> {
  @override
  SellerStudioState build() {
    Future<void>.microtask(loadDashboard);
    return const SellerStudioState();
  }

  Future<void> loadDashboard() async {
    state = state.copyWith(status: AsyncStatus.loading, clearError: true);

    try {
      final datasource = ref.read(sellerRemoteDatasourceProvider);
      final analytics = await datasource.getListingsAnalytics(
        query: const <String, dynamic>{'limit': 50},
      );

      state = state.copyWith(
        status: AsyncStatus.success,
        listingsAnalytics: analytics,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: AsyncStatus.error,
        error: error.toString(),
      );
    }
  }

  Future<void> loadPayoutLedger() async {
    try {
      final datasource = ref.read(sellerRemoteDatasourceProvider);
      final payouts = await datasource.getPayoutLedger(
        query: const <String, dynamic>{'limit': 100},
      );
      state = state.copyWith(payoutsLedger: payouts, clearError: true);
    } catch (error) {
      state = state.copyWith(
        status: AsyncStatus.error,
        error: error.toString(),
      );
    }
  }

  void previewBulkImportCsv(String rawInput) {
    final lines = rawInput
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);

    if (lines.isEmpty) {
      state = state.copyWith(
        bulkImportPreview: const <Map<String, dynamic>>[],
        bulkImportValidationErrors: const <String>['Input is empty.'],
        clearLastBulkImportResult: true,
      );
      return;
    }

    final preview = <Map<String, dynamic>>[];
    final errors = <String>[];

    for (var index = 0; index < lines.length; index++) {
      final lineNumber = index + 1;
      final columns = lines[index]
          .split(',')
          .map((value) => value.trim())
          .toList(growable: false);

      if (columns.length < 3) {
        errors.add('Line $lineNumber must include title,category,price.');
        continue;
      }

      final price = double.tryParse(columns[2]);
      if (price == null || price <= 0) {
        errors.add('Line $lineNumber has invalid price.');
        continue;
      }

      preview.add(<String, dynamic>{
        'title': columns[0],
        'category': columns[1],
        'price': price,
        'raw': lines[index],
      });
    }

    state = state.copyWith(
      bulkImportPreview: preview,
      bulkImportValidationErrors: errors,
      clearLastBulkImportResult: true,
      clearError: true,
    );
  }

  Future<void> submitBulkImport() async {
    if (state.bulkImportPreview.isEmpty ||
        state.bulkImportValidationErrors.isNotEmpty) {
      return;
    }

    state = state.copyWith(isImportSubmitting: true, clearError: true);

    try {
      final datasource = ref.read(sellerRemoteDatasourceProvider);
      final result = await datasource.bulkImport(<String, dynamic>{
        'items': state.bulkImportPreview,
      });
      state = state.copyWith(
        isImportSubmitting: false,
        bulkImportPreview: const <Map<String, dynamic>>[],
        bulkImportValidationErrors: const <String>[],
        lastBulkImportResult: result,
      );
      await loadDashboard();
    } catch (error) {
      state = state.copyWith(
        isImportSubmitting: false,
        status: AsyncStatus.error,
        error: error.toString(),
      );
    }
  }
}
