import 'package:flutter/material.dart';
import 'package:streaky/config/app_colors.dart';

/// A reusable card widget with a colored glow shadow.
///
/// Uses the surface color as background with a soft glow underneath.
class GlowCard extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final double borderRadius;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showGlow;

  const GlowCard({
    super.key,
    required this.child,
    this.glowColor = AppColors.accentPurple,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.onLongPress,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: glowColor.withAlpha(30),
          width: 1,
        ),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: glowColor.withAlpha(25),
                  blurRadius: 16,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: glowColor.withAlpha(20),
          highlightColor: glowColor.withAlpha(10),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
