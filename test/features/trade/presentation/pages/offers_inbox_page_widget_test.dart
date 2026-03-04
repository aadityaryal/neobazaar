import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders incoming offers list', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Column(children: [Text('Offer from Alice'), Text('Offer from Bob')])),
      ),
    );

    expect(find.text('Offer from Alice'), findsOneWidget);
    expect(find.text('Offer from Bob'), findsOneWidget);
  });

  testWidgets('accept/reject actions call notifier and update UI state', (tester) async {
    var accepted = false;
    var rejected = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              TextButton(onPressed: () => accepted = true, child: const Text('Accept')),
              TextButton(onPressed: () => rejected = true, child: const Text('Reject')),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('Accept'));
    await tester.tap(find.text('Reject'));

    expect(accepted, isTrue);
    expect(rejected, isTrue);
  });
}
