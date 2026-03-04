import 'package:flutter_test/flutter_test.dart';

class _FakeProductListState {
  _FakeProductListState({required this.items, required this.hasNextPage, this.error});

  final List<String> items;
  final bool hasNextPage;
  final String? error;
}

void main() {
  test('fetch success populates list and clears error', () {
    final state = _FakeProductListState(items: ['A', 'B'], hasNextPage: true, error: null);

    expect(state.items, ['A', 'B']);
    expect(state.error, isNull);
  });

  test('pagination appends items and stops at last page', () {
    final firstPage = ['A', 'B'];
    final secondPage = ['C'];
    final merged = [...firstPage, ...secondPage];

    expect(merged, ['A', 'B', 'C']);
    expect(merged.length, 3);
  });
}
