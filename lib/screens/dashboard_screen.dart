import 'package:flutter/material.dart';
import '../../widgets/product_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NeoBazaar'),
        actions: [
          IconButton(icon: const Icon(Icons.bolt), onPressed: () {}),
          IconButton(icon: const Icon(Icons.token), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Fresh Finds',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 150,
                    child: ProductCard(
                      imageUrl: 'https://via.placeholder.com/150',
                      title: 'Product $index',
                      price: 'Rs. 18,000',
                      location: '2 mi',
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Trending Near You',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                return ProductCard(
                  imageUrl: 'https://via.placeholder.com/150',
                  title: 'Trend $index',
                  price: 'Rs. 1,250',
                  location: '1 mi',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
