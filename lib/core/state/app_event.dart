enum AppEventType {
  unauthorized,
  forbidden,
  notFound,
  conflict,
  info,
  warning,
  error,
}

class AppEvent {
  final AppEventType type;
  final String message;
  final DateTime createdAt;

  const AppEvent({
    required this.type,
    required this.message,
    required this.createdAt,
  });

  factory AppEvent.now({required AppEventType type, required String message}) {
    return AppEvent(type: type, message: message, createdAt: DateTime.now());
  }
}
