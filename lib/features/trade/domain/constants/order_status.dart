class OrderStatus {
  OrderStatus._();

  static const String pending = 'pending';
  static const String escrow = 'escrow';
  static const String completed = 'completed';
  static const String disputed = 'disputed';
  static const String refunded = 'refunded';

  static const Set<String> values = <String>{
    pending,
    escrow,
    completed,
    disputed,
    refunded,
  };
}
