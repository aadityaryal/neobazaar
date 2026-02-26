import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/features/seller/presentation/view_model/seller_studio_notifier.dart';

class SellerBulkImportPage extends ConsumerStatefulWidget {
  const SellerBulkImportPage({super.key});

  @override
  ConsumerState<SellerBulkImportPage> createState() =>
      _SellerBulkImportPageState();
}

class _SellerBulkImportPageState extends ConsumerState<SellerBulkImportPage> {
  final TextEditingController _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sellerStudioNotifierProvider);
    final notifier = ref.read(sellerStudioNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Seller Bulk Import')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Bulk Import Walkthrough'),
                  SizedBox(height: 6),
                  Text('1. Use CSV rows in format: title,category,price'),
                  Text('2. Click Preview to validate rows before submit'),
                  Text(
                    '3. Fix any validation errors, then click Submit to import valid rows',
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Expected result: accepted items are imported, invalid rows remain rejected with reasons.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text('Format: title,category,price (one item per line)'),
          const SizedBox(height: 8),
          TextField(
            controller: _inputController,
            minLines: 6,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText: 'Book,Books,299\nHeadphones,Electronics,4500',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      notifier.previewBulkImportCsv(_inputController.text),
                  child: const Text('Preview'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: state.isImportSubmitting
                      ? null
                      : () => notifier.submitBulkImport(),
                  child: state.isImportSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (state.lastBulkImportResult != null) ...[
            Card(
              color: Colors.green.withAlpha(15),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Last Submission Result'),
                    const SizedBox(height: 6),
                    Text(_resultSummary(state.lastBulkImportResult!)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (state.bulkImportValidationErrors.isNotEmpty) ...[
            const Text('Validation Errors:'),
            const SizedBox(height: 6),
            ...state.bulkImportValidationErrors.map(
              (error) =>
                  Text('• $error', style: const TextStyle(color: Colors.red)),
            ),
            const SizedBox(height: 12),
          ],
          if (state.bulkImportPreview.isNotEmpty) ...[
            const Text('Validation Preview:'),
            const SizedBox(height: 6),
            ...state.bulkImportPreview.map(
              (row) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(row['title']?.toString() ?? '-'),
                subtitle: Text(
                  'Category: ${row['category']} • Price: ${row['price']}',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _resultSummary(Map<String, dynamic> result) {
    final accepted =
        result['accepted'] ?? result['imported'] ?? result['successCount'];
    final rejected =
        result['rejected'] ?? result['failed'] ?? result['failureCount'];
    final message = result['message']?.toString();

    final acceptedText = accepted == null ? '-' : accepted.toString();
    final rejectedText = rejected == null ? '-' : rejected.toString();

    return 'Imported: $acceptedText • Rejected: $rejectedText${message == null || message.isEmpty ? '' : ' • $message'}';
  }
}
