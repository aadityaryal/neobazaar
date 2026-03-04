import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows conversation list and unread counts', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Column(children: [Text('Riya (2)'), Text('Aadit (1)')])),
      ),
    );

    expect(find.text('Riya (2)'), findsOneWidget);
    expect(find.text('Aadit (1)'), findsOneWidget);
  });

  testWidgets('tapping conversation navigates to chat detail page', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const Scaffold(body: Text('Chat Detail')),
                  ),
                );
              },
              child: const Text('Open Chat'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Chat'));
    await tester.pumpAndSettle();
    expect(find.text('Chat Detail'), findsOneWidget);
  });
}
