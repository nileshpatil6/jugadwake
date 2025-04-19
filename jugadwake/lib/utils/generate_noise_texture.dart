import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// A utility script to generate a noise texture image.
/// 
/// This script generates a Perlin noise texture and saves it to the assets folder.
/// Run this script with: dart run lib/utils/generate_noise_texture.dart
void main() async {
  // Create a 256x256 noise texture
  final width = 256;
  final height = 256;
  final random = math.Random(42); // Fixed seed for deterministic noise
  
  // Create an image
  final image = img.Image(width: width, height: height);
  
  // Generate Perlin-like noise
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      // Simple noise function (not true Perlin noise, but good enough for our purposes)
      final noise = _generateNoise(x, y, random);
      
      // Convert noise value to grayscale color (0-255)
      final value = (noise * 255).round().clamp(0, 255);
      
      // Set pixel color
      image.setPixel(x, y, img.ColorRgb8(value, value, value));
    }
  }
  
  // Encode image to PNG
  final pngData = img.encodePng(image);
  
  // Save to file
  final file = File('assets/textures/noise_texture.png');
  await file.writeAsBytes(pngData);
  
  print('Noise texture generated and saved to assets/textures/noise_texture.png');
}

// Simple noise function
double _generateNoise(int x, int y, math.Random random) {
  // Use multiple octaves for more natural-looking noise
  double noise = 0.0;
  double amplitude = 1.0;
  double frequency = 0.01;
  double persistence = 0.5;
  
  for (int i = 0; i < 4; i++) {
    // Sample noise at different frequencies
    final sampleX = x * frequency;
    final sampleY = y * frequency;
    
    // Simple value noise (not true Perlin)
    final value = _smoothNoise(sampleX, sampleY, random);
    
    noise += value * amplitude;
    
    amplitude *= persistence;
    frequency *= 2.0;
  }
  
  // Normalize to 0.0-1.0 range
  return (noise + 1.0) / 2.0;
}

// Smooth noise function
double _smoothNoise(double x, double y, math.Random random) {
  // Get integer and fractional parts
  final x0 = x.floor();
  final y0 = y.floor();
  final x1 = x0 + 1;
  final y1 = y0 + 1;
  
  // Get fractional parts
  final sx = x - x0;
  final sy = y - y0;
  
  // Interpolate between corner values
  final n00 = _dotGridGradient(x0, y0, x, y, random);
  final n10 = _dotGridGradient(x1, y0, x, y, random);
  final n01 = _dotGridGradient(x0, y1, x, y, random);
  final n11 = _dotGridGradient(x1, y1, x, y, random);
  
  // Smooth interpolation
  final ix0 = _smoothstep(n00, n10, sx);
  final ix1 = _smoothstep(n01, n11, sx);
  
  return _smoothstep(ix0, ix1, sy);
}

// Dot product of distance and gradient vectors
double _dotGridGradient(int ix, int iy, double x, double y, math.Random random) {
  // Get pseudo-random gradient vector
  final seed = ix * 7919 + iy * 104729; // Large primes for better distribution
  final r = math.Random(seed);
  final angle = r.nextDouble() * 2 * math.pi;
  final gradX = math.cos(angle);
  final gradY = math.sin(angle);
  
  // Distance vector
  final dx = x - ix;
  final dy = y - iy;
  
  // Dot product
  return dx * gradX + dy * gradY;
}

// Smooth step function
double _smoothstep(double a, double b, double t) {
  // Hermite curve: 3t² - 2t³
  final s = t * t * (3 - 2 * t);
  return a + s * (b - a);
}
