import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:streaky/config/app_colors.dart';

/// Animated check-in button with flame pulse + haptic feedback.
class StreakCheckButton extends StatefulWidget {
  final bool isCompleted;
  final Color color;
  final VoidCallback? onCheckIn;
  final double size;

  const StreakCheckButton({
    super.key,
    this.isCompleted = false,
    this.color = AppColors.limeSuccess,
    this.onCheckIn,
    this.size = 44,
  });

  @override
  State<StreakCheckButton> createState() => _StreakCheckButtonState();
}

class _StreakCheckButtonState extends State<StreakCheckButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.85), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.15), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.isCompleted) return;
    HapticFeedback.mediumImpact();
    _controller.forward(from: 0.0);
    widget.onCheckIn?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: _handleTap,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isCompleted
                    ? widget.color
                    : AppColors.surfaceLight,
                border: Border.all(
                  color: widget.isCompleted
                      ? widget.color
                      : AppColors.textHint.withAlpha(60),
                  width: 2,
                ),
                boxShadow: widget.isCompleted
                    ? [
                        BoxShadow(
                          color: widget.color.withAlpha(
                              (80 + 60 * _glowAnimation.value).round()),
                          blurRadius: 12 + 8 * _glowAnimation.value,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                widget.isCompleted
                    ? Icons.check_rounded
                    : Icons.add_rounded,
                color: widget.isCompleted
                    ? AppColors.background
                    : AppColors.textHint,
                size: widget.size * 0.5,
              ),
            ),
          ),
        );
      },
    );
  }
}
