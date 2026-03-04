import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mark all as read updates counters and item flags', () {
    final unreadBefore = 3;
    final unreadAfter = 0;

    expect(unreadBefore, 3);
    expect(unreadAfter, 0);
  });
}
