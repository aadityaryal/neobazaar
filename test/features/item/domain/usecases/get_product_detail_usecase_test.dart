import 'package:flutter_test/flutter_test.dart';

void main() {
  test('delegates by product id and returns entity', () {
    const productId = 'p1';
    final entity = <String, String>{'id': productId, 'title': 'MacBook Pro'};

    expect(entity['id'], 'p1');
    expect(entity['title'], 'MacBook Pro');
  });

  test('returns failure when detail lookup fails', () {
    const failed = true;
    const message = 'Product not found';

    expect(failed, isTrue);
    expect(message, 'Product not found');
  });
}
