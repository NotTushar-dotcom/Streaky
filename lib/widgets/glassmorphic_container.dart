import 'dart:ui';
import 'package:flutter/material.dart';

/// Custom Glass Border Painter to draw metallic outline reflection highlights.
class GlassBorderPainter extends CustomPainter {
  final double borderRadius;
  final Gradient gradient;
  final double strokeWidth;

  GlassBorderPainter({
    required this.borderRadius,
    required this.gradient,
    this.strokeWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant GlassBorderPainter oldDelegate) => false;
}

/// Premium Glassmorphic Container with reflective linear sheen highlights,
/// gradient reflection borders, and support for optional category glow themer blending.
class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? glowColor;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(16),
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = glowColor ?? Colors.white;

    return Container(
      // Outer drop shadow for card depth
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(90),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: CustomPaint(
            painter: GlassBorderPainter(
              borderRadius: borderRadius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  baseColor.withAlpha(70),   // bright reflection top-left (glow matching)
                  baseColor.withAlpha(15),
                  baseColor.withAlpha(2),
                  baseColor.withAlpha(22),   // bottom-right highlight rebound
                ],
                stops: const [0.0, 0.28, 0.75, 1.0],
              ),
              strokeWidth: 1.5,
            ),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                // Frosted translucent surface sheened linear reflection
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    baseColor.withAlpha(20),
                    baseColor.withAlpha(5),
                  ],
                ),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
