import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  // Primary gradients
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.primary,
      Color(0xFF4A4AB8),
    ],
  );
  
  static const LinearGradient primaryVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.primary,
      Color(0xFF4A4AB8),
    ],
  );
  
  static const LinearGradient primaryHorizontal = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      AppColors.primary,
      Color(0xFF4A4AB8),
    ],
  );
  
  // Surface gradients
  static const LinearGradient surface = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.surface,
      Color(0xFF161616),
    ],
  );
  
  static const LinearGradient surfaceVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.surface,
      Color(0xFF161616),
    ],
  );
  
  // Background gradients
  static const LinearGradient background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.background,
      Color(0xFF161616),
    ],
  );
  
  static const LinearGradient backgroundDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF161616),
      Color(0xFF0D0D0D),
    ],
  );

  // Glassmorphism optimized backgrounds
  static const LinearGradient glassmorphismBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2A2A2A), // Lighter top left
      Color(0xFF1E1E1E), // Main background
      Color(0xFF161616), // Darker middle
      Color(0xFF0D0D0D), // Darkest bottom right
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  static const LinearGradient glassmorphismSubtle = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF242424),
      Color(0xFF1A1A1A),
      Color(0xFF161616),
      Color(0xFF121212),
    ],
    stops: [0.0, 0.4, 0.7, 1.0],
  );
  
  // Accent gradients
  static LinearGradient get accent => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.accent,
      Color(0xFF0097A7),
    ],
  );
  
  static LinearGradient get accentVertical => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.accent,
      Color(0xFF0097A7),
    ],
  );
  
  // Status gradients
  static LinearGradient get success => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.success,
      Color(0xFF2E7D32),
    ],
  );
  
  static LinearGradient get error => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.error,
      Color(0xFFD32F2F),
    ],
  );
  
  static LinearGradient get warning => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.warning,
      Color(0xFFF57C00),
    ],
  );
  
  // Shimmer gradients
  static const LinearGradient shimmer = LinearGradient(
    begin: Alignment(-1.0, -2.0),
    end: Alignment(1.0, 2.0),
    colors: [
      Color(0xFF2C2C2C),
      Color(0xFF3A3A3A),
      Color(0xFF2C2C2C),
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  // Overlay gradients
  static const LinearGradient overlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0x80000000),
    ],
  );
  
  static const LinearGradient overlayReverse = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      Colors.transparent,
      Color(0x80000000),
    ],
  );
  
  // Radial gradients
  static const RadialGradient radialPrimary = RadialGradient(
    center: Alignment.center,
    radius: 1.0,
    colors: [
      AppColors.primary,
      Color(0xFF4A4AB8),
    ],
  );
  
  static const RadialGradient radialSurface = RadialGradient(
    center: Alignment.center,
    radius: 1.0,
    colors: [
      AppColors.surface,
      Color(0xFF161616),
    ],
  );
  
  // Sweep gradients
  static const SweepGradient sweepPrimary = SweepGradient(
    center: Alignment.center,
    colors: [
      AppColors.primary,
      Color(0xFF4A4AB8),
      AppColors.primary,
    ],
  );
  
  // Custom gradient builder
  static LinearGradient custom({
    required List<Color> colors,
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
    List<double>? stops,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: colors,
      stops: stops,
    );
  }
  
  // Custom radial gradient builder
  static RadialGradient customRadial({
    required List<Color> colors,
    Alignment center = Alignment.center,
    double radius = 1.0,
    List<double>? stops,
  }) {
    return RadialGradient(
      center: center,
      radius: radius,
      colors: colors,
      stops: stops,
    );
  }
}