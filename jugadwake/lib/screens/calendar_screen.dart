import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with SingleTickerProviderStateMixin {
  // Current selected month and year
  late DateTime _currentMonth;
  late DateTime _selectedDate;

  // Scroll controller for detecting scroll position
  late ScrollController _scrollController;

  // Animation controller for calendar collapse
  late AnimationController _collapseController;
  // late Animation<double> _cornerRadiusAnimation; // No longer needed
  late Animation<double> _dayLabelOpacityAnimation;
  // late Animation<double> _gridIconOpacityAnimation; // No longer needed

  // Threshold for collapsing the calendar (in pixels)
  final double _collapseThreshold = 60.0;

  // Flag to track if calendar is collapsed
  bool _isCalendarCollapsed = false;

  // View type (day, week, month, schedule)
  String _currentView = 'Day';

  // No longer needed
  // bool _isEditMenuOpen = false;
  // late AnimationController _editMenuController;
  // late Animation<double> _editMenuAnimation;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _selectedDate = DateTime.now();
    _updateToday();

    // Initialize scroll controller
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Initialize animation controllers
    _collapseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // No longer needed
    // _editMenuController = AnimationController(
    //   vsync: this,
    //   duration: const Duration(milliseconds: 250),
    // );

    // Day label opacity animation (from 1.0 to 0.0)
    _dayLabelOpacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _collapseController, curve: Curves.easeInOut),
    );

    // No longer needed
    // _editMenuAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
    //   CurvedAnimation(parent: _editMenuController, curve: Curves.easeOutBack),
    // );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _collapseController.dispose();
    // _editMenuController.dispose(); // No longer needed
    super.dispose();
  }

  // Handle scroll events
  void _onScroll() {
    if (_scrollController.hasClients) {
      if (_scrollController.offset > _collapseThreshold &&
          !_isCalendarCollapsed) {
        // Collapse calendar
        _collapseController.forward();
        setState(() {
          _isCalendarCollapsed = true;
        });
      } else if (_scrollController.offset <= _collapseThreshold &&
          _isCalendarCollapsed) {
        // Expand calendar
        _collapseController.reverse();
        setState(() {
          _isCalendarCollapsed = false;
        });
      }
    }
  }

  // Update today's date when month changes
  void _updateToday() {
    // This method is kept for compatibility but no longer needs to track today
    // as we're using a simplified calendar view
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditMenu(context),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      // Spacer for collapsed calendar
                      SliverToBoxAdapter(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: _isCalendarCollapsed ? 56.0 : 0,
                        ),
                      ),
                      // Calendar grid (only visible when not collapsed)
                      SliverToBoxAdapter(
                        child: AnimatedOpacity(
                          opacity: _isCalendarCollapsed ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: _buildCalendarGrid(),
                          ),
                        ),
                      ),
                      // View selector
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _buildViewSelector(),
                        ),
                      ),
                      // Date picker strip
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: _buildDatePickerStrip(),
                        ),
                      ),
                      // Timeline grid
                      SliverPadding(
                        padding: const EdgeInsets.all(16.0),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildTimelineGrid(),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Collapsed calendar button (positioned at top)
            Positioned(
              top: 56 + 18, // Below title, 18px from left
              left: 18,
              child: Visibility(
                visible: _isCalendarCollapsed,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.darkBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.grid_view,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Top navigation bar with title and menu
  Widget _buildTopBar() {
    return Container(
      height: 56,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                size: 16,
                color: AppTheme.navyText,
              ),
              onPressed: () {},
            ),
            // Title
            Text(
              'Calendar',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.navyText,
              ),
            ),
            // Menu button
            IconButton(
              icon: const Icon(
                Icons.more_vert,
                size: 20,
                color: AppTheme.navyText,
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  // Change month by offset
  void _changeMonth(int offset) {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + offset,
        1,
      );
      _updateToday();
    });
  }

  // Show month picker
  void _showMonthPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Month',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    final month = index + 1;
                    final isSelected = month == _currentMonth.month;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _currentMonth = DateTime(
                            _currentMonth.year,
                            month,
                            1,
                          );
                          _updateToday();
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? AppTheme.primary
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                isSelected
                                    ? AppTheme.primary
                                    : Colors.grey.shade300,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _getMonthName(month),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Get month name from month number
  String _getMonthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return monthNames[month - 1];
  }

  // Calendar grid with weekday labels and date cells
  Widget _buildCalendarGrid() {
    return AnimatedBuilder(
      animation: _collapseController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.darkBlue,
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Month selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      size: 16,
                      color: Colors.white,
                    ),
                    onPressed: () => _changeMonth(-1),
                  ),
                  GestureDetector(
                    onTap: _showMonthPicker,
                    child: Row(
                      children: [
                        Text(
                          _getMonthName(_currentMonth.month),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.white,
                    ),
                    onPressed: () => _changeMonth(1),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Weekday labels
              Opacity(
                opacity: _dayLabelOpacityAnimation.value,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    _WeekdayLabel('Mon'),
                    _WeekdayLabel('Tue'),
                    _WeekdayLabel('Wed'),
                    _WeekdayLabel('Thu'),
                    _WeekdayLabel('Fri'),
                    _WeekdayLabel('Sat'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Date grid
              Opacity(
                opacity: _dayLabelOpacityAnimation.value,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(6, (index) {
                    final day = 13; // Example day number
                    final isSelected = index == 1; // Tuesday is selected

                    return Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color:
                            isSelected ? AppTheme.darkBlue : Colors.transparent,
                        shape: BoxShape.circle,
                        border:
                            isSelected
                                ? Border.all(color: Colors.white, width: 2)
                                : null,
                      ),
                      child: Center(
                        child: Text(
                          day.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // View selector dropdown
  Widget _buildViewSelector() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 4,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _currentView,
            icon: const Icon(Icons.arrow_drop_down, color: AppTheme.navyText),
            elevation: 0,
            style: const TextStyle(color: AppTheme.navyText),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _currentView = newValue;
                });
              }
            },
            items:
                <String>[
                  'Schedule',
                  'Day',
                  'Week',
                  'Month',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            value == _currentView
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  // Date picker strip with days of week
  Widget _buildDatePickerStrip() {
    // Get the current week's dates
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Find the start of the week (Sunday)
    final startOfWeek = today.subtract(Duration(days: today.weekday % 7));

    // Generate the week's dates
    final weekDates = List.generate(
      7,
      (index) => startOfWeek.add(Duration(days: index)),
    );

    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 16),
      height: 70,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(7, (index) {
            final date = weekDates[index];
            final isToday =
                date.day == today.day &&
                date.month == today.month &&
                date.year == today.year;
            final isSelected =
                date.day == _selectedDate.day &&
                date.month == _selectedDate.month &&
                date.year == _selectedDate.year;

            // Day of week abbreviation
            final dayName = DateFormat('E').format(date).substring(0, 3);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                },
                child: SizedBox(
                  width: 40,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Day name (Sun, Mon, etc)
                      Text(
                        dayName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color:
                              isToday || isSelected
                                  ? AppTheme.primary
                                  : AppTheme.navyText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Date number with pill background for today
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color:
                              isToday ? AppTheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                          border:
                              isSelected && !isToday
                                  ? Border.all(
                                    color: AppTheme.primary,
                                    width: 1.5,
                                  )
                                  : null,
                        ),
                        child: Center(
                          child: Text(
                            date.day.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color:
                                  isToday
                                      ? Colors.white
                                      : isSelected
                                      ? AppTheme.primary
                                      : AppTheme.navyText,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // Show edit menu
  void _showEditMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.add_task, color: AppTheme.primary),
                title: const Text('Add New Task'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Add New Task clicked')),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppTheme.primary,
                ),
                title: const Text('Remove Task'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Remove Task clicked')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // No longer needed
  // Widget _buildEditMenuItem({
  //   required IconData icon,
  //   required String label,
  //   required VoidCallback onTap,
  // }) {
  //   return InkWell(
  //     onTap: onTap,
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //       child: Row(
  //         children: [
  //           Icon(icon, size: 20, color: AppTheme.primary),
  //           const SizedBox(width: 12),
  //           Text(
  //             label,
  //             style: const TextStyle(
  //               fontSize: 14,
  //               fontWeight: FontWeight.w500,
  //               color: AppTheme.navyText,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Timeline grid with hour markers
  Widget _buildTimelineGrid() {
    // Hours from 8am to 7pm
    final hours = List.generate(12, (index) => index + 8);

    return Container(
      height: 600, // Fixed height for the timeline
      color: Colors.white,
      child: Column(
        children: [
          // Header for the timeline
          Container(
            padding: const EdgeInsets.only(bottom: 8),
            alignment: Alignment.centerLeft,
            child: const Text(
              'Daily Schedule',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.navyText,
              ),
            ),
          ),
          // Timeline content
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time gutter (left side with hour labels)
                SizedBox(
                  width: 60,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children:
                        hours.map((hour) {
                          // Format hour as 8:00 AM
                          final timeString =
                              DateFormat('h:00 a')
                                  .format(DateTime(2023, 1, 1, hour))
                                  .toLowerCase();

                          return Container(
                            height: 50,
                            padding: const EdgeInsets.only(right: 8),
                            alignment: Alignment.topRight,
                            child: Text(
                              timeString,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.secondaryText,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
                // Main grid area
                Expanded(
                  child: Column(
                    children:
                        hours.map((hour) {
                          return Container(
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: Colors.grey.withAlpha(51),
                                  width: 1,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Weekday label widget
class _WeekdayLabel extends StatelessWidget {
  final String label;

  const _WeekdayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
