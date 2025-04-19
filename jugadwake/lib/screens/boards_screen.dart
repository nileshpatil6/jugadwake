import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BoardsScreen extends StatelessWidget {
  const BoardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildBoardsSection(),
              const SizedBox(height: 16),
              Expanded(
                child: _buildBoardsGrid(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // Header with date, greeting and avatar
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '07 June 2023',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Hey Sobuj',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your boards looks great today!',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.amber,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              'S',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Boards section title with Add New button
  Widget _buildBoardsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Boards',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(
                Icons.add,
                size: 16,
                color: Colors.black87,
              ),
              const SizedBox(width: 4),
              Text(
                'Add New',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Grid of board cards
  Widget _buildBoardsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildBoardCard(
          title: 'Work',
          taskCount: 8,
          icon: Icons.work_outline,
          iconColor: Colors.brown,
          iconBgColor: Colors.brown.shade100,
          progressPercent: 0.7,
        ),
        _buildBoardCard(
          title: 'Personal Task',
          taskCount: 12,
          icon: Icons.favorite,
          iconColor: Colors.red,
          iconBgColor: Colors.red.shade100,
          progressPercent: 0.7,
          color: AppTheme.primary,
        ),
        _buildBoardCard(
          title: 'Meet',
          taskCount: 5,
          icon: Icons.people_outline,
          iconColor: Colors.orange,
          iconBgColor: Colors.orange.shade100,
          progressPercent: 0.8,
        ),
        _buildBoardCard(
          title: 'Private Task',
          taskCount: 6,
          icon: Icons.lock_outline,
          iconColor: Colors.blue,
          iconBgColor: Colors.blue.shade100,
          progressPercent: 0.4,
        ),
        _buildBoardCard(
          title: 'Event',
          taskCount: 6,
          isEvent: true,
          icon: Icons.event_note,
          iconColor: Colors.green,
          iconBgColor: Colors.green.shade100,
        ),
      ],
    );
  }

  // Individual board card
  Widget _buildBoardCard({
    required String title,
    required int taskCount,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    double progressPercent = 0.0,
    Color? color,
    bool isEvent = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              Icon(
                Icons.more_vert,
                color: color != null ? Colors.white : Colors.grey,
                size: 20,
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color != null ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isEvent ? '$taskCount Events' : '$taskCount Task',
            style: TextStyle(
              fontSize: 12,
              color: color != null ? Colors.white.withOpacity(0.8) : Colors.grey.shade600,
            ),
          ),
          if (progressPercent > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: color != null ? Colors.white.withOpacity(0.3) : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: progressPercent,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: color != null ? Colors.white : AppTheme.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(progressPercent * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color != null ? Colors.white : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Bottom navigation bar
  Widget _buildBottomNavBar() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.grid_view, 'Your Boards', isSelected: true),
          _buildNavItem(Icons.calendar_today_outlined, 'Calendar'),
          _buildNavItem(Icons.check_box_outlined, 'Tasks'),
          _buildNavItem(Icons.person_outline, 'Profile'),
        ],
      ),
    );
  }

  // Bottom navigation item
  Widget _buildNavItem(IconData icon, String label, {bool isSelected = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isSelected ? AppTheme.primary : Colors.grey,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? AppTheme.primary : Colors.grey,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
