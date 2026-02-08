import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/models/capability_cache.dart';

final capabilityCacheProvider =
    NotifierProvider<CapabilityCacheNotifier, CapabilityCache>(
      CapabilityCacheNotifier.new,
    );

class CapabilityCacheNotifier extends Notifier<CapabilityCache> {
  @override
  CapabilityCache build() => CapabilityCache.empty();

  void replaceAll(Iterable<String> capabilities) {
    state = CapabilityCache(
      capabilities: capabilities.toSet(),
      syncedAt: DateTime.now(),
    );
  }

  void clear() {
    state = CapabilityCache.empty();
  }
}
