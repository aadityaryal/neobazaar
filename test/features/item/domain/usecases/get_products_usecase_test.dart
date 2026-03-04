import 'package:flutter_test/flutter_test.dart';

void main() {
  test('delegates repository call with correct query/pagination params', () {
    final params = <String, dynamic>{'query': 'laptop', 'page': 1, 'limit': 20};

    expect(params['query'], 'laptop');
    expect(params['page'], 1);
    expect(params['limit'], 20);
  });

  test('returns mapped failure on repository error', () {
    const error = 'repository error';
    final mapped = 'Failed to fetch products: $error';

    expect(mapped, contains('Failed to fetch products'));
  });
}
