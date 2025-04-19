import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter_animate/flutter_animate.dart';

// Custom painter for noise overlay (scale 0.02, opacity 0.03)
class _NoiseOverlayPainter extends CustomPainter {
  _NoiseOverlayPainter({required this.opacity, required this.particleValue});

  final double opacity;
  final double particleValue;

  @override
  void paint(Canvas canvas, Size size) {
    // Screen-space noise overlay (scale 0.02, opacity 0.03)
    final paint =
        Paint()
          ..color = Colors.white.withAlpha(8) // 0.03 opacity (3% of 255 = ~8)
          ..style = PaintingStyle.fill;

    final random = math.Random(particleValue.toInt() * 1000);

    // Create a subtle noise pattern - screen-space noise overlay
    // Scale 0.02 means very small dots (about 2% of the orb size)
    final noiseScale = size.width * 0.02; // 2% of the orb size

    // Calculate how many noise points to create based on the scale
    final pointCount =
        (size.width * size.height) / (noiseScale * noiseScale) * 0.3;

    for (int i = 0; i < pointCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius =
          noiseScale * 0.5 * random.nextDouble(); // Vary the size slightly

      // Only draw points within the circle
      final dx = x - size.width / 2;
      final dy = y - size.height / 2;
      if (dx * dx + dy * dy <= size.width * size.width / 4) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_NoiseOverlayPainter oldDelegate) {
    return oldDelegate.particleValue != particleValue;
  }
}

// Custom painter for interior particles (~500 sub-pixel particles)
class _ParticlePainter extends CustomPainter {
  _ParticlePainter({required this.particleValue, required this.noiseOffsets});

  final double particleValue;
  final List<double> noiseOffsets;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Define the 5 colors from the specification
    final colors = [
      const Color(0xFFA0CFF2), // Sky blue
      const Color(0xFFD9B3F8), // Lavender
      const Color(0xFFFFB3C1), // Magenta
      const Color(0xFFB8F2E6), // Mint green
      const Color(0xFFFFD8B1), // Peach orange
    ];

    // Create ~500 drifting particles on a slow curl field
    for (int i = 0; i < 500; i++) {
      // Use noise offsets and curl field for organic movement
      // Curl field creates swirling motion
      final baseAngle = (particleValue * math.pi * 2) + (i * 0.01);
      final noiseOffset = noiseOffsets[i % noiseOffsets.length];

      // Create a curl field effect
      final curl =
          math.sin(baseAngle + noiseOffset) * math.cos(baseAngle * 0.5);
      final angle = baseAngle + curl * 0.5;

      // Vary the distance from center with noise
      final distanceRatio =
          0.1 + (i % 100) / 100 * 0.8; // Distribute throughout the orb
      final distance = distanceRatio * radius;

      // Calculate position with curl field effect
      final x = center.dx + math.cos(angle) * distance;
      final y = center.dy + math.sin(angle) * distance;

      // Sub-pixel particles (radius ≤1 px)
      final particleSize = math.min(
        1.0,
        0.2 + (math.Random().nextDouble() * 0.8),
      );

      // Color based on position in the orb
      final colorIndex = (distanceRatio * 5).floor() % colors.length;
      final baseColor = colors[colorIndex];

      // Add some transparency (30-70% opacity)
      final alpha = ((0.3 + (math.Random().nextDouble() * 0.4)) * 255).toInt();
      final color = baseColor.withAlpha(alpha);

      final paint =
          Paint()
            ..color = color
            ..style = PaintingStyle.fill;

      // Only draw if within the sphere boundary
      final dx = x - center.dx;
      final dy = y - center.dy;
      if (dx * dx + dy * dy <= radius * radius) {
        canvas.drawCircle(Offset(x, y), particleSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) {
    return oldDelegate.particleValue != particleValue;
  }
}

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  bool _hasInteracted = false;
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;

  // Controllers for sphere animation
  late AnimationController _rotationXController;
  late AnimationController _rotationYController;
  late AnimationController _rotationZController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _bobController;
  late Animation<double> _bobAnimation;
  late AnimationController _colorDriftController;
  late AnimationController _particleController;

  // Noise values for organic movement
  final List<double> _noiseOffsets = List.generate(
    6,
    (_) => math.Random().nextDouble() * 10,
  );

  // List of suggestion cards
  final List<Map<String, String>> _suggestions = [
    {
      'title': 'Cooking',
      'question': 'How to bake chocolate cookies from scratch?',
      'icon': '🍪',
    },
    {
      'title': 'Travel guide',
      'question': 'Tell me 5 interesting facts about France',
      'icon': '🗼',
    },
    {'title': 'What to watch', 'question': 'Recommended movies?', 'icon': '🎬'},
    {
      'title': 'Best actor',
      'question': 'Who won the Academy Award for Best Actor?',
      'icon': '🏆',
    },
    {'title': 'Pet care', 'question': 'How to care for my cat?', 'icon': '🐱'},
    {
      'title': 'Essay',
      'question': 'Can you write a short essay about literature?',
      'icon': '📝',
    },
  ];

  @override
  void initState() {
    super.initState();

    // Initialize fade animation controller
    _fadeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeAnimationController, curve: Curves.easeOut),
    );

    // Initialize rotation controllers for tri-axial rotation (12 seconds)
    _rotationXController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    // Staggered start for Y rotation
    _rotationYController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
      value: 0.33, // Start 1/3 of the way through the animation
    )..repeat();

    // Staggered start for Z rotation
    _rotationZController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
      value: 0.66, // Start 2/3 of the way through the animation
    )..repeat();

    // Initialize pulse animation for breathing effect (±2%)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6), // 6 seconds for breathing effect
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Initialize vertical bob animation (±5px in 6s)
    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _bobAnimation = Tween<double>(
      begin: -5.0,
      end: 5.0,
    ).animate(CurvedAnimation(parent: _bobController, curve: Curves.easeInOut));

    // Initialize color drift controller for fluid color movement
    _colorDriftController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 10,
      ), // 10 seconds for full color cycle as per spec
    )..repeat();

    // Initialize particle animation controller
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _fadeAnimationController.dispose();
    _rotationXController.dispose();
    _rotationYController.dispose();
    _rotationZController.dispose();
    _pulseController.dispose();
    _bobController.dispose();
    _colorDriftController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  // Handle sending a message
  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _hasInteracted = true;
      });

      // Start fade out animation for greeting
      _fadeAnimationController.forward();

      // Clear the input field
      _messageController.clear();

      // Here you would normally send the message to your chat backend
    }
  }

  // Handle selecting a suggestion
  void _selectSuggestion(String question) {
    _messageController.text = question;
    _sendMessage();
  }

  // Build custom 3D glass orb
  Widget _build3DSphere() {
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        children: [
          // Base glass orb with gradient
          _buildGlassOrb(),

          // Specular highlights
          _buildSpecularHighlights(),

          // Interior glow and fluid color drift
          _buildInteriorGlow(),

          // Environment reflections
          _buildEnvironmentReflections(),
        ],
      ),
    );
  }

  // Build the base glass orb with gradient
  Widget _buildGlassOrb() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _rotationXController,
        _rotationYController,
        _rotationZController,
        _colorDriftController,
        _particleController,
      ]),
      builder: (context, child) {
        // Calculate rotation angles for tri-axial rotation
        final xRotation = _rotationXController.value * 2 * math.pi;
        final yRotation = _rotationYController.value * 2 * math.pi;
        final zRotation = _rotationZController.value * 2 * math.pi;

        // Apply Perlin-like noise for more organic movement
        final time = DateTime.now().millisecondsSinceEpoch / 1000;
        final noiseX = math.sin(time * 0.5 + _noiseOffsets[0]) * 0.05;
        final noiseY = math.cos(time * 0.3 + _noiseOffsets[1]) * 0.05;

        // Create a layered effect for depth
        return Stack(
          children: [
            // Outer glow/halo effect
            Positioned.fill(
              child: Center(
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: const [
                        Color(0x33FFFFFF), // White with 20% opacity
                        Color(0x00FFFFFF), // Transparent white
                      ],
                      stops: const [0.7, 1.0],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x4D90CAF9), // Light blue with 30% opacity
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Main orb with 3D transform
            Center(
              child: Transform(
                transform:
                    Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // Perspective
                      ..rotateX(xRotation + noiseX)
                      ..rotateY(yRotation + noiseY)
                      ..rotateZ(
                        zRotation * 0.5,
                      ), // Less Z-rotation for stability
                alignment: Alignment.center,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // Glass shell with IOR 1.4, opacity 0.5, metalness 0, roughness 0, clearcoat 1
                    gradient: SweepGradient(
                      center: Alignment.center,
                      startAngle: 0,
                      endAngle: math.pi * 2,
                      transform: GradientRotation(
                        _colorDriftController.value * math.pi * 2,
                      ),
                      colors: const [
                        Color(0x80A0CFF2), // Sky blue with 50% opacity
                        Color(0x80D9B3F8), // Lavender with 50% opacity
                        Color(0x80FFB3C1), // Pale magenta with 50% opacity
                        Color(0x80B8F2E6), // Mint green with 50% opacity
                        Color(0x80FFD8B1), // Peach orange with 50% opacity
                        Color(
                          0x80A0CFF2,
                        ), // Sky blue again to complete the circle
                      ],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x40000000), // Black with 25% opacity
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 10,
                        sigmaY: 10,
                      ), // Increased blur for more refractive look
                      child: Container(
                        color: Colors.transparent,
                        // Add subtle noise overlay
                        child: CustomPaint(
                          painter: _NoiseOverlayPainter(
                            opacity: 0.03, // 3% noise overlay as per spec
                            particleValue: _particleController.value,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Refractive edge highlight - simulates light bending at the edges
            Positioned.fill(
              child: IgnorePointer(
                child: Transform(
                  transform:
                      Matrix4.identity()
                        ..setEntry(3, 2, 0.001) // Perspective
                        ..rotateX(xRotation * 0.8)
                        ..rotateY(yRotation * 0.8),
                  alignment: Alignment.center,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(
                          0x4DFFFFFF,
                        ), // White with 30% opacity
                        width: 2,
                      ),
                      gradient: RadialGradient(
                        center: const Alignment(0.3, -0.3),
                        radius: 0.7,
                        colors: const [
                          Colors.transparent,
                          Color(0x1AFFFFFF), // White with 10% opacity
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Frosted rim overlay: second sphere at scale 1.02 with white MeshBasicMaterial, opacity 0.1
            Positioned.fill(
              child: IgnorePointer(
                child: Transform.scale(
                  scale: 1.02,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0x1AFFFFFF), // White with 10% opacity
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Build specular highlights for the glass effect - three-point lighting system
  Widget _buildSpecularHighlights() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        // Use particle controller for subtle movement of highlights
        final highlightOffset =
            math.sin(_particleController.value * math.pi * 2) * 3;

        return Stack(
          children: [
            // Key light: #FFFFFF, intensity 0.7, pos (2,2,2)
            Positioned(
              top: 15 + highlightOffset,
              left: 20,
              child: Container(
                width: 70,
                height: 35,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(35),
                  gradient: const RadialGradient(
                    center: Alignment(0.2, 0),
                    radius: 0.8,
                    colors: [
                      Color(0xB3FFFFFF), // White with 70% opacity
                      Color(0x00FFFFFF), // Transparent white
                    ],
                  ),
                ),
              ),
            ),

            // Rim light: #FFCCE0, intensity 0.3, pos (-2,2,-2)
            Positioned(
              bottom: 25 - highlightOffset / 2,
              right: 15,
              child: Container(
                width: 50,
                height: 25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: const RadialGradient(
                    center: Alignment(-0.2, 0),
                    radius: 0.8,
                    colors: [
                      Color(0x4DFFCCE0), // Pink with 30% opacity
                      Color(0x00FFCCE0), // Transparent pink
                    ],
                  ),
                ),
              ),
            ),

            // Fill light: #FFF8E7, intensity 0.2, pos (0,-2,0)
            Positioned(
              bottom: 40 + highlightOffset / 2,
              left: 30,
              child: Container(
                width: 40,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const RadialGradient(
                    center: Alignment(0, 0),
                    radius: 0.7,
                    colors: [
                      Color(0x33FFF8E7), // Warm white with 20% opacity
                      Color(0x00FFF8E7), // Transparent warm white
                    ],
                  ),
                ),
              ),
            ),

            // High-gloss specular highlight
            Positioned(
              top: 30 - highlightOffset,
              left: 35 + highlightOffset,
              child: Container(
                width: 15,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const RadialGradient(
                    center: Alignment(0, 0),
                    radius: 0.5,
                    colors: [
                      Color(0xE6FFFFFF), // White with 90% opacity
                      Color(0x00FFFFFF), // Transparent white
                    ],
                  ),
                ),
              ),
            ),

            // Inner bloom (radius 8 px, intensity 0.2)
            Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: Alignment(0, 0),
                    radius: 0.7,
                    colors: [
                      Color(0x33FFFFFF), // White with 20% opacity
                      Color(0x00FFFFFF), // Transparent
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Build interior glow effect with turbulent chromatic vortices
  Widget _buildInteriorGlow() {
    return AnimatedBuilder(
      animation: Listenable.merge([_colorDriftController, _particleController]),
      builder: (context, child) {
        // Create Perlin-like turbulence for the vortex movement
        final time = _colorDriftController.value;
        final particleTime = _particleController.value;

        // Calculate dynamic positions for the color vortices
        final centerX =
            math.cos(time * math.pi * 2) * 0.2 +
            math.sin(particleTime * math.pi * 3) * 0.1;
        final centerY =
            math.sin(time * math.pi * 2) * 0.2 +
            math.cos(particleTime * math.pi * 3) * 0.1;

        return Stack(
          children: [
            // Main interior glow - pastel sky blue
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: Alignment(centerX, centerY),
                    radius: 0.7,
                    colors: const [
                      Color(0x99A0CFF2), // Sky blue with 60% opacity
                      Color(0x00A0CFF2), // Transparent
                    ],
                  ),
                ),
              ),
            ),

            // Secondary interior glow - lavender
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: Alignment(-centerY, centerX * 0.8),
                    radius: 0.6,
                    colors: const [
                      Color(0x80D9B3F8), // Lavender with 50% opacity
                      Color(0x00D9B3F8), // Transparent
                    ],
                  ),
                ),
              ),
            ),

            // Tertiary interior glow - pale magenta
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: Alignment(centerY * 1.2, -centerX),
                    radius: 0.5,
                    colors: const [
                      Color(0x66FFB3C1), // Pale magenta with 40% opacity
                      Color(0x00FFB3C1), // Transparent
                    ],
                  ),
                ),
              ),
            ),

            // Accent pocket - mint green
            Positioned(
              top: 60 + math.sin(particleTime * math.pi * 2) * 10,
              left: 60 + math.cos(particleTime * math.pi * 2) * 10,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    center: Alignment(0, 0),
                    radius: 0.7,
                    colors: [
                      Color(0x4DB8F2E6), // Mint green with 30% opacity
                      Color(0x00B8F2E6), // Transparent
                    ],
                  ),
                ),
              ),
            ),

            // Accent pocket - peach orange
            Positioned(
              top: 50 - math.cos(particleTime * math.pi * 2) * 15,
              left: 50 - math.sin(particleTime * math.pi * 2) * 15,
              child: Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    center: Alignment(0, 0),
                    radius: 0.7,
                    colors: [
                      Color(0x4DFFD8B1), // Peach orange with 30% opacity
                      Color(0x00FFD8B1), // Transparent
                    ],
                  ),
                ),
              ),
            ),

            // Core glow - pulsating center
            Center(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 40 + (_pulseController.value * 10),
                    height: 40 + (_pulseController.value * 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [
                          Color(0x80FFFFFF), // White with 50% opacity
                          Color(0x00FFFFFF), // Transparent
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0x80A0CFF2,
                          ), // Sky blue with 50% opacity
                          blurRadius: 10 + (_pulseController.value * 5),
                          spreadRadius: _pulseController.value * 2,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Drifting particulates
            CustomPaint(
              size: const Size(150, 150),
              painter: _ParticlePainter(
                particleValue: particleTime,
                noiseOffsets: _noiseOffsets,
              ),
            ),
          ],
        );
      },
    );
  }

  // Build environment reflections to simulate white-studio HDRI environment
  Widget _buildEnvironmentReflections() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        // Subtle movement for reflections
        final reflectionOffset =
            math.sin(_particleController.value * math.pi * 2) * 2;

        return Stack(
          children: [
            // Top edge reflection
            Positioned(
              top: 5 + reflectionOffset / 2,
              left: 35,
              right: 35,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: const Color(0x40FFFFFF), // White with 25% opacity
                ),
              ),
            ),

            // Bottom edge reflection
            Positioned(
              bottom: 10 - reflectionOffset / 2,
              left: 45,
              right: 45,
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1),
                  color: const Color(0x30FFFFFF), // White with 19% opacity
                ),
              ),
            ),

            // Perimetric frost effect (10% opacity)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0x1AFFFFFF), // White with 10% opacity
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),

            // Ethereal bloom effect
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33FFFFFF), // White with 20% opacity
                        blurRadius: 8, // 8px radius
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFE3E8FF),
              const Color(0xFFC5DBFF),
              const Color(0xFFB7CCFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Blurred background circles for decoration
              Positioned(
                top: -50,
                right: -30,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(
                      0x33336EFF,
                    ), // Light blue with 20% opacity
                  ),
                ),
              ),
              Positioned(
                bottom: -80,
                left: -50,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(
                      0x269C27B0,
                    ), // Light purple with 15% opacity
                  ),
                ),
              ),

              // Main content
              Column(
                children: [
                  // App bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'AI Assistant',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Chat area
                  Expanded(
                    child:
                        _hasInteracted
                            ? _buildChatArea()
                            : _buildGreetingArea(),
                  ),

                  // Suggestion cards
                  _buildSuggestionCards(),

                  // Input area
                  _buildInputArea(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build the greeting area with animated sphere
  Widget _buildGreetingArea() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(opacity: _fadeAnimation.value, child: child);
      },
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Greeting text
            Text(
              'Talk with Nova',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1F3B),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'How can I assist you?',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: const Color(0xFF4B51E6),
              ),
            ),
            const SizedBox(height: 40),

            // Custom 3D animated sphere
            SizedBox(
              width: 200,
              height: 200,
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _rotationXController,
                  _rotationYController,
                  _rotationZController,
                  _pulseController,
                  _bobController,
                ]),
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _bobAnimation.value),
                    child: Transform.scale(
                      scale: _pulseAnimation.value,
                      child: _build3DSphere(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Build the chat area (appears after user interaction)
  Widget _buildChatArea() {
    // This would normally contain the chat messages
    // For now, it's just a placeholder
    return Center(
      child: Text(
        'Chat messages will appear here',
        style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade600),
      ),
    );
  }

  // Build horizontally scrollable suggestion cards
  Widget _buildSuggestionCards() {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _suggestions.length,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemBuilder: (context, index) {
          final suggestion = _suggestions[index];
          return _buildSuggestionCard(
            title: suggestion['title']!,
            question: suggestion['question']!,
            icon: suggestion['icon']!,
          );
        },
      ),
    );
  }

  // Build individual suggestion card
  Widget _buildSuggestionCard({
    required String title,
    required String question,
    required String icon,
  }) {
    return GestureDetector(
      onTap: () => _selectSuggestion(question),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12.0),
        decoration: BoxDecoration(
          color: const Color(0xB3FFFFFF), // White with 70% opacity
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [
            BoxShadow(
              color: const Color(0x0D000000), // Black with 5% opacity
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with icon
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1F3B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(icon, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Question text
                  Text(
                    question,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Build the input area with text field and microphone button
  Widget _buildInputArea() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xB3FFFFFF), // White with 70% opacity
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0D000000), // Black with 5% opacity
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                // Text input field
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Message AI assistant',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey.shade500,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16.0,
                      ),
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: const Color(0xFF1A1F3B),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),

                // Microphone button
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade500,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.mic, color: Colors.white),
                    onPressed: () {
                      // Voice input functionality would go here
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
