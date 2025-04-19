import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  // Helper method to get a color with opacity
  Color _getColorWithOpacity(Color color, double opacity) {
    if (color == Colors.blue) {
      return Color.fromARGB((255 * opacity).round(), 33, 150, 243);
    } else if (color == Colors.green) {
      return Color.fromARGB((255 * opacity).round(), 76, 175, 80);
    } else if (color == Colors.purple) {
      return Color.fromARGB((255 * opacity).round(), 156, 39, 176);
    } else if (color == Colors.orange) {
      return Color.fromARGB((255 * opacity).round(), 255, 152, 0);
    } else if (color == AppTheme.primary) {
      return Color.fromARGB((255 * opacity).round(), 14, 165, 233);
    } else {
      // Default fallback - use a fixed light blue color with opacity
      return Color.fromARGB((255 * opacity).round(), 33, 150, 243);
    }
  }

  // Sample reminder data
  final List<Map<String, dynamic>> _reminders = [
    {
      'title': 'Team Meeting',
      'time': '10:00 AM',
      'date': 'Today',
      'isCompleted': false,
      'category': 'Work',
      'categoryColor': Colors.blue,
    },
    {
      'title': 'Doctor Appointment',
      'time': '2:30 PM',
      'date': 'Tomorrow',
      'isCompleted': false,
      'category': 'Health',
      'categoryColor': Colors.green,
    },
    {
      'title': 'Call Mom',
      'time': '6:00 PM',
      'date': 'Today',
      'isCompleted': false,
      'category': 'Personal',
      'categoryColor': Colors.purple,
    },
    {
      'title': 'Submit Project Report',
      'time': '11:59 PM',
      'date': 'Friday',
      'isCompleted': false,
      'category': 'Work',
      'categoryColor': Colors.blue,
    },
    {
      'title': 'Grocery Shopping',
      'time': '4:00 PM',
      'date': 'Saturday',
      'isCompleted': false,
      'category': 'Errands',
      'categoryColor': Colors.orange,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildReminderCategories(),
              const SizedBox(height: 24),
              _buildUpcomingRemindersHeader(),
              const SizedBox(height: 16),
              Expanded(child: _buildRemindersList()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new reminder
        },
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Build header with title and search button
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Reminders',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.navyText,
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: IconButton(
              icon: const Icon(Icons.search, color: AppTheme.navyText),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  // Build reminder categories (horizontal scrolling)
  Widget _buildReminderCategories() {
    final List<Map<String, dynamic>> categories = [
      {'name': 'All', 'color': AppTheme.primary, 'count': _reminders.length},
      {
        'name': 'Work',
        'color': Colors.blue,
        'count': _reminders.where((r) => r['category'] == 'Work').length,
      },
      {
        'name': 'Personal',
        'color': Colors.purple,
        'count': _reminders.where((r) => r['category'] == 'Personal').length,
      },
      {
        'name': 'Health',
        'color': Colors.green,
        'count': _reminders.where((r) => r['category'] == 'Health').length,
      },
      {
        'name': 'Errands',
        'color': Colors.orange,
        'count': _reminders.where((r) => r['category'] == 'Errands').length,
      },
    ];

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final bool isSelected =
              index == 0; // First item (All) is selected by default
          final Color categoryColor = category['color'] as Color;
          final String categoryName = category['name'] as String;
          final int categoryCount = category['count'] as int;

          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? _getColorWithOpacity(categoryColor, 0.1)
                      : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? categoryColor : Colors.grey.shade200,
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _getColorWithOpacity(categoryColor, 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$categoryCount',
                      style: TextStyle(
                        color: categoryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  categoryName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? categoryColor : AppTheme.navyText,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Build upcoming reminders header with filter button
  Widget _buildUpcomingRemindersHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Upcoming Reminders',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.navyText,
          ),
        ),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.filter_list,
              size: 18,
              color: AppTheme.navyText,
            ),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  // Build reminders list
  Widget _buildRemindersList() {
    return ListView.builder(
      itemCount: _reminders.length,
      itemBuilder: (context, index) {
        final reminder = _reminders[index];
        return _buildReminderItem(reminder, index);
      },
    );
  }

  // Build individual reminder item
  Widget _buildReminderItem(Map<String, dynamic> reminder, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0D000000), // Colors.black with 5% opacity
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Checkbox
            GestureDetector(
              onTap: () {
                setState(() {
                  reminder['isCompleted'] = !reminder['isCompleted'];
                });
              },
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color:
                      reminder['isCompleted']
                          ? reminder['categoryColor']
                          : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: reminder['categoryColor'],
                    width: 2,
                  ),
                ),
                child:
                    reminder['isCompleted']
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
              ),
            ),
            const SizedBox(width: 16),
            // Reminder details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder['title'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.navyText,
                      decoration:
                          reminder['isCompleted']
                              ? TextDecoration.lineThrough
                              : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${reminder['time']} · ${reminder['date']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Category tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getColorWithOpacity(
                  reminder['categoryColor'] as Color,
                  0.1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                reminder['category'],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: reminder['categoryColor'],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
