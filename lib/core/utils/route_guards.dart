import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/providers/app_session_provider.dart';
import 'package:neobazaar/core/providers/app_settings_provider.dart';
import 'package:neobazaar/core/providers/capability_cache_provider.dart';

class GuardDecision {
  final bool allowed;
  final String? reason;

  const GuardDecision({required this.allowed, this.reason});
}

GuardDecision authGuard(WidgetRef ref) {
  final session = ref.read(appSessionProvider);

  if (!session.sessionChecked) {
    return const GuardDecision(
      allowed: false,
      reason: 'Session not checked yet',
    );
  }

  if (!session.isAuthenticated) {
    return const GuardDecision(
      allowed: false,
      reason: 'Authentication required',
    );
  }

  return const GuardDecision(allowed: true);
}

GuardDecision adminGuard(WidgetRef ref) {
  final authDecision = authGuard(ref);
  if (!authDecision.allowed) {
    return authDecision;
  }

  final cache = ref.read(capabilityCacheProvider);
  final allowed =
      cache.has('admin:access') ||
      cache.has('admin:*') ||
      cache.has('role:admin');

  if (!allowed) {
    return const GuardDecision(
      allowed: false,
      reason: 'Admin capability required',
    );
  }

  return const GuardDecision(allowed: true);
}

GuardDecision sellerGuard(WidgetRef ref) {
  final authDecision = authGuard(ref);
  if (!authDecision.allowed) {
    return authDecision;
  }

  final settings = ref.read(appSettingsProvider);
  if (settings.uiMode == UiMode.seller) {
    return const GuardDecision(allowed: true);
  }

  final cache = ref.read(capabilityCacheProvider);
  final hasSellerCapability = cache.hasAny(const [
    'seller:access',
    'seller:*',
    'role:seller',
  ]);

  if (hasSellerCapability) {
    return const GuardDecision(allowed: true);
  }

  if (!hasSellerCapability) {
    return const GuardDecision(
      allowed: false,
      reason: 'Switch to Seller mode to access this page',
    );
  }

  return const GuardDecision(allowed: true);
}
