import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Selected segment in the horizontal control
  int _selectedSegment = 2; // Default to segment "23"

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusBar(),
                    _buildGreetingHeader(),
                    const SizedBox(height: 24),
                    _buildSegmentControl(),
                    const SizedBox(height: 24),
                    _buildTodaysTasks(),
                    const SizedBox(height: 16),
                    _buildTaskTimeline(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Build the status bar with hamburger menu, logo, and avatar
  Widget _buildStatusBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Hamburger menu
              Icon(Icons.menu, color: AppTheme.navyText, size: 24),
              const SizedBox(width: 16),
              // App logo/text
              Text(
                'VoiceFlow',
                style: TextStyle(
                  color: AppTheme.navyText,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          // User avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.lightBlue2,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Icon(Icons.person, color: AppTheme.primary, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  // Build greeting header with name and illustration
  Widget _buildGreetingHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Large greeting
                Text(
                  'Good Morning, Nilesh!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.navyText,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                // Try Saying "Hey Neo" with light blue texture
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.lightBlue2, AppTheme.lightBlue3],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(
                          0x4D9DB7FF,
                        ), // AppTheme.lightBlue4 with 30% opacity
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.mic, size: 16, color: AppTheme.navyText),
                      const SizedBox(width: 6),
                      Text(
                        'Try Saying "Hello Nova"',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.navyText,
                          letterSpacing: 0.5,
                          shadows: [
                            Shadow(
                              color: const Color(
                                0x78FFFFFF,
                              ), // Colors.white with 0.47 opacity
                              offset: const Offset(0, 1),
                              blurRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Subheading with time
                Row(
                  children: [
                    Text(
                      'Start the ',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                    Text(
                      '10:17',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.navyText,
                      ),
                    ),
                    Text(
                      ' tour of death',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Plant illustration
          SizedBox(
            width: 120,
            height: 120,
            child: Image.asset(
              'assets/plant.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.eco_outlined,
                  size: 80,
                  color: AppTheme.primary,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Build horizontal segment control
  Widget _buildSegmentControl() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppTheme.lightBlue1,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSegment('12', 0),
          _buildSegment('34', 1),
          _buildSegment('23', 2),
          _buildSegment('39', 3),
          _buildSegment('14', 4),
          _buildSegment('66', 5),
          // Additional icons from the image
          _buildIconSegment(Icons.settings, 6),
          _buildIconSegment(Icons.computer, 7),
          _buildIconSegment(Icons.person_outline, 8),
        ],
      ),
    );
  }

  // Build individual segment
  Widget _buildSegment(String label, int index) {
    final bool isSelected = _selectedSegment == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSegment = index;
        });
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.lightBlue2 : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                      spreadRadius: -2,
                    ),
                  ]
                  : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: AppTheme.navyText,
            ),
          ),
        ),
      ),
    );
  }

  // Build icon segment
  Widget _buildIconSegment(IconData icon, int index) {
    final bool isSelected = _selectedSegment == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSegment = index;
        });
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.lightBlue2 : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                      spreadRadius: -2,
                    ),
                  ]
                  : null,
        ),
        child: Center(child: Icon(icon, size: 16, color: AppTheme.navyText)),
      ),
    );
  }

  // Build Today's Tasks section
  Widget _buildTodaysTasks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Tasks",
              style: TextStyle(
                fontSize: 24,
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
                border: Border.all(color: AppTheme.lightBlue2, width: 1),
              ),
              child: Icon(
                Icons.card_giftcard,
                color: AppTheme.navyText,
                size: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Primary task card
        _buildPrimaryTaskCard(),
      ],
    );
  }

  // Build primary task card
  Widget _buildPrimaryTaskCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightBlue1,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side with badge and content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 10% badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.lightBlue2,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '10%',
                    style: TextStyle(
                      color: AppTheme.navyText,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Task title
                Text(
                  'Pu Ticond',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.navyText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Task completion of the first',
                  style: TextStyle(fontSize: 14, color: AppTheme.secondaryText),
                ),
                const SizedBox(height: 12),
                // Progress text
                Row(
                  children: [
                    Text(
                      'Progress, ',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                    Text(
                      '18/20',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.navyText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Plant illustration
          SizedBox(
            width: 80,
            height: 80,
            child: Image.asset(
              'assets/plant_small.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.spa_outlined,
                  size: 60,
                  color: AppTheme.primary,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Build task timeline
  Widget _buildTaskTimeline() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.lightBlue1, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Due tasks header
          Row(
            children: [
              _buildTimelineNode('DS', 'text'),
              const SizedBox(width: 12),
              Text(
                'Due Tasks',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.navyText,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.help_outline, size: 16, color: AppTheme.secondaryText),
              const Spacer(),
              // Vertical label - woid
              _buildVerticalLabel(
                'woid',
                AppTheme.lightBlue2,
                AppTheme.navyText,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Task 1
          _buildTimelineTask(
            'Task Name',
            'Noty, Nestinet Neh / sheatiter',
            Colors.red,
            false,
          ),
          const SizedBox(height: 16),
          // Task 2 with red node
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimelineNode('102', 'number', color: Colors.red.shade100),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTimelineTask(
                      'Wock',
                      'Mercier / Pead feditrating',
                      Colors.green,
                      false,
                    ),
                    const SizedBox(height: 16),
                    // Task 3
                    _buildTimelineTask('Coppertionh', '', Colors.blue, true),
                  ],
                ),
              ),
              // Vertical label - milestones
              _buildVerticalLabel(
                'milestones',
                Colors.red.shade100,
                Colors.red.shade900,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build timeline node
  Widget _buildTimelineNode(String text, String type, {Color? color}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: type == 'number' ? color ?? Colors.white : Colors.white,
        border:
            type == 'text'
                ? Border.all(color: AppTheme.lightBlue2, width: 2)
                : null,
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: type == 'number' ? AppTheme.navyText : AppTheme.navyText,
          ),
        ),
      ),
    );
  }

  // Build timeline task
  Widget _buildTimelineTask(
    String title,
    String subtitle,
    Color statusColor,
    bool isLast,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.navyText,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: AppTheme.tertiaryText),
                ),
              ],
            ],
          ),
        ),
        // Checkmark
        statusColor == Colors.red
            ? _buildCheckmark(Colors.red)
            : statusColor == Colors.green
            ? _buildCheckmark(Colors.green)
            : _buildCheckmark(Colors.blue),
      ],
    );
  }

  // Build checkmark
  Widget _buildCheckmark(Color color) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withAlpha(25),
        border: Border.all(color: color, width: 1),
      ),
      child: Center(child: Icon(Icons.check, size: 14, color: color)),
    );
  }

  // Build vertical label
  Widget _buildVerticalLabel(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: RotatedBox(
        quarterTurns: 1,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
