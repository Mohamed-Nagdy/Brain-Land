import 'package:flutter/material.dart';

import '../constants/colors.dart';

/// AppTextStyles defines the typography system for BrainLand
/// Includes child-friendly fonts with good readability
class AppTextStyles {
  // Prevent instantiation
  AppTextStyles._();

  // Headings - Bold and playful
  static const heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
    height: 1.2,
    fontFamily: 'Comic Sans MS',
  );

  static const heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: 0.3,
    height: 1.3,
    fontFamily: 'Comic Sans MS',
  );

  static const heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.2,
    height: 1.3,
    fontFamily: 'Comic Sans MS',
  );

  static const heading4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
    fontFamily: 'Comic Sans MS',
  );

  // Body text - Clear and readable
  static const bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
    fontFamily: 'Comic Sans MS',
  );

  static const bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
    fontFamily: 'Comic Sans MS',
  );

  static const bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
    fontFamily: 'Comic Sans MS',
  );

  // Secondary text - Less prominent
  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.4,
    fontFamily: 'Comic Sans MS',
  );

  static const overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 1.5,
    height: 1.6,
    fontFamily: 'Comic Sans MS',
  );

  // Button text - Bold and prominent
  static const button = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 1.0,
    height: 1.2,
    fontFamily: 'Comic Sans MS',
  );

  static const buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 0.8,
    height: 1.2,
    fontFamily: 'Comic Sans MS',
  );

  // Numbers in games - Extra large and clear
  static const gameNumber = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.0,
    fontFamily: 'Comic Sans MS',
  );

  static const gameNumberLarge = TextStyle(
    fontSize: 64,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.0,
    fontFamily: 'Comic Sans MS',
  );

  static const gameNumberSmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.0,
    fontFamily: 'Comic Sans MS',
  );

  // Special text styles
  static const title = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
    height: 1.2,
    fontFamily: 'Comic Sans MS',
  );

  static const subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
    fontFamily: 'Comic Sans MS',
  );

  // Score and stats text
  static const score = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.0,
    fontFamily: 'Comic Sans MS',
  );

  static const stat = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.2,
    fontFamily: 'Comic Sans MS',
  );

  // Label text
  static const label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
    height: 1.4,
    fontFamily: 'Comic Sans MS',
  );

  static const labelBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
    height: 1.4,
    fontFamily: 'Comic Sans MS',
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
