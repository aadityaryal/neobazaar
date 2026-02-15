import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/app/routes/app_routes.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/dashboard/presentation/widgets/product_card.dart';
import 'package:neobazaar/features/item/presentation/pages/compare_screen.dart';
import 'package:neobazaar/features/item/presentation/pages/product_detail_page.dart';
import 'package:neobazaar/features/item/presentation/view_model/local_product_notifier.dart';
import 'package:neobazaar/features/item/presentation/view_model/product_list_notifier.dart';

class BrowseScreen extends ConsumerStatefulWidget {
  const BrowseScreen({super.key});

  @override
  ConsumerState<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends ConsumerState<BrowseScreen> {
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(productListNotifierProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productListNotifierProvider);
    final notifier = ref.read(productListNotifierProvider.notifier);
    final localState = ref.watch(localProductNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse'),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.compare_arrows),
                if (localState.compareShortlist.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              AppRoutes.push(context, const CompareScreen());
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: notifier.refresh,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            if (localState.recentlyViewed.isNotEmpty) ...[
              const Text(
                'Recently Viewed',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: localState.recentlyViewed.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final product = localState.recentlyViewed[index];
                    return SizedBox(
                      width: 170,
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
              ),
              const SizedBox(height: 12),
            ],
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SizedBox(
                  width: 160,
                  child: DropdownButtonFormField<String>(
                    initialValue: state.category,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All')),
                      DropdownMenuItem(
                        value: 'electronics',
                        child: Text('Electronics'),
                      ),
                      DropdownMenuItem(
                        value: 'fashion',
                        child: Text('Fashion'),
                      ),
                      DropdownMenuItem(
                        value: 'vehicles',
                        child: Text('Vehicles'),
                      ),
                    ],
                    onChanged: (value) => notifier.setCategory(value),
                  ),
                ),
                SizedBox(
                  width: 160,
                  child: DropdownButtonFormField<String>(
                    initialValue: state.location,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Location'),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All')),
                      DropdownMenuItem(
                        value: 'kathmandu',
                        child: Text('Kathmandu'),
                      ),
                      DropdownMenuItem(
                        value: 'pokhara',
                        child: Text('Pokhara'),
                      ),
                      DropdownMenuItem(
                        value: 'lalitpur',
                        child: Text('Lalitpur'),
                      ),
                    ],
                    onChanged: (value) => notifier.setLocation(value),
                  ),
                ),
                SizedBox(
                  width: 160,
                  child: DropdownButtonFormField<String>(
                    initialValue: state.mode,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Mode'),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All')),
                      DropdownMenuItem(value: 'fixed', child: Text('Fixed')),
                      DropdownMenuItem(
                        value: 'auction',
                        child: Text('Auction'),
                      ),
                    ],
                    onChanged: (value) => notifier.setMode(value),
                  ),
                ),
                SizedBox(
                  width: 160,
                  child: TextField(
                    controller: _minPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Min price'),
                    onSubmitted: (_) {
                      notifier.setPriceRange(
                        minPrice: num.tryParse(_minPriceController.text),
                        maxPrice: num.tryParse(_maxPriceController.text),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: 160,
                  child: TextField(
                    controller: _maxPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Max price'),
                    onSubmitted: (_) {
                      notifier.setPriceRange(
                        minPrice: num.tryParse(_minPriceController.text),
                        maxPrice: num.tryParse(_maxPriceController.text),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<String>(
                    initialValue: state.sort,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Sort'),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Default')),
                      DropdownMenuItem(value: 'newest', child: Text('Newest')),
                      DropdownMenuItem(value: 'oldest', child: Text('Oldest')),
                      DropdownMenuItem(
                        value: 'price_asc',
                        child: Text('Price asc'),
                      ),
                      DropdownMenuItem(
                        value: 'price_desc',
                        child: Text('Price desc'),
                      ),
                    ],
                    onChanged: (value) => notifier.setSort(value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (state.status == AsyncStatus.loading && state.items.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (state.status == AsyncStatus.error && state.items.isEmpty)
              Center(
                child: Column(
                  children: [
                    Text(state.errorMessage ?? 'Failed to load products'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: notifier.retry,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (state.items.isEmpty)
              const Center(
                child: Text('No products found for selected filters.'),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  final product = state.items[index];
                  return ProductCard(
                    imageUrl: product.imageUrls.isNotEmpty
                        ? product.imageUrls.first
                        : 'assets/images/products/image1.png',
                    title: product.title,
                    price: 'Rs. ${product.price}',
                    location: product.location ?? '-',
                    mode: product.mode,
                    onTap: () {
                      AppRoutes.push(
                        context,
                        ProductDetailPage(productId: product.id),
                      );
                    },
                  );
                },
              ),
            const SizedBox(height: 12),
            if (state.hasMore && state.items.isNotEmpty)
              ElevatedButton(
                onPressed: state.status == AsyncStatus.loading
                    ? null
                    : notifier.loadMore,
                child: Text(
                  state.status == AsyncStatus.loading
                      ? 'Loading...'
                      : 'Load more',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
