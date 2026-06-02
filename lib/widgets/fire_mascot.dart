import 'dart:math';
import 'package:flutter/material.dart';
import 'package:streaky/config/app_colors.dart';

/// Animated fire mascot widget using CustomPainter.
///
/// Evolves with streak level:
/// - Level 1: Newbie Fire (small, gentle)
/// - Level 2: Growing Fire (medium, brighter)
/// - Level 3: On Fire (large, vivid)
/// - Level 4: Legendary Fire (extra large, particles + crown)
class FireMascot extends StatefulWidget {
  final double size;
  final int level; // 1–4
  final bool animate;

  const FireMascot({
    super.key,
    this.size = 80,
    this.level = 1,
    this.animate = true,
  });

  /// Determine mascot level from streak count.
  factory FireMascot.fromStreak({
    Key? key,
    required int streakCount,
    double size = 80,
    bool animate = true,
  }) {
    int level;
    if (streakCount >= 30) {
      level = 4;
    } else if (streakCount >= 14) {
      level = 3;
    } else if (streakCount >= 7) {
      level = 2;
    } else {
      level = 1;
    }
    return FireMascot(key: key, size: size, level: level, animate: animate);
  }

  @override
  State<FireMascot> createState() => _FireMascotState();
}

class _FireMascotState extends State<FireMascot> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _flickerController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _flickerAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _flickerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _flickerAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _flickerController, curve: Curves.easeInOut),
    );

    if (widget.animate) {
      _pulseController.repeat(reverse: true);
      _flickerController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _flickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _flickerAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: widget.animate ? _pulseAnimation.value : 1.0,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: CustomPaint(
              painter: _FirePainter(
                level: widget.level,
                flickerOffset: widget.animate ? _flickerAnimation.value : 0.0,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FirePainter extends CustomPainter {
  final int level;
  final double flickerOffset;

  _FirePainter({required this.level, this.flickerOffset = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // Glow behind the flame
    final glowPaint = Paint()
      ..color = _glowColor.withAlpha(40)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.6);
    canvas.drawCircle(Offset(cx, cy + r * 0.1), r * 0.7, glowPaint);

    // Outer flame
    _drawFlame(canvas, cx, cy, r * 0.85, _outerColor.withAlpha(200), flickerOffset);

    // Middle flame
    _drawFlame(canvas, cx, cy + r * 0.05, r * 0.6, _middleColor, flickerOffset * 0.7);

    // Inner flame (brightest)
    _drawFlame(canvas, cx, cy + r * 0.12, r * 0.38, _innerColor, flickerOffset * 0.4);

    // Face
    _drawFace(canvas, cx, cy + r * 0.15, r);

    // Crown for legendary
    if (level >= 4) {
      _drawCrown(canvas, cx, cy - r * 0.55, r * 0.3);
    }
  }

  void _drawFlame(Canvas canvas, double cx, double cy, double radius,
      Color color, double offset) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final tipY = cy - radius * 1.6;
    final baseY = cy + radius * 0.6;

    path.moveTo(cx - radius * 0.8, baseY);
    path.quadraticBezierTo(
      cx - radius * 1.0 + offset * radius * 2,
      cy - radius * 0.5,
      cx + offset * radius * 3,
      tipY,
    );
    path.quadraticBezierTo(
      cx + radius * 1.0 + offset * radius * 2,
      cy - radius * 0.5,
      cx + radius * 0.8,
      baseY,
    );
    path.quadraticBezierTo(cx, baseY + radius * 0.3, cx - radius * 0.8, baseY);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawFace(Canvas canvas, double cx, double cy, double r) {
    final eyeR = r * 0.06;
    final eyeY = cy - r * 0.02;
    final eyeSpacing = r * 0.18;

    // Eyes
    final eyePaint = Paint()..color = const Color(0xFF1A1A2E);
    canvas.drawCircle(Offset(cx - eyeSpacing, eyeY), eyeR, eyePaint);
    canvas.drawCircle(Offset(cx + eyeSpacing, eyeY), eyeR, eyePaint);

    // Eye highlights
    final highlightPaint = Paint()..color = Colors.white;
    canvas.drawCircle(
        Offset(cx - eyeSpacing + eyeR * 0.3, eyeY - eyeR * 0.3),
        eyeR * 0.4,
        highlightPaint);
    canvas.drawCircle(
        Offset(cx + eyeSpacing + eyeR * 0.3, eyeY - eyeR * 0.3),
        eyeR * 0.4,
        highlightPaint);

    // Smile
    final smilePaint = Paint()
      ..color = const Color(0xFF1A1A2E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.03
      ..strokeCap = StrokeCap.round;

    final smileRect = Rect.fromCenter(
      center: Offset(cx, cy + r * 0.08),
      width: r * 0.22,
      height: r * 0.12,
    );
    canvas.drawArc(smileRect, 0.2, pi * 0.6, false, smilePaint);
  }

  void _drawCrown(Canvas canvas, double cx, double cy, double size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(cx - size, cy + size * 0.5);
    path.lineTo(cx - size, cy - size * 0.2);
    path.lineTo(cx - size * 0.5, cy + size * 0.1);
    path.lineTo(cx, cy - size * 0.5);
    path.lineTo(cx + size * 0.5, cy + size * 0.1);
    path.lineTo(cx + size, cy - size * 0.2);
    path.lineTo(cx + size, cy + size * 0.5);
    path.close();

    canvas.drawPath(path, paint);
  }

  Color get _outerColor {
    switch (level) {
      case 4:
        return const Color(0xFFFF4500);
      case 3:
        return const Color(0xFFFF6B00);
      case 2:
        return const Color(0xFFFF8A00);
      default:
        return const Color(0xFFFF9F40);
    }
  }

  Color get _middleColor {
    switch (level) {
      case 4:
        return const Color(0xFFFF8A00);
      case 3:
        return const Color(0xFFFF9F40);
      case 2:
        return const Color(0xFFFFB347);
      default:
        return const Color(0xFFFFCC80);
    }
  }

  Color get _innerColor {
    switch (level) {
      case 4:
        return const Color(0xFFFFD700);
      case 3:
        return const Color(0xFFFFE082);
      case 2:
        return const Color(0xFFFFECB3);
      default:
        return const Color(0xFFFFF3E0);
    }
  }

  Color get _glowColor {
    switch (level) {
      case 4:
        return const Color(0xFFFF4500);
      case 3:
        return AppColors.primaryOrange;
      case 2:
        return const Color(0xFFFFB347);
      default:
        return const Color(0xFFFFCC80);
    }
  }

  @override
  bool shouldRepaint(covariant _FirePainter oldDelegate) {
    return oldDelegate.flickerOffset != flickerOffset ||
        oldDelegate.level != level;
  }
}
