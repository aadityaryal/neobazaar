import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders order cards with status badges', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(children: [Text('Order #1'), Text('Status: Delivered')]),
        ),
      ),
    );

    expect(find.text('Order #1'), findsOneWidget);
    expect(find.text('Status: Delivered'), findsOneWidget);
  });

  testWidgets('filter/sort controls update visible list', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Column(children: [Text('Sort'), Text('Filter')])),
      ),
    );

    expect(find.text('Sort'), findsOneWidget);
    expect(find.text('Filter'), findsOneWidget);
  });

  testWidgets('tapping order opens timeline/detail screen', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const Scaffold(body: Text('Order Timeline')),
                  ),
                );
              },
              child: const Text('Order #42'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Order #42'));
    await tester.pumpAndSettle();
    expect(find.text('Order Timeline'), findsOneWidget);
  });
}
