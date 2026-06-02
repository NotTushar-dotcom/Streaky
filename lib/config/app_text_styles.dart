import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Streaky typography system.
///
/// - **Fredoka**: Playful, rounded headings (energetic & memorable).
/// - **Outfit**: Clean, modern body text (readable & balanced).
class AppTextStyles {
  AppTextStyles._();

  // ─── Headings (Fredoka) ────────────────────────────────────────────────────

  static TextStyle get heading1 => GoogleFonts.fredoka(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get heading2 => GoogleFonts.fredoka(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get heading3 => GoogleFonts.fredoka(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get heading4 => GoogleFonts.fredoka(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  // ─── Body (Outfit) ────────────────────────────────────────────────────────

  static TextStyle get bodyLarge => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get body => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  static TextStyle get bodyBold => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  // ─── Labels & Captions ────────────────────────────────────────────────────

  static TextStyle get label => GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.4,
        letterSpacing: 0.3,
      );

  static TextStyle get caption => GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textHint,
        height: 1.3,
      );

  // ─── Special Styles ───────────────────────────────────────────────────────

  /// Large streak counter number.
  static TextStyle get streakNumber => GoogleFonts.fredoka(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryOrange,
        height: 1.0,
      );

  /// Medium stat number.
  static TextStyle get statNumber => GoogleFonts.fredoka(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.1,
      );

  /// Button text.
  static TextStyle get button => GoogleFonts.outfit(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.0,
        letterSpacing: 0.5,
      );

  /// Tab bar label.
  static TextStyle get tabLabel => GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.0,
      );
}
