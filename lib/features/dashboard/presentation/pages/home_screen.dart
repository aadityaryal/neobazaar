import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/app/routes/app_routes.dart';
import 'package:neobazaar/core/providers/app_settings_provider.dart';
import 'package:neobazaar/core/providers/device_sensor_provider.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/core/utils/snackbar_utils.dart';
import 'package:neobazaar/features/dashboard/presentation/view_model/dashboard_token_notifier.dart';
import 'package:neobazaar/features/dashboard/presentation/view_model/quests_teaser_notifier.dart';
import 'package:neobazaar/features/dashboard/presentation/widgets/menu_button.dart';
import 'package:neobazaar/features/dashboard/presentation/widgets/neobazaar_drawer.dart';
import 'package:neobazaar/features/dashboard/presentation/widgets/product_card.dart';
import 'package:neobazaar/features/dashboard/presentation/widgets/recommendation_carousel.dart';
import 'package:neobazaar/features/item/presentation/pages/product_detail_page.dart';
import 'package:neobazaar/features/item/presentation/view_model/product_list_notifier.dart';
import 'package:neobazaar/features/item/presentation/view_model/recommendation_notifier.dart';

class _ModeSection {
  final String key;
  final String label;

  const _ModeSection(this.key, this.label);
}

enum _TiltZone { left, neutral, right }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const double _leftTiltThreshold = -4.0;
  static const double _rightTiltThreshold = 4.0;
  static const Duration _tiltSequenceWindow = Duration(seconds: 2);
  static const Duration _tiltRefreshCooldown = Duration(seconds: 2);

  _TiltZone _tiltZone = _TiltZone.neutral;
  DateTime? _rightTiltAt;
  DateTime? _lastTiltRefreshAt;
  bool _refreshingFromTilt = false;
  String _selectedModeKey = 'all';

  static const List<_ModeSection> _modeSections = <_ModeSection>[
    _ModeSection('buy_now', 'Buy Now'),
    _ModeSection('auction', 'Auction'),
    _ModeSection('donate', 'Donate'),
    _ModeSection('other', 'Other Listings'),
  ];

  String _modeKey(String? mode) {
    final normalized = (mode ?? '').trim().toLowerCase();
    switch (normalized) {
      case 'buy_now':
      case 'auction':
      case 'donate':
        return normalized;
      default:
        return 'other';
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(recommendationNotifierProvider.notifier).fetch();
      await ref.read(productListNotifierProvider.notifier).refresh();
      await ref
          .read(questsTeaserNotifierProvider.notifier)
          .fetchActiveTeasers();
    });
  }

  Future<void> _refreshFromTilt() async {
    if (_refreshingFromTilt) {
      return;
    }

    _refreshingFromTilt = true;
    try {
      await ref.read(recommendationNotifierProvider.notifier).fetch();
      await ref.read(productListNotifierProvider.notifier).refresh();

      if (!mounted) {
        return;
      }
      SnackbarUtils.showInfo(context, 'Refreshed from tilt');
    } finally {
      _refreshingFromTilt = false;
    }
  }

  _TiltZone _zoneForTiltX(double x) {
    if (x <= _leftTiltThreshold) {
      return _TiltZone.left;
    }
    if (x >= _rightTiltThreshold) {
      return _TiltZone.right;
    }
    return _TiltZone.neutral;
  }

  void _handleTiltRefresh(
    AsyncValue<DeviceSensorState> state,
    bool gesturesEnabled,
  ) {
    if (!gesturesEnabled) {
      _tiltZone = _TiltZone.neutral;
      _rightTiltAt = null;
      return;
    }

    state.whenData((value) {
      final snapshot = value.snapshot;
      if (value.status != DeviceSensorStatus.active || snapshot == null) {
        return;
      }

      final currentZone = _zoneForTiltX(snapshot.accelerometer.x);
      final now = DateTime.now();

      final enteredRight =
          _tiltZone != _TiltZone.right && currentZone == _TiltZone.right;
      if (enteredRight) {
        _rightTiltAt = now;
      }

      final enteredLeft =
          _tiltZone != _TiltZone.left && currentZone == _TiltZone.left;

      if (enteredLeft && _rightTiltAt != null) {
        final elapsed = now.difference(_rightTiltAt!);
        if (elapsed <= _tiltSequenceWindow) {
          if (_lastTiltRefreshAt != null &&
              now.difference(_lastTiltRefreshAt!) < _tiltRefreshCooldown) {
            _tiltZone = currentZone;
            return;
          }
          _lastTiltRefreshAt = now;
          _rightTiltAt = null;
          _tiltZone = currentZone;
          _refreshFromTilt();
          return;
        }

        _rightTiltAt = null;
      }

      if (_rightTiltAt != null &&
          now.difference(_rightTiltAt!) > _tiltSequenceWindow) {
        _rightTiltAt = null;
      }

      _tiltZone = currentZone;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);

    ref.listen<AsyncValue<DeviceSensorState>>(deviceSensorStateProvider, (
      previous,
      next,
    ) {
      _handleTiltRefresh(next, settings.tiltRefreshEnabled);
    });

    final recommendations = ref.watch(recommendationNotifierProvider);
    final productList = ref.watch(productListNotifierProvider);
    final questsTeaser = ref.watch(questsTeaserNotifierProvider);
    final dashboardTokens = ref.watch(dashboardTokenNotifierProvider);

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 900
        ? 4
        : screenWidth > 600
        ? 3
        : 2;
    return SizedBox.expand(
      child: Scaffold(
        drawer: const NeoBazaarDrawer(),
        appBar: AppBar(
          leading: const MenuButton(),
          title: const Text('NeoBazaar'),
          actions: [
            IconButton(icon: const Icon(Icons.inbox), onPressed: () {}),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: Colors.orange,
                            size: 20,
                          ),
                          SizedBox(width: 6),
                          Text('Daily Streak: 3'),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(
                            Icons.monetization_on,
                            color: Colors.amber,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text('NeoTokens: ${dashboardTokens.tokenBalance}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'Demo: shake toggles theme globally, tilt right then left quickly to refresh.',
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Recommendations',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              RecommendationCarousel(
                state: recommendations,
                onRetry: () =>
                    ref.read(recommendationNotifierProvider.notifier).fetch(),
                onTapItem: (item) {
                  ref
                      .read(recommendationNotifierProvider.notifier)
                      .trackRecommendationClick(item);
                  AppRoutes.push(
                    context,
                    ProductDetailPage(productId: item.id),
                  );
                },
              ),
              if (questsTeaser.status == AsyncStatus.success &&
                  questsTeaser.items.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Card(
                    child: ListTile(
                      title: Text(
                        questsTeaser.items.first['title']?.toString() ??
                            'Active quest',
                      ),
                      subtitle: Text(
                        questsTeaser.items.first['description']?.toString() ??
                            'Complete tasks to earn rewards.',
                      ),
                    ),
                  ),
                ),
              if (questsTeaser.status == AsyncStatus.error)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('Unable to load quests teaser.'),
                ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Products',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: _selectedModeKey == 'all',
                      onSelected: (_) {
                        setState(() {
                          _selectedModeKey = 'all';
                        });
                      },
                    ),
                    ..._modeSections
                        .where((section) => section.key != 'other')
                        .map(
                          (section) => ChoiceChip(
                            label: Text(section.label),
                            selected: _selectedModeKey == section.key,
                            onSelected: (_) {
                              setState(() {
                                _selectedModeKey = section.key;
                              });
                            },
                          ),
                        ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (productList.status == AsyncStatus.loading &&
                  productList.items.isEmpty)
                const SizedBox(
                  height: 80,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (productList.status == AsyncStatus.error &&
                  productList.items.isEmpty)
                Center(
                  child: TextButton(
                    onPressed: () =>
                        ref.read(productListNotifierProvider.notifier).retry(),
                    child: const Text('Retry products'),
                  ),
                )
              else if (productList.items.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('No products found.'),
                )
              else
                ..._modeSections.map((section) {
                  if (_selectedModeKey != 'all' &&
                      _selectedModeKey != section.key) {
                    return const SizedBox.shrink();
                  }

                  final items = productList.items
                      .where((item) => _modeKey(item.mode) == section.key)
                      .toList(growable: false);

                  if (items.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                          child: Text(
                            section.label,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                childAspectRatio: 0.8,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return ProductCard(
                              imageUrl: item.imageUrls.isNotEmpty
                                  ? item.imageUrls.first
                                  : 'assets/images/products/image1.png',
                              title: item.title,
                              price: 'Rs. ${item.price}',
                              location: item.location ?? '-',
                              mode: item.mode,
                              onTap: () {
                                AppRoutes.push(
                                  context,
                                  ProductDetailPage(productId: item.id),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
