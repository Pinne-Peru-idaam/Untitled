import 'package:flutter/material.dart';

// lib/widgets/gradient_background.dart
class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(1.2, -0.6), // Position towards top-left
          radius: 1.6,
          colors: [
            Color(0xFF1A3048), // Dark blue
            Color(0xFF0D1B29), // Darker blue
            Color(0xFF060D14), // Very dark blue
            Color(0xFF020408), // Almost black with slight blue
            Color(0xFF010204), // Almost black with green tint at bottom
          ],
          stops: [0.2, 0.4, 0.6, 0.8, 1.0],
          focal: Alignment(1, -0.6),
          focalRadius: 0.2,
        ),
      ),
      child: child,
    );
  }
}
