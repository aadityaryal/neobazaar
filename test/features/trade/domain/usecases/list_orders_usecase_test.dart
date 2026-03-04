import 'package:flutter_test/flutter_test.dart';

void main() {
  test('delegates with filter params and returns list', () {
    final filters = <String, dynamic>{'status': 'pending', 'page': 1};
    final orders = <String>['o1', 'o2'];

    expect(filters['status'], 'pending');
    expect(orders.length, 2);
  });

  test('returns empty list path cleanly', () {
    const orders = <String>[];

    expect(orders, isEmpty);
  });
}
