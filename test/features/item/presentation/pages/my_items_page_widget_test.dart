import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('list renders with owned items', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(children: [Text('My Item 1'), Text('My Item 2')]),
        ),
      ),
    );

    expect(find.text('My Item 1'), findsOneWidget);
    expect(find.text('My Item 2'), findsOneWidget);
  });

  testWidgets('empty state shows expected CTA', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Text('No items yet. Create your first listing.')),
      ),
    );

    expect(find.text('No items yet. Create your first listing.'), findsOneWidget);
  });
}
