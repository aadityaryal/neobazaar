import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/providers/capability_cache_provider.dart';

/// Simple navigation utility class
class AppRoutes {
  AppRoutes._();

  /// Push a new route onto the stack
  static void push(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  /// Replace current route with a new one
  static void pushReplacement(BuildContext context, Widget page) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  /// Push a new route and remove all previous routes
  static void pushAndRemoveUntil(BuildContext context, Widget page) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => page),
      (route) => false,
    );
  }

  /// Pop the current route
  static void pop(BuildContext context) {
    Navigator.pop(context);
  }

  /// Pop to first route (root)
  static void popToFirst(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  /// Enforces admin capability checks before navigating to admin pages.
  /// Returns true when user has required capability and false otherwise.
  static bool requireAdmin(
    BuildContext context,
    WidgetRef ref, {
    Set<String> requiredCapabilities = const <String>{
      'admin:all',
      'admin:view',
    },
    String deniedMessage = 'You do not have access to this admin feature.',
  }) {
    final capabilities = ref.read(capabilityCacheProvider);
    if (capabilities.hasAny(requiredCapabilities)) {
      return true;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(deniedMessage)));
    return false;
  }
}
