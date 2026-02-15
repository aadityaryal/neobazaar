import 'package:flutter/material.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/dashboard/presentation/widgets/product_card.dart';
import 'package:neobazaar/features/item/domain/entities/product_entity.dart';
import 'package:neobazaar/features/item/presentation/state/recommendation_state.dart';

class RecommendationCarousel extends StatelessWidget {
  final RecommendationState state;
  final VoidCallback onRetry;
  final ValueChanged<ProductEntity> onTapItem;

  const RecommendationCarousel({
    super.key,
    required this.state,
    required this.onRetry,
    required this.onTapItem,
  });

  @override
  Widget build(BuildContext context) {
    if (state.status == AsyncStatus.loading) {
      return const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.status == AsyncStatus.error) {
      return Center(
        child: TextButton(
          onPressed: onRetry,
          child: const Text('Retry recommendations'),
        ),
      );
    }

    if (state.items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text('No recommendations available right now.'),
      );
    }

    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: state.items.length,
        itemBuilder: (context, index) {
          final item = state.items[index];
          return SizedBox(
            width: 180,
            child: ProductCard(
              imageUrl: item.imageUrls.isNotEmpty
                  ? item.imageUrls.first
                  : 'assets/images/products/image1.png',
              title: item.title,
              price: 'Rs. ${item.price}',
              location: item.location ?? '-',
              mode: item.mode,
              onTap: () => onTapItem(item),
            ),
          );
        },
      ),
    );
  }
}
