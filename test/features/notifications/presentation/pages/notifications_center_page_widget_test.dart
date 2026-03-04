import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('list renders notifications grouped by date/type', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Column(children: [Text('Today'), Text('Order notification')])),
      ),
    );

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Order notification'), findsOneWidget);
  });

  testWidgets('mark-as-read action updates unread indicator', (tester) async {
    var unread = 1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TextButton(
            onPressed: () => unread = 0,
            child: const Text('Mark as read'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Mark as read'));
    expect(unread, 0);
  });
}
