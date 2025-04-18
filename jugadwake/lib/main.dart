import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'widgets/voice_sphere_indicator.dart';
import 'widgets/voice_sphere_example.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JugadWake',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'JugadWake - Wake Word Detection'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Platform channel for communicating with native code
  static const MethodChannel _methodChannel = MethodChannel(
    'com.example.jugadwake/wake_word',
  );
  static const EventChannel _eventChannel = EventChannel(
    'com.example.jugadwake/transcription',
  );

  bool _serviceRunning = false;
  bool _permissionGranted = false;
  String _lastTranscription = '';
  final List<String> _transcriptionLog = [];
  bool _showDebugLog = false;
  StreamSubscription? _eventSubscription;

  // Lock screen overlay state
  bool _lockScreenOverlayEnabled = false;

  // Notification permission state
  bool _notificationPermissionGranted = false;

  // Voice sphere indicator key
  final GlobalKey<VoiceSphereIndicatorState> _voiceSphereKey = GlobalKey();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
    _checkServiceStatus();
    _checkLockScreenOverlayStatus();
    _checkNotificationPermission().then((_) {
      // Show persistent notification when app starts
      if (_notificationPermissionGranted) {
        _showPersistentNotification();
      }
    });
    _listenForTranscriptions();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  // Check if microphone permission is granted
  Future<void> _checkPermission() async {
    final status = await Permission.microphone.status;
    setState(() {
      _permissionGranted = status.isGranted;
    });
  }

  // Request microphone permission
  Future<void> _requestPermission() async {
    final status = await Permission.microphone.request();
    setState(() {
      _permissionGranted = status.isGranted;
    });

    if (status.isGranted) {
      _showSnackBar('Microphone permission granted');
    } else if (status.isPermanentlyDenied) {
      _showSnackBar(
        'Microphone permission denied permanently. Please enable in settings.',
      );
      // Open app settings
      await openAppSettings();
    } else {
      _showSnackBar('Microphone permission denied');
    }
  }

  // Check if the wake word service is running
  Future<void> _checkServiceStatus() async {
    try {
      final bool isRunning = await _methodChannel.invokeMethod(
        'isWakeWordServiceRunning',
      );
      setState(() {
        _serviceRunning = isRunning;
      });
    } on PlatformException catch (e) {
      _showSnackBar('Error checking service status: ${e.message}');
    }
  }

  // Check if the lock screen overlay is running
  Future<void> _checkLockScreenOverlayStatus() async {
    try {
      final bool isRunning = await _methodChannel.invokeMethod(
        'isLockScreenOverlayRunning',
      );
      setState(() {
        _lockScreenOverlayEnabled = isRunning;
      });
    } on PlatformException catch (e) {
      _showSnackBar('Error checking lock screen overlay status: ${e.message}');
    }
  }

  // Start the lock screen overlay
  Future<void> _startLockScreenOverlay() async {
    try {
      // Request overlay permission if needed
      if (await _methodChannel.invokeMethod('requestOverlayPermission')) {
        final bool success = await _methodChannel.invokeMethod(
          'startLockScreenOverlay',
        );
        if (success) {
          setState(() {
            _lockScreenOverlayEnabled = true;
          });
          _showSnackBar('Lock screen overlay started');
        } else {
          _showSnackBar('Permission needed for lock screen overlay');
        }
      } else {
        _showSnackBar('Overlay permission denied');
      }
    } on PlatformException catch (e) {
      _showSnackBar('Error starting lock screen overlay: ${e.message}');
    }
  }

  // Stop the lock screen overlay
  Future<void> _stopLockScreenOverlay() async {
    try {
      await _methodChannel.invokeMethod('stopLockScreenOverlay');
      setState(() {
        _lockScreenOverlayEnabled = false;
      });
      _showSnackBar('Lock screen overlay stopped');
    } on PlatformException catch (e) {
      _showSnackBar('Error stopping lock screen overlay: ${e.message}');
    }
  }

  // Check notification permission status
  Future<void> _checkNotificationPermission() async {
    try {
      final bool isGranted = await _methodChannel.invokeMethod(
        'requestNotificationPermission',
      );
      setState(() {
        _notificationPermissionGranted = isGranted;
      });
    } on PlatformException catch (e) {
      _showSnackBar('Error checking notification permission: ${e.message}');
    }
  }

  // Request notification permission
  Future<void> _requestNotificationPermission() async {
    try {
      final bool isGranted = await _methodChannel.invokeMethod(
        'requestNotificationPermission',
      );
      setState(() {
        _notificationPermissionGranted = isGranted;
      });

      if (isGranted) {
        _showSnackBar('Notification permission granted');
      } else {
        _showSnackBar('Please grant notification permission in settings');
      }
    } on PlatformException catch (e) {
      _showSnackBar('Error requesting notification permission: ${e.message}');
    }
  }

  // Start the wake word service
  Future<void> _startService() async {
    if (!_permissionGranted) {
      await _requestPermission();
      if (!_permissionGranted) return;
    }

    try {
      // Request battery optimization exemption
      await _methodChannel.invokeMethod('requestBatteryOptimizationDisable');

      // Start the service
      final bool success = await _methodChannel.invokeMethod(
        'startWakeWordService',
      );
      if (success) {
        setState(() {
          _serviceRunning = true;
        });
        _showSnackBar('Wake word service started');
      }
    } on PlatformException catch (e) {
      _showSnackBar('Error starting service: ${e.message}');
    }
  }

  // Stop the wake word service
  Future<void> _stopService() async {
    try {
      final bool success = await _methodChannel.invokeMethod(
        'stopWakeWordService',
      );
      if (success) {
        setState(() {
          _serviceRunning = false;
        });
        _showSnackBar('Wake word service stopped');
      }
    } on PlatformException catch (e) {
      _showSnackBar('Error stopping service: ${e.message}');
    }
  }

  // Listen for transcription updates from the native side
  void _listenForTranscriptions() {
    _eventSubscription = _eventChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        if (event is Map) {
          final String type = event['type'] as String;
          if (type == 'transcription') {
            final String text = event['text'] as String;
            setState(() {
              _lastTranscription = text;
              if (_transcriptionLog.length >= 10) {
                _transcriptionLog.removeAt(0);
              }
              _transcriptionLog.add(text);
            });
          } else if (type == 'wake_word_detected') {
            _showSnackBar('Wake word detected! 🔊');
            _onWakeWordDetected();
          }
        }
      },
      onError: (dynamic error) {
        _showSnackBar('Error receiving transcriptions: $error');
      },
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _toggleDebugLog() {
    setState(() {
      _showDebugLog = !_showDebugLog;
    });
  }

  // Handle wake word detection
  void _onWakeWordDetected() {
    setState(() {
      _isListening = true;
    });
    _voiceSphereKey.currentState?.startListening();

    // If lock screen overlay is enabled, show it
    if (_lockScreenOverlayEnabled) {
      // Check notification permission first
      if (!_notificationPermissionGranted) {
        _requestNotificationPermission().then((_) {
          if (_notificationPermissionGranted) {
            _showLockScreenAnimation();
          }
        });
      } else {
        _showLockScreenAnimation();
      }
    }

    // Start the timer to stop listening after 5 seconds
    _startListeningTimer();
  }

  // Show lock screen animation via notification
  Future<void> _showLockScreenAnimation() async {
    try {
      // Show the animation on the lock screen using the full-screen intent approach
      final success = await _methodChannel.invokeMethod(
        'showLockScreenAnimation',
      );
      if (!success) {
        _showSnackBar('Permission needed for lock screen animation');
      }
    } catch (error) {
      _showSnackBar('Error showing lock screen animation: $error');
    }
  }

  // Automatically stop listening after 5 seconds
  void _startListeningTimer() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isListening = false;
        });
        _voiceSphereKey.currentState?.stopListening();

        // No need to hide the lock screen animation as it auto-dismisses
      }
    });
  }

  // Show persistent notification that stays visible on lock screen
  Future<void> _showPersistentNotification() async {
    try {
      await _methodChannel.invokeMethod('showPersistentNotification');
    } catch (error) {
      _showSnackBar('Error showing persistent notification: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(_showDebugLog ? Icons.visibility_off : Icons.visibility),
            onPressed: _toggleDebugLog,
            tooltip: 'Toggle debug log',
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Status card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        _buildStatusRow(
                          'Microphone Permission',
                          _permissionGranted,
                          _requestPermission,
                        ),
                        const Divider(),
                        _buildStatusRow(
                          'Wake Word Service',
                          _serviceRunning,
                          _serviceRunning ? _stopService : _startService,
                        ),
                        const Divider(),
                        _buildStatusRow(
                          'Lock Screen Animation',
                          _lockScreenOverlayEnabled,
                          _lockScreenOverlayEnabled
                              ? _stopLockScreenOverlay
                              : _startLockScreenOverlay,
                        ),
                        const Divider(),
                        _buildStatusRow(
                          'Notification Permission',
                          _notificationPermissionGranted,
                          _requestNotificationPermission,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Info card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'How it works',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            if (_isListening)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.mic,
                                      color: Colors.blue.shade700,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Listening...',
                                      style: TextStyle(
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '1. Enable the wake word service using the toggle above',
                        ),
                        const SizedBox(height: 4),
                        const Text('2. Say "Hey boy" to wake up your device'),
                        const SizedBox(height: 4),
                        const Text(
                          '3. The service will continue to listen even when the app is closed',
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _showPersistentNotification,
                          child: const Text('Show Persistent Notification'),
                        ),
                      ],
                    ),
                  ),
                ),

                // Debug log (conditionally shown)
                if (_showDebugLog) ...[
                  const SizedBox(height: 16),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Debug Log',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(
                                  'Last heard: "$_lastTranscription"',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Divider(),
                            Expanded(
                              child: ListView.builder(
                                itemCount: _transcriptionLog.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4.0,
                                    ),
                                    child: Text(_transcriptionLog[index]),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Voice sphere indicator
          VoiceSphereIndicator(
            key: _voiceSphereKey,
            diameter: 160, // Adjustable size
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String title, bool enabled, VoidCallback onPressed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Row(
          children: [
            Text(
              enabled ? 'Enabled' : 'Disabled',
              style: TextStyle(
                color: enabled ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: onPressed,
              child: Text(enabled ? 'Disable' : 'Enable'),
            ),
          ],
        ),
      ],
    );
  }
}
