import 'package:flutter_riverpod/flutter_riverpod.dart';

class WebSocketSubscriptionRegistry {
  final Map<String, Set<String>> _registry = <String, Set<String>>{};

  void subscribe({required String scope, required String channel}) {
    _registry.putIfAbsent(scope, () => <String>{}).add(channel);
  }

  void unsubscribe({required String scope, required String channel}) {
    final channels = _registry[scope];
    if (channels == null) {
      return;
    }

    channels.remove(channel);
    if (channels.isEmpty) {
      _registry.remove(scope);
    }
  }

  bool isSubscribed({required String scope, required String channel}) {
    return _registry[scope]?.contains(channel) ?? false;
  }

  Set<String> channelsForScope(String scope) {
    return Set<String>.unmodifiable(_registry[scope] ?? <String>{});
  }

  Map<String, Set<String>> snapshot() {
    return _registry.map(
      (scope, channels) => MapEntry(scope, Set<String>.unmodifiable(channels)),
    );
  }

  void clearScope(String scope) {
    _registry.remove(scope);
  }

  void clearAll() {
    _registry.clear();
  }
}

final websocketSubscriptionRegistryProvider =
    Provider<WebSocketSubscriptionRegistry>((ref) {
      return WebSocketSubscriptionRegistry();
    });
