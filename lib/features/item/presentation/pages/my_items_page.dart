import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:neobazaar/app/routes/app_routes.dart';
import 'package:neobazaar/app/theme/app_colors.dart';
import 'package:neobazaar/app/theme/theme_extensions.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/dashboard/presentation/pages/post_screen.dart';
import 'package:neobazaar/features/seller/presentation/view_model/seller_studio_notifier.dart';

class MyItemsPage extends ConsumerStatefulWidget {
  const MyItemsPage({super.key});

  @override
  ConsumerState<MyItemsPage> createState() => _MyItemsPageState();
}

class _MyItemsPageState extends ConsumerState<MyItemsPage> {
  String _selectedMode = 'all';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sellerStudioNotifierProvider);
    final allListings = state.listingsAnalytics;


    final availableModes = <String>{
      'all',
      ...allListings
          .map((item) => _normalizeMode(item['mode']?.toString()))
          .where((mode) => mode != 'other'),
    }.toList(growable: false);

    final filteredListings = _selectedMode == 'all'
        ? allListings
        : allListings
              .where((item) {
                final mode = _normalizeMode(item['mode']?.toString());
                return mode == _selectedMode;
              })
              .toList(growable: false);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          AppRoutes.push(context, const PostScreen());
        },
        icon: const Icon(Icons.add_circle_outline_rounded),
        label: const Text('Create Listing'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(sellerStudioNotifierProvider.notifier).loadDashboard(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Seller Listings',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: context.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${filteredListings.length} listing(s) in view',
                            style: TextStyle(
                              fontSize: 14,
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        ref
                            .read(sellerStudioNotifierProvider.notifier)
                            .loadDashboard();
                      },
                      tooltip: 'Refresh listings',
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
              ),
              if (availableModes.length > 1)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableModes
                          .map(
                            (mode) => ChoiceChip(
                              label: Text(_modeLabel(mode)),
                              selected: _selectedMode == mode,
                              onSelected: (_) {
                                setState(() {
                                  _selectedMode = mode;
                                });
                              },
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ),
                ),
              Expanded(
                child: _buildBody(
                  context: context,
                  status: state.status,
                  error: state.error,
                  listings: filteredListings,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required AsyncStatus status,
    required String? error,
    required List<Map<String, dynamic>> listings,
  }) {
    if (status == AsyncStatus.loading && listings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (status == AsyncStatus.error && listings.isEmpty) {
      return _StatusPane(
        icon: Icons.error_outline_rounded,
        title: 'Unable to load seller listings',
        subtitle: error ?? 'Please check your connection and retry.',
        actionLabel: 'Retry',
        onAction: () {
          ref.read(sellerStudioNotifierProvider.notifier).loadDashboard();
        },
      );
    }

    if (listings.isEmpty) {
      return const _StatusPane(
        icon: Icons.inventory_2_outlined,
        title: 'No listings yet',
        subtitle: 'Create your first listing from Seller Studio.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      itemCount: listings.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final listing = listings[index];
        return _ListingCard(listing: listing);
      },
    );
  }

  String _normalizeMode(String? value) {
    final normalized = (value ?? '').trim().toLowerCase();
    if (normalized.isEmpty) {
      return 'other';
    }

    switch (normalized) {
      case 'buy_now':
      case 'buynow':
      case 'buy now':
      case 'fixed':
        return 'buy_now';
      case 'auction':
      case 'bid':
      case 'bidding':
        return 'auction';
      case 'donate':
      case 'donation':
        return 'donate';
      default:
        return 'other';
    }
  }

  String _modeLabel(String mode) {
    switch (mode) {
      case 'all':
        return 'All';
      case 'buy_now':
        return 'Buy Now';
      case 'auction':
        return 'Auction';
      case 'donate':
        return 'Donate';
      default:
        return 'Other';
    }
  }
}

class _ListingCard extends StatelessWidget {
  final Map<String, dynamic> listing;

  const _ListingCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    final title = listing['title']?.toString().trim();
    final thumbnailUrl = _extractThumbnailUrl(listing);
    final mode = _normalizeMode(listing['mode']?.toString());
    final status = listing['status']?.toString().trim();
    final category = listing['category']?.toString().trim();
    final location = listing['location']?.toString().trim();
    final createdAt = _formatCreatedAt(listing['createdAt']?.toString());
    final listedPrice = _parseAmount(
      listing['priceListed'] ?? listing['price'] ?? listing['aiSuggestedPrice'],
    );
    final hasViews = listing.containsKey('views');
    final hasClicks = listing.containsKey('clicks');
    final views = _parseCount(listing['views']);
    final clicks = _parseCount(listing['clicks']);

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
        boxShadow: context.softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 42,
                        height: 42,
                        child: _ListingImage(imageUrl: thumbnailUrl),
                      ),
                    ),
                    Positioned(
                      right: -1,
                      bottom: -1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _modeColor(mode),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: context.surfaceColor,
                            width: 1.5,
                          ),
                        ),
                        padding: const EdgeInsets.all(3),
                        child: Icon(_modeIcon(mode), color: Colors.white, size: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title == null || title.isEmpty ? 'Untitled Listing' : title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  icon: Icons.category_rounded,
                  text: _modeLabel(mode),
                  color: _modeColor(mode),
                ),
                if (status != null && status.isNotEmpty)
                  _InfoChip(
                    icon: Icons.flag_rounded,
                    text: status,
                    color: AppColors.info,
                  ),
                if (category != null && category.isNotEmpty)
                  _InfoChip(
                    icon: Icons.sell_rounded,
                    text: category,
                    color: AppColors.secondary,
                  ),
              ],
            ),
            if (createdAt != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: context.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    createdAt,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                _MetricTile(
                  icon: Icons.currency_rupee_rounded,
                  label: 'Listed Price',
                  value: listedPrice == null ? '-' : 'Rs. $listedPrice',
                ),
                const SizedBox(width: 10),
                _MetricTile(
                  icon: Icons.location_on_rounded,
                  label: 'Location',
                  value: (location == null || location.isEmpty)
                      ? '-'
                      : location,
                ),
              ],
            ),
            if (hasViews || hasClicks) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  _MetricTile(
                    icon: Icons.visibility_rounded,
                    label: 'Views',
                    value: '$views',
                  ),
                  const SizedBox(width: 10),
                  _MetricTile(
                    icon: Icons.ads_click_rounded,
                    label: 'Clicks',
                    value: '$clicks',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  static int _parseCount(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String? _parseAmount(dynamic value) {
    if (value is int) {
      return value.toString();
    }
    if (value is double) {
      return value == value.roundToDouble()
          ? value.toInt().toString()
          : value.toStringAsFixed(2);
    }
    if (value is num) {
      final asDouble = value.toDouble();
      return asDouble == asDouble.roundToDouble()
          ? asDouble.toInt().toString()
          : asDouble.toStringAsFixed(2);
    }

    final raw = value?.toString().trim();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final parsed = num.tryParse(raw);
    if (parsed == null) {
      return raw;
    }
    final asDouble = parsed.toDouble();
    return asDouble == asDouble.roundToDouble()
        ? asDouble.toInt().toString()
        : asDouble.toStringAsFixed(2);
  }

  static String? _formatCreatedAt(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      return raw;
    }

    final local = parsed.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return 'Created ${local.year}-$month-$day';
  }

  static String _normalizeMode(String? value) {
    final normalized = (value ?? '').trim().toLowerCase();
    switch (normalized) {
      case 'buy_now':
      case 'buynow':
      case 'buy now':
      case 'fixed':
        return 'buy_now';
      case 'auction':
      case 'bid':
      case 'bidding':
        return 'auction';
      case 'donate':
      case 'donation':
        return 'donate';
      default:
        return 'other';
    }
  }

  static String? _extractThumbnailUrl(Map<String, dynamic> item) {
    final images = item['images'];
    if (images is List && images.isNotEmpty) {
      final first = images.first;
      final asText = first?.toString().trim();
      if (asText != null && asText.isNotEmpty) {
        return asText;
      }
    }
    return null;
  }

  static String _modeLabel(String mode) {
    switch (mode) {
      case 'buy_now':
        return 'Buy Now';
      case 'auction':
        return 'Auction';
      case 'donate':
        return 'Donate';
      default:
        return 'Other';
    }
  }

  static IconData _modeIcon(String mode) {
    switch (mode) {
      case 'buy_now':
        return Icons.shopping_bag_rounded;
      case 'auction':
        return Icons.gavel_rounded;
      case 'donate':
        return Icons.volunteer_activism_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  static Color _modeColor(String mode) {
    switch (mode) {
      case 'buy_now':
        return AppColors.info;
      case 'auction':
        return AppColors.warning;
      case 'donate':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }
}

class _ListingImage extends StatelessWidget {
  final String? imageUrl;

  const _ListingImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return const ColoredBox(
        color: Colors.black12,
        child: Center(child: Icon(Icons.image_outlined, size: 18)),
      );
    }

    final url = imageUrl!;
    final isSvg = url.toLowerCase().endsWith('.svg');
    final isRemote = url.startsWith('http://') || url.startsWith('https://');
    final isLocalFilePath = url.startsWith('/') || url.startsWith('file://');

    if (isRemote) {
      if (isSvg) {
        return SvgPicture.network(
          url,
          fit: BoxFit.cover,
          placeholderBuilder: (_) => const ColoredBox(
            color: Colors.black12,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        );
      }
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const ColoredBox(
          color: Colors.black12,
          child: Center(child: Icon(Icons.image_not_supported, size: 16)),
        ),
      );
    }

    if (isLocalFilePath && !isSvg) {
      final filePath = url.startsWith('file://')
          ? Uri.parse(url).toFilePath()
          : url;
      return Image.file(
        File(filePath),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const ColoredBox(
          color: Colors.black12,
          child: Center(child: Icon(Icons.image_not_supported, size: 16)),
        ),
      );
    }

    if (isSvg) {
      return SvgPicture.asset(
        url,
        fit: BoxFit.cover,
        placeholderBuilder: (_) => const ColoredBox(
          color: Colors.black12,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }

    return Image.asset(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const ColoredBox(
        color: Colors.black12,
        child: Center(child: Icon(Icons.image_not_supported, size: 16)),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: context.surfaceVariantColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: context.textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondary,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPane extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _StatusPane({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 54, color: context.textTertiary),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: context.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
