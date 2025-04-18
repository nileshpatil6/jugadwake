import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A widget that mimics Google Assistant's listening orb.
///
/// This widget displays a 3D spinning sphere with a glossy finish and subtle
/// pulsing glow when activated. It's designed to provide visual feedback
/// during voice interactions.
class VoiceSphereIndicator extends StatefulWidget {
  /// Creates a VoiceSphereIndicator.
  ///
  /// The [diameter] parameter controls the size of the sphere.
  const VoiceSphereIndicator({
    super.key,
    this.diameter = 160.0,
  });

  /// The diameter of the sphere in pixels.
  final double diameter;

  @override
  State<VoiceSphereIndicator> createState() => VoiceSphereIndicatorState();
}

class VoiceSphereIndicatorState extends State<VoiceSphereIndicator>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _visibilityController;

  // Animations
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowRadiusAnimation;
  late Animation<double> _visibilityAnimation;

  // Colors
  final Color _baseColor = const Color(0xFF1A237E); // Deep midnight blue
  final Color _highlightColor = const Color(0xFF00BFA5); // Cyan-teal
  final Color _accentColor1 = const Color(0xFF7C4DFF); // Violet
  final Color _accentColor2 = const Color(0xFF18FFFF); // Aqua

  @override
  void initState() {
    super.initState();

    // Rotation animation (continuous 360° spin)
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rotationAnimation = CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    );

    // Pulse animation (scale and glow)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
    _glowRadiusAnimation = Tween<double>(begin: 8.0, end: 16.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Visibility animation (fade in/out)
    _visibilityController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _visibilityAnimation = CurvedAnimation(
      parent: _visibilityController,
      curve: Curves.easeOut,
    );

    // Initially hidden
    _visibilityController.value = 0.0;
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _visibilityController.dispose();
    super.dispose();
  }

  /// Starts the listening animation.
  ///
  /// This method fades in the sphere and starts the rotation and pulse animations.
  void startListening() {
    _visibilityController.forward();
    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
  }

  /// Stops the listening animation.
  ///
  /// This method fades out the sphere and stops all animations.
  void stopListening() {
    _visibilityController.reverse().then((_) {
      _rotationController.stop();
      _pulseController.stop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _rotationAnimation,
        _pulseAnimation,
        _visibilityAnimation,
      ]),
      builder: (context, child) {
        return Positioned(
          bottom: 24.0, // 24px above bottom edge
          left: 0,
          right: 0,
          child: Center(
            child: Opacity(
              opacity: _visibilityAnimation.value,
              child: Transform.scale(
                scale: _visibilityAnimation.value * _pulseAnimation.value,
                child: Container(
                  width: widget.diameter,
                  height: widget.diameter,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _highlightColor.withOpacity(0.3),
                        blurRadius: _glowRadiusAnimation.value,
                        spreadRadius: _glowRadiusAnimation.value / 2,
                      ),
                    ],
                  ),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // Perspective
                      ..rotateY(_rotationController.value * 2 * math.pi),
                    child: _buildSphere(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSphere() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(0.3, -0.3), // Light source position
          radius: 0.8,
          colors: [
            _highlightColor,
            _baseColor,
          ],
          stops: const [0.1, 1.0],
        ),
      ),
      child: CustomPaint(
        painter: _SpherePainter(
          accentColor1: _accentColor1,
          accentColor2: _accentColor2,
          rotationValue: _rotationController.value,
        ),
        child: Container(), // Empty container for sizing
      ),
    );
  }
}

/// Custom painter for drawing the iridescent accent rings on the sphere.
class _SpherePainter extends CustomPainter {
  _SpherePainter({
    required this.accentColor1,
    required this.accentColor2,
    required this.rotationValue,
  });

  final Color accentColor1;
  final Color accentColor2;
  final double rotationValue;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw multiple concentric rings with varying opacity
    for (int i = 1; i <= 3; i++) {
      final ringRadius = radius * (0.5 + i * 0.15);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..shader = SweepGradient(
          colors: [
            accentColor1.withOpacity(0.6 - i * 0.15),
            accentColor2.withOpacity(0.6 - i * 0.15),
            accentColor1.withOpacity(0.6 - i * 0.15),
          ],
          stops: const [0.0, 0.5, 1.0],
          transform: GradientRotation(rotationValue * 2 * math.pi),
        ).createShader(Rect.fromCircle(center: center, radius: ringRadius));

      // Apply perspective distortion to make rings appear on a sphere
      final oval = Rect.fromCenter(
        center: center,
        width: ringRadius * 2,
        height: ringRadius * 1.8, // Slightly squashed to simulate perspective
      );

      canvas.drawOval(oval, paint);
    }
  }

  @override
  bool shouldRepaint(_SpherePainter oldDelegate) {
    return oldDelegate.rotationValue != rotationValue;
  }
}
