import 'package:flutter/material.dart';
import 'dart:math' as math;

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  // Selected day of the week (0 = Monday, 6 = Sunday)
  int _selectedDay = 2; // Wednesday selected by default

  // List of ongoing tasks
  final List<Map<String, dynamic>> _ongoingTasks = [
    {'title': 'Coffee Break with Lior', 'isCompleted': false},
    {'title': 'Git Product Launching', 'isCompleted': false},
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
              const SizedBox(height: 20),
              _buildProgressCircle(),
              const SizedBox(height: 30),
              _buildWeeklyChallenge(),
              const SizedBox(height: 20),
              _buildLegend(),
              const SizedBox(height: 20),
              _buildOngoingTasksHeader(),
              const SizedBox(height: 10),
              _buildOngoingTasksList(),
            ],
          ),
        ),
      ),
    );
  }

  // Build header with back button and menu
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () {
              // Navigate back
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show menu
            },
          ),
        ],
      ),
    );
  }

  // Build circular progress indicator
  Widget _buildProgressCircle() {
    return Center(
      child: SizedBox(
        width: 180,
        height: 180,
        child: CustomPaint(
          painter: CircularProgressPainter(),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  '78%',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1F3B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build weekly challenge section with days of week
  Widget _buildWeeklyChallenge() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weekly Challenge',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1F3B),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDayCircle('M', 0),
            _buildDayCircle('T', 1),
            _buildDayCircle('W', 2),
            _buildDayCircle('T', 3),
            _buildDayCircle('F', 4),
            _buildDayCircle('S', 5),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 80,
          child: CustomPaint(
            painter: ChartPainter(),
            size: Size(MediaQuery.of(context).size.width - 40, 80),
          ),
        ),
      ],
    );
  }

  // Build day circle for weekly challenge
  Widget _buildDayCircle(String day, int index) {
    final bool isSelected = _selectedDay == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDay = index;
        });
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? const Color(0xFF6C5DD3) : Colors.transparent,
        ),
        child: Center(
          child: Text(
            day,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF1A1F3B),
            ),
          ),
        ),
      ),
    );
  }

  // Build legend for the chart
  Widget _buildLegend() {
    return Row(
      children: [
        _buildLegendItem(const Color(0xFF6C5DD3), 'Completed Task'),
        const SizedBox(width: 20),
        _buildLegendItem(const Color(0xFFFFB800), 'Ongoing Task'),
      ],
    );
  }

  // Build legend item
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF1A1F3B)),
        ),
      ],
    );
  }

  // Build ongoing tasks header
  Widget _buildOngoingTasksHeader() {
    return const Text(
      'Ongoing Task',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1F3B),
      ),
    );
  }

  // Build ongoing tasks list
  Widget _buildOngoingTasksList() {
    return Column(
      children: _ongoingTasks.map((task) => _buildTaskItem(task)).toList(),
    );
  }

  // Build individual task item
  Widget _buildTaskItem(Map<String, dynamic> task) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.list, size: 20, color: Color(0xFF1A1F3B)),
                const SizedBox(width: 12),
                Text(
                  task['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1A1F3B),
                  ),
                ),
              ],
            ),
          ),
          Checkbox(
            value: task['isCompleted'],
            onChanged: (value) {
              setState(() {
                task['isCompleted'] = value;
              });
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: const BorderSide(width: 1, color: Color(0xFFE0E0E0)),
            activeColor: Colors.transparent,
            checkColor: Colors.green,
          ),
        ],
      ),
    );
  }
}

// Custom painter for circular progress indicator
class CircularProgressPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Define gradient colors for the progress arc
    final gradientColors = [
      const Color(0xFF6C5DD3), // Purple
      const Color(0xFFFFB800), // Yellow
      const Color(0xFFFF7A00), // Orange
    ];

    // Create gradient shader
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      colors: gradientColors,
      startAngle: -math.pi / 2,
      endAngle: 3 * math.pi / 2,
      tileMode: TileMode.clamp,
    ).createShader(rect);

    // Draw background circle
    final bgPaint =
        Paint()
          ..color = const Color(0xFFF5F5F5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12.0;

    canvas.drawCircle(center, radius - 6, bgPaint);

    // Draw progress arc
    final progressPaint =
        Paint()
          ..shader = gradient
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12.0
          ..strokeCap = StrokeCap.round;

    // 78% progress (0.78 * 2 * pi)
    const progress = 0.78;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 6),
      -math.pi / 2, // Start from top
      progress * 2 * math.pi,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Custom painter for the chart
class ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Define points for the purple line (completed tasks)
    final purplePoints = [
      Offset(0, height * 0.5),
      Offset(width * 0.2, height * 0.3),
      Offset(width * 0.4, height * 0.6),
      Offset(width * 0.6, height * 0.2),
      Offset(width * 0.8, height * 0.7),
      Offset(width, height * 0.4),
    ];

    // Define points for the yellow line (ongoing tasks)
    final yellowPoints = [
      Offset(0, height * 0.7),
      Offset(width * 0.2, height * 0.5),
      Offset(width * 0.4, height * 0.8),
      Offset(width * 0.6, height * 0.4),
      Offset(width * 0.8, height * 0.6),
      Offset(width, height * 0.5),
    ];

    // Draw purple line
    final purplePath = Path();
    purplePath.moveTo(purplePoints[0].dx, purplePoints[0].dy);

    for (int i = 1; i < purplePoints.length; i++) {
      final p0 = i > 0 ? purplePoints[i - 1] : purplePoints[0];
      final p1 = purplePoints[i];

      // Create a smooth curve
      final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);

      purplePath.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p1.dx,
        p1.dy,
      );
    }

    // Draw yellow line
    final yellowPath = Path();
    yellowPath.moveTo(yellowPoints[0].dx, yellowPoints[0].dy);

    for (int i = 1; i < yellowPoints.length; i++) {
      final p0 = i > 0 ? yellowPoints[i - 1] : yellowPoints[0];
      final p1 = yellowPoints[i];

      // Create a smooth curve
      final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);

      yellowPath.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p1.dx,
        p1.dy,
      );
    }

    // Draw the paths
    final purplePaint =
        Paint()
          ..color = const Color(0xFF6C5DD3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

    final yellowPaint =
        Paint()
          ..color = const Color(0xFFFFB800)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

    canvas.drawPath(purplePath, purplePaint);
    canvas.drawPath(yellowPath, yellowPaint);

    // Draw dots for the purple line
    final purpleDotPaint =
        Paint()
          ..color = const Color(0xFF6C5DD3)
          ..style = PaintingStyle.fill;

    // Draw dots for the yellow line
    final yellowDotPaint =
        Paint()
          ..color = const Color(0xFFFFB800)
          ..style = PaintingStyle.fill;

    // Draw dots at each point
    for (final point in purplePoints) {
      canvas.drawCircle(point, 4, purpleDotPaint);
    }

    for (final point in yellowPoints) {
      canvas.drawCircle(point, 4, yellowDotPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
