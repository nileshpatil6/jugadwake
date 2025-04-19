import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Custom bottom navigation bar with 5 items and smooth animations
class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with SingleTickerProviderStateMixin {
  // Animation controller for the sliding indicator
  late AnimationController _indicatorController;
  late Animation<double> _indicatorPositionAnimation;

  // Previous index to calculate animation direction
  late int _previousIndex;

  // Item width for positioning the indicator
  final double _itemWidth = 72.0;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.currentIndex;

    // Initialize animation controller
    _indicatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Initialize position animation
    _updateIndicatorPosition();
  }

  @override
  void didUpdateWidget(CustomBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the index changed, animate the indicator
    if (widget.currentIndex != oldWidget.currentIndex) {
      _previousIndex = oldWidget.currentIndex;
      _updateIndicatorPosition();
      _indicatorController.forward(from: 0.0);
    }
  }

  void _updateIndicatorPosition() {
    // Calculate start and end positions based on previous and current indices
    final double startPosition =
        _previousIndex * _itemWidth + (_itemWidth / 2 - 15);
    final double endPosition =
        widget.currentIndex * _itemWidth + (_itemWidth / 2 - 15);

    _indicatorPositionAnimation = Tween<double>(
      begin: startPosition,
      end: endPosition,
    ).animate(
      CurvedAnimation(parent: _indicatorController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _indicatorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Stack(
          children: [
            // Nav items row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.grid_view, 'Home'),
                _buildNavItem(1, Icons.calendar_today_outlined, 'Calendar'),
                _buildNavItem(2, Icons.check_box_outlined, 'Tasks'),
                _buildNavItem(3, Icons.smart_toy_outlined, 'AI'),
                _buildNavItem(4, Icons.person_outline, 'Profile'),
              ],
            ),
            // Animated sliding indicator
            Positioned(
              bottom: 0,
              child: AnimatedBuilder(
                animation: _indicatorController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_indicatorPositionAnimation.value, 0),
                    child: child,
                  );
                },
                child: Container(
                  width: 30,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build a navigation item with animation
  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = widget.currentIndex == index;

    return InkWell(
      onTap: () => widget.onTap(index),
      child: SizedBox(
        width: _itemWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with animated container
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    isSelected ? const Color(0x1A0EA5E9) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.8, end: isSelected ? 1.0 : 0.8),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Icon(
                  icon,
                  color: isSelected ? AppTheme.primary : Colors.grey,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Animated text
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppTheme.primary : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
