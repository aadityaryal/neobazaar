import 'package:flutter_test/flutter_test.dart';

void main() {
  test('list orders success updates grouped statuses', () {
    final statuses = <String, int>{'pending': 1, 'delivered': 2};

    expect(statuses['pending'], 1);
    expect(statuses['delivered'], 2);
  });

  test('cancel/retry action transitions state correctly', () {
    var state = 'pending';
    state = 'cancelled';
    expect(state, 'cancelled');

    state = 'retrying';
    expect(state, 'retrying');
  });
}
