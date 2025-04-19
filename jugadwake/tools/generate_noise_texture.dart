import 'dart:io';
import 'dart:math' as math;
import 'package:image/image.dart' as img;

void main() {
  // Create a 256x256 noise texture
  final width = 256;
  final height = 256;
  final image = img.Image(width: width, height: height);
  final random = math.Random(42); // Fixed seed for reproducibility
  
  // Fill with perlin-like noise
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      // Generate noise value (0-255)
      final noiseValue = (random.nextDouble() * 255).toInt();
      
      // Create a grayscale pixel
      final pixel = img.ColorRgba8(noiseValue, noiseValue, noiseValue, 255);
      
      // Set the pixel in the image
      image.setPixel(x, y, pixel);
    }
  }
  
  // Encode the image as PNG
  final png = img.encodePng(image);
  
  // Save to file
  File('../assets/textures/noise_texture.png').writeAsBytesSync(png);
  
  print('Noise texture generated successfully!');
}
