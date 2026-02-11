import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/providers/capability_cache_provider.dart';

class AdminCapabilityGate extends ConsumerWidget {
  final Set<String> requiredCapabilities;
  final Widget child;
  final Widget? fallback;

  const AdminCapabilityGate({
    super.key,
    required this.requiredCapabilities,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capabilities = ref.watch(capabilityCacheProvider);
    final isAllowed = capabilities.hasAny(requiredCapabilities);

    if (isAllowed) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}
