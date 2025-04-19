import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Profile data structure remains the same
  final Map<String, dynamic> _profileData = {
    'name': 'Alex Johnson',
    'email': 'alex.johnson@example.com',
    'avatar': 'assets/avatar.svg',
    'stats': {
      'tasksTotal': 42,
      'tasksCompleted': 28,
      'currentStreak': 5,
      'efficiency': 85,
      'wakeWordAccuracy': 92,
    },
    'achievements': [
      {
        'name': 'Early Bird',
        'description': '7 days morning streak',
        'progress': 0.7,
      },
      {
        'name': 'Task Master',
        'description': '100 tasks completed',
        'progress': 0.28,
      },
      {
        'name': 'Perfect Week',
        'description': 'All tasks completed this week',
        'progress': 0.85,
      },
    ],
  };

  bool _isDarkMode = false;
  bool _isWakeWordEnabled = true;
  double _alarmVolume = 0.8;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
      _isWakeWordEnabled = prefs.getBool('wakeWordEnabled') ?? true;
      _alarmVolume = prefs.getDouble('alarmVolume') ?? 0.8;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Profile', style: theme.textTheme.headlineSmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primary, width: 3),
                      ),
                      child: ClipOval(
                        child: SvgPicture.asset(
                          _profileData['avatar'],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _profileData['name'],
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _profileData['email'],
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Stats Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  'Tasks',
                  '${_profileData['stats']['tasksCompleted']}/${_profileData['stats']['tasksTotal']}',
                  Icons.task_alt,
                  _calculateTaskProgress(),
                  theme,
                ),
                _buildStatCard(
                  'Efficiency',
                  '${_profileData['stats']['efficiency']}%',
                  Icons.trending_up,
                  _profileData['stats']['efficiency'] / 100,
                  theme,
                ),
                _buildStatCard(
                  'Wake Word',
                  '${_profileData['stats']['wakeWordAccuracy']}%',
                  Icons.record_voice_over,
                  _profileData['stats']['wakeWordAccuracy'] / 100,
                  theme,
                ),
                _buildStatCard(
                  'Streak',
                  '${_profileData['stats']['currentStreak']} days',
                  Icons.local_fire_department,
                  _profileData['stats']['currentStreak'] / 7,
                  theme,
                  accentColor: AppTheme.secondary,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Achievements Section
            Text('Achievements', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 16),
            ..._profileData['achievements']
                .map<Widget>(
                  (achievement) => _buildAchievementCard(
                    achievement['name'],
                    achievement['description'],
                    achievement['progress'],
                    theme,
                  ),
                )
                .toList(),
            const SizedBox(height: 32),

            // Settings Section
            Text('Settings', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 16),
            _buildSettingsCard(theme),
            const SizedBox(height: 24),

            // Sign Out Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Signing out...'),
                      duration: const Duration(seconds: 1),
                      backgroundColor: AppTheme.secondary,
                    ),
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondary.withOpacity(0.1),
                  foregroundColor: AppTheme.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTaskProgress() {
    return _profileData['stats']['tasksCompleted'] /
        _profileData['stats']['tasksTotal'];
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    double progress,
    ThemeData theme, {
    Color? accentColor,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: accentColor ?? AppTheme.primary),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodySmall),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppTheme.background,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    accentColor ?? AppTheme.primary,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(
    String title,
    String description,
    double progress,
    ThemeData theme,
  ) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: theme.textTheme.bodyLarge),
            Text(
              '${(progress * 100).toInt()}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: progress == 1.0 ? AppTheme.accent2 : AppTheme.textLight,
                fontWeight:
                    progress == 1.0 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(description, style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.background,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent1),
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(ThemeData theme) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: Text('Dark Mode', style: theme.textTheme.bodyLarge),
            value: _isDarkMode,
            activeColor: AppTheme.primary,
            onChanged: (bool value) {
              setState(() {
                _isDarkMode = value;
              });
              SharedPreferences.getInstance().then((prefs) {
                prefs.setBool('darkMode', value);
              });
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: Text(
              'Wake Word Detection',
              style: theme.textTheme.bodyLarge,
            ),
            value: _isWakeWordEnabled,
            activeColor: AppTheme.primary,
            onChanged: (bool value) {
              setState(() {
                _isWakeWordEnabled = value;
              });
              SharedPreferences.getInstance().then((prefs) {
                prefs.setBool('wakeWordEnabled', value);
              });
            },
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Alarm Volume', style: theme.textTheme.bodyLarge),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppTheme.primary,
                    inactiveTrackColor: AppTheme.background,
                    thumbColor: AppTheme.primary,
                    overlayColor: AppTheme.primary.withOpacity(0.1),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: _alarmVolume,
                    onChanged: (double value) {
                      setState(() {
                        _alarmVolume = value;
                      });
                      SharedPreferences.getInstance().then((prefs) {
                        prefs.setDouble('alarmVolume', value);
                      });
                    },
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
