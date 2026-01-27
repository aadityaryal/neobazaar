import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/state/app_event.dart';

final appEventBusProvider = NotifierProvider<AppEventBusNotifier, AppEvent?>(
  AppEventBusNotifier.new,
);

class AppEventBusNotifier extends Notifier<AppEvent?> {
  @override
  AppEvent? build() => null;

  void publish({required AppEventType type, required String message}) {
    state = AppEvent.now(type: type, message: message);
  }

  void clear() {
    state = null;
  }
}
