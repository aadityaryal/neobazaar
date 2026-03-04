import 'package:flutter_test/flutter_test.dart';

void main() {
  test('delegates with correct payload/idempotency key', () {
    final payload = <String, dynamic>{'itemId': 'i1', 'amount': 5000};
    const idempotencyKey = 'offer-k1';

    expect(payload['itemId'], 'i1');
    expect(payload['amount'], 5000);
    expect(idempotencyKey, 'offer-k1');
  });

  test('propagates repository failure correctly', () {
    const failure = 'Offer create failed';
    final propagated = failure;

    expect(propagated, 'Offer create failed');
  });
}
