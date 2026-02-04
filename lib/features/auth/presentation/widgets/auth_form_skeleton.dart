import 'package:flutter/material.dart';

class AuthFormSkeleton extends StatelessWidget {
  const AuthFormSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _SkeletonBox(height: 110, width: 110, radius: 16),
        SizedBox(height: 24),
        _SkeletonBox(height: 28, width: 220),
        SizedBox(height: 32),
        _SkeletonBox(height: 56),
        SizedBox(height: 16),
        _SkeletonBox(height: 56),
        SizedBox(height: 16),
        _SkeletonBox(height: 56),
        SizedBox(height: 28),
        _SkeletonBox(height: 48),
      ],
    );
  }
}

class StartupLoadingSkeleton extends StatelessWidget {
  const StartupLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          _SkeletonBox(height: 20, width: 180),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double height;
  final double width;
  final double radius;

  const _SkeletonBox({
    required this.height,
    this.width = double.infinity,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
