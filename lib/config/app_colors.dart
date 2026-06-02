import 'package:flutter/material.dart';

/// Streaky color palette — "Arcade Dopamine" theme.
///
/// All colors are derived from the PRD design specification.
class AppColors {
  AppColors._();

  // ─── Core Palette ──────────────────────────────────────────────────────────

  /// Deep bluish-purple background.
  static const Color background = Color(0xFF0B0A1F);

  /// Surface card color.
  static const Color surface = Color(0xFF16142E);

  /// Slightly elevated surface (for nested cards, inputs).
  static const Color surfaceLight = Color(0xFF1E1B3D);

  /// Primary action color — energetic orange.
  static const Color primaryOrange = Color(0xFFFF8A00);

  /// Accent color — vibrant purple.
  static const Color accentPurple = Color(0xFF9B5CFF);

  /// Highlight color — electric cyan.
  static const Color cyanHighlight = Color(0xFF2FE6FF);

  /// Success color — fresh lime green.
  static const Color limeSuccess = Color(0xFFA8FF60);

  /// Error / danger color.
  static const Color error = Color(0xFFFF4D6A);

  /// Warning color.
  static const Color warning = Color(0xFFFFD54F);

  // ─── Text Colors ───────────────────────────────────────────────────────────

  /// Primary text — white with slight warmth.
  static const Color textPrimary = Color(0xFFF5F5F7);

  /// Secondary text — muted lavender.
  static const Color textSecondary = Color(0xFF9896B0);

  /// Tertiary / hint text.
  static const Color textHint = Color(0xFF5C5A78);

  // ─── Category Colors ───────────────────────────────────────────────────────

  static const Color coding = Color(0xFF9B5CFF);
  static const Color gym = Color(0xFFFF8A00);
  static const Color learning = Color(0xFF2FE6FF);
  static const Color reading = Color(0xFFA8FF60);
  static const Color meditation = Color(0xFFBB86FC);
  static const Color contentCreation = Color(0xFFFF6B9D);
  static const Color journaling = Color(0xFFFFD54F);
  static const Color socialMedia = Color(0xFF4FC3F7);
  static const Color selfImprovement = Color(0xFFFF8A65);
  static const Color general = Color(0xFFFF8A00);

  /// Map category name to its glow color.
  static Color categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'coding':
        return coding;
      case 'gym':
        return gym;
      case 'learning':
        return learning;
      case 'reading':
        return reading;
      case 'meditation':
        return meditation;
      case 'content creation':
      case 'content_creation':
        return contentCreation;
      case 'journaling':
        return journaling;
      case 'social media':
      case 'social_media':
        return socialMedia;
      case 'self improvement':
      case 'self_improvement':
        return selfImprovement;
      default:
        return general;
    }
  }

  // ─── Glow & Shadow Utilities ───────────────────────────────────────────────

  /// Generates a soft glow box-shadow for a given color.
  static List<BoxShadow> glowShadow(Color color, {double intensity = 0.35}) {
    return [
      BoxShadow(
        color: color.withAlpha((intensity * 255).round()),
        blurRadius: 20,
        spreadRadius: 2,
      ),
      BoxShadow(
        color: color.withAlpha((intensity * 0.5 * 255).round()),
        blurRadius: 40,
        spreadRadius: 4,
      ),
    ];
  }

  /// Lighter glow for subtle effects (cards, borders).
  static List<BoxShadow> subtleGlow(Color color) {
    return [
      BoxShadow(
        color: color.withAlpha(40),
        blurRadius: 12,
        spreadRadius: 1,
      ),
    ];
  }

  // ─── Gradients ─────────────────────────────────────────────────────────────

  /// Primary orange-to-yellow gradient for CTAs.
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF8A00), Color(0xFFFFB347)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Purple accent gradient.
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF9B5CFF), Color(0xFFBB86FC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Cyan highlight gradient.
  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF2FE6FF), Color(0xFF80F0FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Success gradient.
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFFA8FF60), Color(0xFFD4FF9E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Background gradient for screens.
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0B0A1F), Color(0xFF12102A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
