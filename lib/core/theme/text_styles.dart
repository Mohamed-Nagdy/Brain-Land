import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/colors.dart';

/// AppTextStyles defines the typography system for BrainLand
/// Uses Fredoka font for child-friendly readability
class AppTextStyles {
  // Prevent instantiation
  AppTextStyles._();

  // Base font family
  static final String _fontFamily = GoogleFonts.fredoka().fontFamily!;

  // Headings - Bold and playful
  static final heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
    height: 1.2,
    fontFamily: _fontFamily,
  );

  static final heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: 0.3,
    height: 1.3,
    fontFamily: _fontFamily,
  );

  static final heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.2,
    height: 1.3,
    fontFamily: _fontFamily,
  );

  static final heading4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
    fontFamily: _fontFamily,
  );

  // Body text - Clear and readable
  static final bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
    fontFamily: _fontFamily,
  );

  static final bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
    fontFamily: _fontFamily,
  );

  static final bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
    fontFamily: _fontFamily,
  );

  // Secondary text - Less prominent
  static final caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.4,
    fontFamily: _fontFamily,
  );

  static final overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 1.5,
    height: 1.6,
    fontFamily: _fontFamily,
  );

  // Button text - Bold and prominent
  static final button = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 1.0,
    height: 1.2,
    fontFamily: _fontFamily,
  );

  static final buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 0.8,
    height: 1.2,
    fontFamily: _fontFamily,
  );

  // Numbers in games - Extra large and clear
  static final gameNumber = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.0,
    fontFamily: _fontFamily,
  );

  static final gameNumberLarge = TextStyle(
    fontSize: 64,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.0,
    fontFamily: _fontFamily,
  );

  static final gameNumberSmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.0,
    fontFamily: _fontFamily,
  );

  // Special text styles
  static final title = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
    height: 1.2,
    fontFamily: _fontFamily,
  );

  static final subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
    fontFamily: _fontFamily,
  );

  // Score and stats text
  static final score = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.0,
    fontFamily: _fontFamily,
  );

  static final stat = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.2,
    fontFamily: _fontFamily,
  );

  // Label text
  static final label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
    height: 1.4,
    fontFamily: _fontFamily,
  );

  static final labelBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
    height: 1.4,
    fontFamily: _fontFamily,
  );

  // Helper methods for color variations
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  static TextStyle withWhiteColor(TextStyle style) {
    return style.copyWith(color: AppColors.textLight);
  }

  static TextStyle withSecondaryColor(TextStyle style) {
    return style.copyWith(color: AppColors.textSecondary);
  }

  // Zone-specific text styles
  static TextStyle zoneHeading(String zoneId) {
    return heading2.copyWith(color: AppColors.getZonePrimaryColor(zoneId));
  }

  static TextStyle zoneTitle(String zoneId) {
    return title.copyWith(color: AppColors.getZonePrimaryColor(zoneId));
  }
}
