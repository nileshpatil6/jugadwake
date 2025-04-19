import 'package:flutter/material.dart';
import 'dart:async';
import '../theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late DateTime _currentTime;
  late Timer _timer;

  // Featured task data
  final Map<String, dynamic> _featuredTask = {
    'title': 'PJ Ticond',
    'description': 'Task completion one hour',
    'progress': 0.1,
    'date': '18 2021',
  };

  // Tasks data
  final List<Map<String, dynamic>> _tasks = [
    {
      'id': 'DS',
      'name': 'Task Name',
      'description': 'Notiy, Nestined Neh/Jeafter',
      'isCompleted': false,
      'type': 'due',
    },
    {
      'id': '102',
      'name': 'Wock',
      'description': 'Meroicc/Pead fedtrating',
      'isCompleted': true,
      'type': 'work',
    },
    {
      'id': '',
      'name': 'Coppetionh',
      'description': '',
      'isCompleted': true,
      'type': 'milestone',
    },
    {
      'id': '',
      'name': 'Cermecation',
      'description': '',
      'isCompleted': false,
      'type': '',
    },
  ];

  // Stats data
  final List<Map<String, dynamic>> _stats = [
    {'value': '12', 'isHighlighted': true},
    {'value': '34', 'isHighlighted': true},
    {'value': '23', 'isHighlighted': true},
    {'value': '39', 'isHighlighted': false},
    {'value': '14', 'isHighlighted': false},
    {'value': '66', 'isHighlighted': false},
    {'value': '', 'isHighlighted': false, 'isIcon': true, 'icon': Icons.sunny},
    {'value': '', 'isHighlighted': false, 'isIcon': true, 'icon': Icons.cloud},
    {
      'value': '',
      'isHighlighted': false,
      'isIcon': true,
      'icon': Icons.umbrella
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Initialize time
    _currentTime = DateTime.now();

    // Update time every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer.cancel();
    super.dispose();
  }

  // Toggle task completion status
  void _toggleTaskCompletion(int index) {
    setState(() {
      _tasks[index]['isCompleted'] = !_tasks[index]['isCompleted'];

      // Sort tasks - completed tasks go to the bottom
      _tasks.sort((a, b) {
        if (a['isCompleted'] && !b['isCompleted']) return 1;
        if (!a['isCompleted'] && b['isCompleted']) return -1;
        return 0;
      });

      // Play animation
      if (_tasks[index]['isCompleted']) {
        _animationController.forward(from: 0.0);
      }
    });
  }

  // Get greeting based on time of day
  String _getGreeting() {
    final hour = _currentTime.hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  // Format time as HH:MM
  String _formatTime() {
    final hour = _currentTime.hour.toString().padLeft(2, '0');
    final minute = _currentTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Light grey background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildGreetingSection(),
                const SizedBox(height: 24),
                _buildStatsRow(),
                const SizedBox(height: 24),
                _buildFeaturedTaskCard(),
                const SizedBox(height: 24),
                _buildTasksSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Header with app name and profile picture
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.menu, size: 24),
            const SizedBox(width: 12),
            const Text(
              'VoiceFlow',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.blue.shade100,
            image: const DecorationImage(
              image: NetworkImage(
                'https://cdn-icons-png.flaticon.com/512/4140/4140048.png',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  // Greeting section with time
  Widget _buildGreetingSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_getGreeting()},',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Text(
                'Nilesh!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Sort the',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatTime(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'for death',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          width: 120,
          height: 120,
          child: Image.network(
            'https://cdn-icons-png.flaticon.com/512/6681/6681204.png',
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  // Stats row
  Widget _buildStatsRow() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _stats.map((stat) {
          final bool isHighlighted = stat['isHighlighted'] ?? false;
          final bool isIcon = stat['isIcon'] ?? false;

          if (isIcon) {
            return Icon(
              stat['icon'],
              size: 20,
              color: Colors.grey.shade400,
            );
          }

          return Text(
            stat['value'],
            style: TextStyle(
              fontSize: 16,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              color: isHighlighted ? Colors.black : Colors.grey.shade400,
            ),
          );
        }).toList(),
      ),
    );
  }

  // Featured task card
  Widget _buildFeaturedTaskCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(128),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '10%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _featuredTask['title'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _featuredTask['description'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue.shade800,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Progress,',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _featuredTask['date'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: 80,
            height: 80,
            child: Image.network(
              'https://cdn-icons-png.flaticon.com/512/3309/3309960.png',
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  // Tasks section
  Widget _buildTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Today\'s Tasks',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTasksList(),
      ],
    );
  }

  // Tasks list
  Widget _buildTasksList() {
    return ListView.builder(
      itemCount: _tasks.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              // Left indicator
              if (task['id'].isNotEmpty)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: task['id'] == 'DS'
                        ? Colors.blue.shade100
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      task['id'],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: task['id'] == 'DS'
                            ? Colors.blue.shade800
                            : Colors.red,
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(width: 40),
              const SizedBox(width: 12),
              // Task content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: task['isCompleted']
                            ? Colors.grey.shade400
                            : Colors.black,
                        decoration: task['isCompleted']
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (task['description'].isNotEmpty)
                      Text(
                        task['description'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
              // Right side - task type indicator
              if (task['type'] == 'due')
                Container(
                  width: 40,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Center(
                      child: Text(
                        'Due yeoscots',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                  ),
                )
              else if (task['type'] == 'work')
                Container(
                  width: 40,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Center(
                      child: Text(
                        'milestcs',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                )
              else
                // Checkbox for completion
                GestureDetector(
                  onTap: () => _toggleTaskCompletion(index),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task['isCompleted']
                          ? Colors.blue.shade400
                          : Colors.white,
                      border: Border.all(
                        color: task['isCompleted']
                            ? Colors.blue.shade400
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: task['isCompleted']
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
