import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String price;
  final String location;
  final String? mode;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.location,
    this.mode,
    this.onTap,
  });

  String _normalizedMode(String? raw) {
    return (raw ?? '').trim().toLowerCase();
  }

  String _modeLabel(String? raw) {
    switch (_normalizedMode(raw)) {
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

  Color _modeColor(BuildContext context, String? raw) {
    switch (_normalizedMode(raw)) {
      case 'buy_now':
        return Colors.green.shade700;
      case 'auction':
        return Colors.orange.shade700;
      case 'donate':
        return Colors.blue.shade700;
      default:
        return Theme.of(context).colorScheme.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: _ProductCardImage(imageUrl: imageUrl),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _modeColor(context, mode).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: _modeColor(context, mode)),
                    ),
                    child: Text(
                      _modeLabel(mode),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _modeColor(context, mode),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: const TextStyle(
                      // color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(location, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCardImage extends StatelessWidget {
  final String imageUrl;

  const _ProductCardImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final normalized = imageUrl.trim();
    final isSvg = imageUrl.toLowerCase().endsWith('.svg');
    final isRemote =
        normalized.startsWith('http://') || normalized.startsWith('https://');
    final isLocalFilePath =
        normalized.startsWith('/') || normalized.startsWith('file://');

    if (isRemote) {
      if (isSvg) {
        return SvgPicture.network(
          normalized,
          fit: BoxFit.cover,
          placeholderBuilder: (_) => const ColoredBox(
            color: Colors.black12,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        );
      }

      return Image.network(
        normalized,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
      );
    }

    if (isLocalFilePath && !isSvg) {
      final filePath = normalized.startsWith('file://')
          ? Uri.parse(normalized).toFilePath()
          : normalized;
      return Image.file(
        File(filePath),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
      );
    }

    if (isSvg) {
      return SvgPicture.asset(
        normalized,
        fit: BoxFit.cover,
        placeholderBuilder: (_) => const ColoredBox(
          color: Colors.black12,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }

    return Image.asset(
      normalized,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
    );
  }
}
