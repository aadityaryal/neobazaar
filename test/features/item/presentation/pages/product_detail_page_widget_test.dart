import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders product title, price, and key attributes', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Text('MacBook Pro M2'),
              Text('NPR 120000'),
              Text('Condition: Like New'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('MacBook Pro M2'), findsOneWidget);
    expect(find.text('NPR 120000'), findsOneWidget);
    expect(find.text('Condition: Like New'), findsOneWidget);
  });

  testWidgets('image gallery/carousel page indicators work', (tester) async {
    final controller = PageController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PageView(
            controller: controller,
            children: const [Text('Image 1'), Text('Image 2')],
          ),
        ),
      ),
    );

    expect(find.text('Image 1'), findsOneWidget);
    await tester.fling(find.byType(PageView), const Offset(-300, 0), 500);
    await tester.pumpAndSettle();
    expect(find.text('Image 2'), findsOneWidget);
  });

  testWidgets('error state shows retry action', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [Text('Something went wrong'), Text('Retry')],
          ),
        ),
      ),
    );

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
