import 'package:flutter/painting.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppImageCachePolicy {
  final int maxMemoryEntries;
  final int maxMemoryBytes;
  final Duration diskStalePeriod;
  final int maxDiskObjects;

  const AppImageCachePolicy({
    this.maxMemoryEntries = 250,
    this.maxMemoryBytes = 120 * 1024 * 1024,
    this.diskStalePeriod = const Duration(days: 7),
    this.maxDiskObjects = 350,
  });

  void applyTo(ImageCache cache) {
    cache.maximumSize = maxMemoryEntries;
    cache.maximumSizeBytes = maxMemoryBytes;
  }
}

const AppImageCachePolicy _defaultAppImageCachePolicy = AppImageCachePolicy();

final appImageCachePolicyProvider = Provider<AppImageCachePolicy>((ref) {
  return _defaultAppImageCachePolicy;
});

final appImageCacheManagerProvider = Provider<BaseCacheManager>((ref) {
  final policy = ref.read(appImageCachePolicyProvider);
  return CacheManager(
    Config(
      'neobazaarImageCache',
      stalePeriod: policy.diskStalePeriod,
      maxNrOfCacheObjects: policy.maxDiskObjects,
    ),
  );
});

void configureGlobalImageCache({
  ImageCache? cache,
  AppImageCachePolicy policy = _defaultAppImageCachePolicy,
}) {
  final target = cache ?? PaintingBinding.instance.imageCache;
  policy.applyTo(target);
}
