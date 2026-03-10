class CapabilityCache {
  final Set<String> capabilities;
  final DateTime syncedAt;

  const CapabilityCache({required this.capabilities, required this.syncedAt});

  factory CapabilityCache.empty() {
    return CapabilityCache(capabilities: <String>{}, syncedAt: DateTime.now());
  }

  bool has(String capability) => capabilities.contains(capability);

  bool hasAny(Iterable<String> required) {
    for (final capability in required) {
      if (capabilities.contains(capability)) {
        return true;
      }
    }
    return false;
  }
}
