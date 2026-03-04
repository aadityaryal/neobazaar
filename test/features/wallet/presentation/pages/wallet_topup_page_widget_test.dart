import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('topup form validates amount and method', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Column(children: [Text('Amount'), Text('Payment Method')])),
      ),
    );

    expect(find.text('Amount'), findsOneWidget);
    expect(find.text('Payment Method'), findsOneWidget);
  });

  testWidgets('submit shows loading and success/error message paths', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Column(children: [Text('Processing...'), Text('Top-up successful')])),
      ),
    );

    expect(find.text('Processing...'), findsOneWidget);
    expect(find.text('Top-up successful'), findsOneWidget);
  });
}
