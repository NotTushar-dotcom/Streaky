import 'dart:math';
import 'package:flutter/material.dart';
import 'package:streaky/config/app_colors.dart';

/// Floating particle/ember background effect.
///
/// Creates an ambient atmosphere with subtle glowing particles
/// that drift upward. Used on splash and home screens.
class ParticleBackground extends StatefulWidget {
  final int particleCount;
  final Color particleColor;
  final Widget? child;

  const ParticleBackground({
    super.key,
    this.particleCount = 30,
    this.particleColor = AppColors.primaryOrange,
    this.child,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _particles = List.generate(
      widget.particleCount,
      (_) => _Particle.random(_random),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Particles
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _ParticlePainter(
                particles: _particles,
                progress: _controller.value,
                color: widget.particleColor,
              ),
              size: Size.infinite,
            );
          },
        ),
        // Child content
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _Particle {
  final double x; // 0..1
  final double y; // 0..1
  final double speed; // how fast it drifts up
  final double size; // radius
  final double opacity;
  final double wobbleAmplitude;
  final double wobbleSpeed;

  _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
    required this.wobbleAmplitude,
    required this.wobbleSpeed,
  });

  factory _Particle.random(Random r) {
    return _Particle(
      x: r.nextDouble(),
      y: r.nextDouble(),
      speed: 0.03 + r.nextDouble() * 0.07,
      size: 1.0 + r.nextDouble() * 2.5,
      opacity: 0.1 + r.nextDouble() * 0.3,
      wobbleAmplitude: 0.005 + r.nextDouble() * 0.015,
      wobbleSpeed: 0.5 + r.nextDouble() * 2.0,
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Color color;

  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      // Calculate position with upward drift and horizontal wobble
      final t = (p.y + progress * p.speed * 10) % 1.0;
      final wobble = sin(progress * p.wobbleSpeed * 2 * pi) * p.wobbleAmplitude;
      final px = (p.x + wobble) * size.width;
      final py = (1.0 - t) * size.height;

      // Fade out as particles reach the top
      final fadeT = t < 0.1 ? t / 0.1 : (t > 0.9 ? (1.0 - t) / 0.1 : 1.0);

      final paint = Paint()
        ..color = color.withAlpha((p.opacity * fadeT * 255).round())
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size * 0.8);

      canvas.drawCircle(Offset(px, py), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => true;
}
