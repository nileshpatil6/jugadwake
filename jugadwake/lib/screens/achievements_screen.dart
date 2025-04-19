import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_theme.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background GIF with low opacity
        Positioned.fill(
          child: Opacity(
            opacity: 0.3,
            child: Center(
              child: Lottie.network(
                'https://i.pinimg.com/originals/f9/6d/fb/f96dfb9f9d4e0b42af3888de8b9473a7.gif',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        // Content
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 64,
                color: AppTheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Achievements',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Coming soon',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppTheme.textLight),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
