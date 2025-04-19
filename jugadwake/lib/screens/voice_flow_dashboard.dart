import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class VoiceFlowDashboard extends StatefulWidget {
  const VoiceFlowDashboard({super.key});

  @override
  State<VoiceFlowDashboard> createState() => _VoiceFlowDashboardState();
}

class _VoiceFlowDashboardState extends State<VoiceFlowDashboard> with SingleTickerProviderStateMixin {
  // Animation controller for task completion animation
  late AnimationController _animationController;
  
  // Current time
  late DateTime _currentTime;
  late Timer _timer;
  
  // Task data
  final List<Map<String, dynamic>> _tasks = [
    {
      'id': '1',
      'name': 'Task Name',
      'description': 'Notiy, Nestined Neh/Jeafter',
      'isCompleted': false,
      'priority': 'medium',
    },
    {
      'id': '2',
      'name': 'Wock',
      'description': 'Meroicc/Pead fedurating',
      'isCompleted': true,
      'priority': 'low',
    },
    {
      'id': '3',
      'name': 'Coppetionh',
      'description': 'Task description here',
      'isCompleted': true,
      'priority': 'high',
    },
    {
      'id': '4',
      'name': 'Cermecation',
      'description': 'Another task description',
      'isCompleted': false,
      'priority': 'medium',
    },
  ];
  
  // Featured task
  final Map<String, dynamic> _featuredTask = {
    'id': 'featured1',
    'name': 'PJ Ticond',
    'description': 'Task completion one month',
    'progress': 0.1,
    'date': '18 2021',
  };
  
  // Stats data
  final List<Map<String, dynamic>> _stats = [
    {'value': '12', 'isHighlighted': true},
    {'value': '34', 'isHighlighted': true},
    {'value': '23', 'isHighlighted': true},
    {'value': '39', 'isHighlighted': false},
    {'value': '14', 'isHighlighted': false},
    {'value': '66', 'isHighlighted': false},
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
    return DateFormat('HH:mm').format(_currentTime);
  }
  
  // Get color for priority indicator
  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red.shade200;
      case 'medium':
        return Colors.blue.shade200;
      case 'low':
        return Colors.green.shade200;
      default:
        return Colors.grey.shade200;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(),
              const SizedBox(height: 20),
              _buildGreetingSection(),
              const SizedBox(height: 20),
              _buildStatsRow(),
              const SizedBox(height: 30),
              _buildTodayTasksHeader(),
              const SizedBox(height: 16),
              _buildFeaturedTask(),
              const SizedBox(height: 20),
              _buildDueTasksSection(),
              Expanded(
                child: _buildTasksList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // App bar with logo and profile
  Widget _buildAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.menu,
              color: Colors.black87,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text(
              'VoiceFlow',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.shade300,
            borderRadius: BorderRadius.circular(10),
            image: const DecorationImage(
              image: AssetImage('assets/images/profile.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
  
  // Greeting section with time and illustration
  Widget _buildGreetingSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_getGreeting()},',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                'Nilesh!',
                style: const TextStyle(
                  fontSize: 32,
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
          child: Image.asset(
            'assets/images/plant_illustration.png',
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
  
  // Stats row with numbers
  Widget _buildStatsRow() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _stats.map((stat) {
          return Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: stat['isHighlighted'] 
                  ? Colors.blue.shade50 
                  : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                stat['value'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: stat['isHighlighted'] 
                      ? Colors.blue.shade700 
                      : Colors.grey.shade400,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  // Today's tasks header with button
  Widget _buildTodayTasksHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Today\'s Tasks',
          style: TextStyle(
            fontSize: 24,
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
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Center(
            child: Icon(
              Icons.add,
              color: Colors.black87,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
  
  // Featured task with progress
  Widget _buildFeaturedTask() {
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(100),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(_featuredTask['progress'] * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _featuredTask['name'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _featuredTask['description'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87.withAlpha(180),
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
            child: Image.asset(
              'assets/images/plant_small.png',
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
  
  // Due tasks section header
  Widget _buildDueTasksSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'DS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Due Tasks',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.question_mark,
                size: 16,
                color: Colors.black54,
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'De yeoscots',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Tasks list
  Widget _buildTasksList() {
    return ListView.builder(
      itemCount: _tasks.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              // Left indicator
              if (index == 0)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      '102',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(width: 40),
              
              // Task details
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
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
                      
                      // Checkmark
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: task['isCompleted']
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            task['isCompleted']
                                ? Icons.check
                                : Icons.close,
                            size: 18,
                            color: task['isCompleted']
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Right indicator
              if (index == 1)
                Container(
                  width: 40,
                  height: 80,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(task['priority']),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Center(
                      child: Text(
                        'milestcs',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade800,
                        ),
                      ),
                    ),
                  ),
                )
              else if (index == 0)
                Container(
                  width: 40,
                  height: 80,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const RotatedBox(
                    quarterTurns: 3,
                    child: Center(
                      child: Text(
                        'world',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(width: 40),
            ],
          ),
        );
      },
    );
  }
}
