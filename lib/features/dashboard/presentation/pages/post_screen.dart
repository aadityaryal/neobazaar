import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/app/routes/app_routes.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/item/presentation/pages/product_detail_page.dart';
import 'package:neobazaar/features/item/presentation/view_model/listing_composer_notifier.dart';

class PostScreen extends ConsumerStatefulWidget {
  const PostScreen({super.key});

  @override
  ConsumerState<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends ConsumerState<PostScreen>
    with WidgetsBindingObserver {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String? _lastRoutedProductId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(_restoreDraftToForm);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final notifier = ref.read(listingComposerNotifierProvider.notifier);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      notifier.saveDraftOnPause();
      return;
    }
    if (state == AppLifecycleState.resumed) {
      _restoreDraftToForm();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _restoreDraftToForm() async {
    final restored = await ref
        .read(listingComposerNotifierProvider.notifier)
        .restoreDraftOnResume();
    if (!mounted || restored == null) {
      return;
    }

    _titleController.text = restored.title;
    _descriptionController.text = restored.description;
    _priceController.text = restored.price == 0
        ? ''
        : restored.price.toString();
    _locationController.text = restored.location ?? '';
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(listingComposerNotifierProvider, (previous, next) {
      final createdProductId = next.createdProductId;
      if (createdProductId == null ||
          createdProductId == _lastRoutedProductId) {
        return;
      }
      _lastRoutedProductId = createdProductId;
      AppRoutes.push(context, ProductDetailPage(productId: createdProductId));
    });

    final state = ref.watch(listingComposerNotifierProvider);
    final notifier = ref.read(listingComposerNotifierProvider.notifier);
    final mediaItems = state.draft?.media ?? const [];
    final draft = state.draft;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Listing')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton.icon(
            onPressed: notifier.pickMedia,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: const Text('Add Photos'),
          ),
          if (mediaItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 96,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: mediaItems.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final media = mediaItems[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(media.compressedPath),
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 96,
                        height: 96,
                        color: Colors.black12,
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
            onChanged: (value) => notifier.updateDraftFields(title: value),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Description'),
            onChanged: (value) =>
                notifier.updateDraftFields(description: value),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Price'),
            onChanged: (value) {
              notifier.updateDraftFields(price: num.tryParse(value) ?? 0);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: state.draft?.category,
            decoration: const InputDecoration(labelText: 'Category'),
            items: const [
              DropdownMenuItem(value: null, child: Text('Select category')),
              DropdownMenuItem(
                value: 'electronics',
                child: Text('Electronics'),
              ),
              DropdownMenuItem(value: 'fashion', child: Text('Fashion')),
              DropdownMenuItem(value: 'vehicles', child: Text('Vehicles')),
              DropdownMenuItem(value: 'other', child: Text('Other')),
            ],
            onChanged: (value) => notifier.updateDraftFields(category: value),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(labelText: 'Location'),
            onChanged: (value) => notifier.updateDraftFields(location: value),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: state.draft?.mode,
            decoration: const InputDecoration(labelText: 'Listing Mode'),
            items: const [
              DropdownMenuItem(value: null, child: Text('Select mode')),
              DropdownMenuItem(value: 'buy_now', child: Text('Buy Now')),
              DropdownMenuItem(value: 'auction', child: Text('Auction')),
              DropdownMenuItem(value: 'donate', child: Text('Donate')),
            ],
            onChanged: (value) => notifier.updateDraftFields(mode: value),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: state.status == AsyncStatus.loading
                ? null
                : notifier.analyzeWithAi,
            child: Text(
              state.status == AsyncStatus.loading
                  ? 'Analyzing with AI...'
                  : 'Analyze with AI',
            ),
          ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              state.errorMessage!,
              style: TextStyle(
                color: state.fallbackUsed
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.error,
              ),
            ),
          ],
          if (state.fallbackUsed) ...[
            const SizedBox(height: 8),
            const Text('Fallback source: proxy_unavailable'),
          ],
          if (state.aiSummary != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Summary',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('Detect: ${state.aiSummary!['detect']}'),
                    const SizedBox(height: 6),
                    Text('Price: ${state.aiSummary!['price']}'),
                  ],
                ),
              ),
            ),
          ],
          if (draft != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Listing Confirmation',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('Title: ${draft.title.isEmpty ? '-' : draft.title}'),
                    Text('Price: Rs. ${draft.price}'),
                    Text('Category: ${draft.category ?? '-'}'),
                    Text('Location: ${draft.location ?? '-'}'),
                    Text('Mode: ${draft.mode ?? '-'}'),
                    Text('Media count: ${draft.media.length}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: state.status == AsyncStatus.loading
                  ? null
                  : notifier.submitListing,
              child: const Text('Submit Listing'),
            ),
          ],
        ],
      ),
    );
  }
}
