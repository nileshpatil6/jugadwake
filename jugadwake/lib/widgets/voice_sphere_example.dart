import 'package:flutter/material.dart';
import 'voice_sphere_indicator.dart';

/// Example widget showing how to use the VoiceSphereIndicator.
class VoiceSphereExample extends StatefulWidget {
  const VoiceSphereExample({super.key});

  @override
  State<VoiceSphereExample> createState() => _VoiceSphereExampleState();
}

class _VoiceSphereExampleState extends State<VoiceSphereExample> {
  // Create a global key to access the VoiceSphereIndicator state
  final GlobalKey<VoiceSphereIndicatorState> _voiceSphereKey = GlobalKey();
  bool _isListening = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Sphere Example'),
      ),
      body: Stack(
        children: [
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isListening ? 'Listening...' : 'Say "Hey boy" to activate',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _toggleListening,
                  child: Text(_isListening ? 'Stop Listening' : 'Start Listening'),
                ),
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

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
      
      if (_isListening) {
        _voiceSphereKey.currentState?.startListening();
      } else {
        _voiceSphereKey.currentState?.stopListening();
      }
    });
  }

  // This method would be called when the wake word is detected
  void _onWakeWordDetected() {
    setState(() {
      _isListening = true;
    });
    _voiceSphereKey.currentState?.startListening();
    
    // Simulate stopping after 5 seconds (in a real app, this would be triggered
    // when voice command processing is complete)
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _isListening = false;
      });
      _voiceSphereKey.currentState?.stopListening();
    });
  }
}
