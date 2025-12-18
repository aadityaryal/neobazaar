import 'package:flutter/material.dart';
import 'package:neobazaar/widgets/product_card.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final freshFinds = [
    {
      'image': 'assets/images/products/image1.png',
      'title': 'Vintage Camera',
      'price': 'Rs. 18,000',
      'location': '2 mi',
    },
    {
      'image': 'assets/images/products/image2.png',
      'title': 'Honda CB Hornet',
      'price': 'Rs. 138,000',
      'location': '5 mi',
    },
    {
      'image': 'assets/images/products/image4.png',
      'title': 'Designer Handbag',
      'price': 'Rs. 1,250',
      'location': '1 mi',
    },
    {
      'image': 'assets/images/products/image4.png',
      'title': 'Designer Handbag',
      'price': 'Rs. 1,250',
      'location': '1 mi',
    },
  ];

  final trending = [
    {
      'image': 'assets/images/products/image5.png',
      'title': 'Running Shoes',
      'price': 'Rs. 900',
      'location': '3 mi',
    },
    {
      'image': 'assets/images/products/image6.png',
      'title': 'Wireless Headphones',
      'price': 'Rs. 1,500',
      'location': '2 mi',
    },
    {
      'image': 'assets/images/products/image4.png',
      'title': 'Designer Handbag',
      'price': 'Rs. 1,250',
      'location': '1 mi',
    },
    {
      'image': 'assets/images/products/image5.png',
      'title': 'Running Shoes',
      'price': 'Rs. 900',
      'location': '3 mi',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('NeoBazaar'),
          actions: [
            IconButton(icon: const Icon(Icons.inbox), onPressed: () {}),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔥 Streak + Tokens row (NEW)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.local_fire_department,
                            color: Colors.orange,
                            size: 20,
                          ),
                          SizedBox(width: 6),
                          Text('Daily Streak: 3'),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: const [
                          Icon(
                            Icons.monetization_on,
                            color: Colors.amber,
                            size: 20,
                          ),
                          SizedBox(width: 6),
                          Text('NeoTokens: 120'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: const Text(
                  'Fresh Finds',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 250,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: freshFinds.length,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: 180,
                      child: ProductCard(
                        imageUrl: freshFinds[index]['image'] ?? '',
                        title: freshFinds[index]['title'] ?? '',
                        price: freshFinds[index]['price'] ?? '',
                        location: freshFinds[index]['location'] ?? '',
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
                    imageUrl: trending[index]['image'] ?? '',
                    title: trending[index]['title'] ?? '',
                    price: trending[index]['price'] ?? '',
                    location: trending[index]['location'] ?? '',
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
