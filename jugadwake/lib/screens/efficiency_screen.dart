import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_theme.dart';

class EfficiencyScreen extends StatelessWidget {
  const EfficiencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart_outlined, size: 64, color: AppTheme.primary),
              const SizedBox(height: 16),
              Text(
                'Efficiency',
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
        // Efficiency GIF in top-right corner
        Positioned(
          top: 16,
          right: 16,
          child: SizedBox(
            width: 64,
            height: 64,
            child: Lottie.network(
              'https://i.pinimg.com/originals/f9/6d/fb/f96dfb9f9d4e0b42af3888de8b9473a7.gif',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}
