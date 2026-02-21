import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/app/routes/app_routes.dart';
import 'package:neobazaar/features/dashboard/presentation/widgets/product_card.dart';
import 'package:neobazaar/features/item/presentation/pages/product_detail_page.dart';
import 'package:neobazaar/features/item/presentation/view_model/local_product_notifier.dart';

class CompareScreen extends ConsumerWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localState = ref.watch(localProductNotifierProvider);
    final notifier = ref.read(localProductNotifierProvider.notifier);
    final items = localState.compareShortlist;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare'),
        actions: [
          TextButton(
            onPressed: items.isEmpty ? null : notifier.clearCompare,
            child: const Text('Clear'),
          ),
        ],
      ),
      body: items.isEmpty
          ? const Center(child: Text('No products in compare shortlist.'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'Compare shortlist lets you keep candidates side-by-side before deciding. Tap any card to open full details.',
                      ),
                    ),
                  );
                }

                final product = items[index - 1];
                return SizedBox(
                  height: 240,
                  child: ProductCard(
                    imageUrl: product.imageUrls.isNotEmpty
                        ? product.imageUrls.first
                        : 'assets/images/products/image1.png',
                    title: product.title,
                    price: 'Rs. ${product.price}',
                    location: product.location ?? '-',
                    onTap: () {
                      AppRoutes.push(
                        context,
                        ProductDetailPage(productId: product.id),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
