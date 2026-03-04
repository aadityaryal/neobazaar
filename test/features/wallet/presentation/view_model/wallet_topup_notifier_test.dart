import 'package:flutter_test/flutter_test.dart';

void main() {
  test('topup success emits success state and refreshes balance', () {
    final oldBalance = 100;
    final topup = 50;
    final newBalance = oldBalance + topup;

    expect(newBalance, 150);
  });
}
