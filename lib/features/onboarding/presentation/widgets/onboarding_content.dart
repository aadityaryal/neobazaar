import 'package:flutter/material.dart';
import '../../domain/entities/onboarding_item.dart';
import '../../../../app/theme/app_colors.dart';

class OnboardingContent extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingContent({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Icon Container
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  item.color.withAlpha(26), // 10% opacity
                  item.color.withAlpha(13), // 5% opacity
                ],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer Ring
                Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: item.color.withAlpha(51), // 20% opacity
                      width: 2,
                    ),
                  ),
                ),
                // Inner Ring
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: item.gradientColors,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: item.color.withAlpha(102), // 40% opacity
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    item.icon,
                    size: 90,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),

          // Title
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),

          // Description
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              height: 1.6,
              color: AppColors.textSecondary,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
