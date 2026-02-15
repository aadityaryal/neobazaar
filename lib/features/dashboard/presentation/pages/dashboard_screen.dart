import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/constants/app_constants.dart';
import 'package:neobazaar/core/providers/app_settings_provider.dart';
import 'package:neobazaar/core/services/analytics/analytics_service.dart';
import 'package:neobazaar/core/widgets/reconnect_banner.dart';
import 'package:neobazaar/features/dashboard/presentation/pages/browse_screen.dart';
import 'package:neobazaar/features/dashboard/presentation/pages/home_screen.dart';
import 'package:neobazaar/features/dashboard/presentation/pages/message_screen.dart';
import 'package:neobazaar/features/dashboard/presentation/pages/profile_screen.dart';
import 'package:neobazaar/features/item/presentation/pages/my_items_page.dart';
import 'package:neobazaar/features/seller/presentation/pages/seller_studio_dashboard_page.dart';

List<BottomNavigationBarItem> dashboardNavItemsForMode(UiMode mode) {
  final isSellerMode = mode == UiMode.seller;
  return <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: const Icon(Icons.home),
      label: isSellerMode ? 'Studio' : 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(isSellerMode ? Icons.add_business : Icons.search),
      label: isSellerMode ? 'Listings' : 'Browse',
    ),
    const BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
    const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
  ];
}

class DashboardModeHeader extends StatelessWidget {
  final bool isSellerMode;
  final ValueChanged<bool> onToggle;
  final bool switchEnabled;

  const DashboardModeHeader({
    required this.isSellerMode,
    required this.onToggle,
    this.switchEnabled = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          Text(
            isSellerMode ? 'Seller Mode' : 'Buyer Mode',
            key: const Key('dashboard-mode-label'),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const Spacer(),
          Text(
            isSellerMode ? 'Buyer' : 'Seller',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Switch(
            key: const Key('dashboard-mode-switch'),
            value: isSellerMode,
            onChanged: switchEnabled ? onToggle : null,
          ),
        ],
      ),
    );
  }
}

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;
  bool _trackedFeatureFlagFallback = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final analytics = ref.read(analyticsServiceProvider);
    final isSellerMode = settings.uiMode == UiMode.seller;
    final modeSwitchEnabled = AppConstants.isFeatureEnabled(
      'buyer_seller_mode_switch',
    );

    if (!modeSwitchEnabled && isSellerMode && !_trackedFeatureFlagFallback) {
      _trackedFeatureFlagFallback = true;
      Future.microtask(() async {
        await ref.read(appSettingsProvider.notifier).resetUiMode();
        analytics.track(
          'feature_fallback_triggered',
          properties: {
            'feature': 'buyer_seller_mode_switch',
            'fallbackType': 'mode_reset',
            'reason': 'feature_flag_disabled',
          },
        );
      });
    }
    if (modeSwitchEnabled) {
      _trackedFeatureFlagFallback = false;
    }

    final screens = <Widget>[
      if (isSellerMode)
        const SellerStudioDashboardPage()
      else
        const HomeScreen(),
      if (isSellerMode) const MyItemsPage() else const BrowseScreen(),
      const MessageScreen(),
      const ProfileScreens(),
    ];
    final items = dashboardNavItemsForMode(settings.uiMode);
    final activeIndex = _currentIndex.clamp(0, screens.length - 1).toInt();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const ReconnectBanner(),
            DashboardModeHeader(
              isSellerMode: isSellerMode,
              switchEnabled: modeSwitchEnabled,
              onToggle: (enabled) async {
                final targetMode = enabled ? UiMode.seller : UiMode.buyer;
                analytics.track(
                  'mode_switch_requested',
                  properties: {
                    'fromMode': settings.uiMode.name,
                    'toMode': targetMode.name,
                  },
                );
                await ref
                    .read(appSettingsProvider.notifier)
                    .setUiMode(targetMode);
                analytics.track(
                  'mode_switch_success',
                  properties: {
                    'fromMode': settings.uiMode.name,
                    'toMode': targetMode.name,
                  },
                );
                setState(() {
                  _currentIndex = 0;
                });
              },
            ),
            if (!modeSwitchEnabled)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Seller mode switch is temporarily disabled.',
                    key: const Key('dashboard-mode-fallback-message'),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            Expanded(
              child: IndexedStack(index: activeIndex, children: screens),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: activeIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: items,
      ),
    );
  }
}
