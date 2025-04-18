import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

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
  static const MethodChannel _methodChannel =
      MethodChannel('com.example.jugadwake/wake_word');
  static const EventChannel _eventChannel =
      EventChannel('com.example.jugadwake/transcription');

  bool _serviceRunning = false;
  bool _permissionGranted = false;
  String _lastTranscription = '';
  final List<String> _transcriptionLog = [];
  bool _showDebugLog = false;
  StreamSubscription? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _checkPermission();
    _checkServiceStatus();
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
          'Microphone permission denied permanently. Please enable in settings.');
      // Open app settings
      await openAppSettings();
    } else {
      _showSnackBar('Microphone permission denied');
    }
  }

  // Check if the wake word service is running
  Future<void> _checkServiceStatus() async {
    try {
      final bool isRunning =
          await _methodChannel.invokeMethod('isWakeWordServiceRunning');
      setState(() {
        _serviceRunning = isRunning;
      });
    } on PlatformException catch (e) {
      _showSnackBar('Error checking service status: ${e.message}');
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
      final bool success = await _methodChannel.invokeMethod('startWakeWordService');
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
      final bool success = await _methodChannel.invokeMethod('stopWakeWordService');
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _toggleDebugLog() {
    setState(() {
      _showDebugLog = !_showDebugLog;
    });
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
      body: Padding(
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
                    Text(
                      'How it works',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Enable the wake word service using the toggle above',
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '2. Say "Hey boy" to wake up your device',
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '3. The service will continue to listen even when the app is closed',
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
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
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
