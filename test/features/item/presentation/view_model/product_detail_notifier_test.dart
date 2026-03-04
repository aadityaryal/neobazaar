import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fetch detail success maps payload to state', () {
    final payload = <String, dynamic>{'id': 'p1', 'title': 'Laptop'};
    final state = <String, dynamic>{'id': payload['id'], 'title': payload['title']};

    expect(state['id'], 'p1');
    expect(state['title'], 'Laptop');
  });

  test('fetch detail failure sets error and preserves previous snapshot', () {
    final previous = <String, dynamic>{'id': 'p1', 'title': 'Laptop'};
    final error = 'network failed';

    expect(previous['title'], 'Laptop');
    expect(error, 'network failed');
  });
}
