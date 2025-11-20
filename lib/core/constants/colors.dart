import 'package:flutter/material.dart';

/// AppColors defines the complete color palette for BrainLand
/// Includes zone-specific gradients, UI colors, and text colors
class AppColors {
  // Prevent instantiation
  AppColors._();

  // Primary colors (for theme compatibility)
  static const primary = Color(0xFF6B4CE6);
  static const secondary = Color(0xFF9B6CE8);
  static const surface = Color(0xFFFAFBFC);
  static const textOnPrimary = Colors.white;
  static const success = Color(0xFF4CAF50);

  // Zone primary colors (for test compatibility)
  static const mathForest = Color(0xFF4CAF50);
  static const logicMountain = Color(0xFF2196F3);
  static const memoryRiver = Color(0xFF9C27B0);
  static const shapeValley = Color(0xFFFF9800);

  // Primary gradient colors
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF6B4CE6), Color(0xFF9B6CE8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // World Map gradient (multi-color for main screen)
  static const worldMapGradient = LinearGradient(
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Math Forest Zone Colors
  static const mathForestGreen = Color(0xFF4CAF50);
  static const mathForestLight = Color(0xFF81C784);
  static const mathForestDark = Color(0xFF388E3C);
  static const mathForestGradient = LinearGradient(
    colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Logic Mountain Zone Colors
  static const logicMountainBlue = Color(0xFF2196F3);
  static const logicMountainLight = Color(0xFF64B5F6);
  static const logicMountainDark = Color(0xFF1976D2);
  static const logicMountainGradient = LinearGradient(
    colors: [Color(0xFF42A5F5), Color(0xFF2196F3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Memory River Zone Colors
  static const memoryRiverPurple = Color(0xFF9C27B0);
  static const memoryRiverLight = Color(0xFFBA68C8);
  static const memoryRiverDark = Color(0xFF7B1FA2);
  static const memoryRiverGradient = LinearGradient(
    colors: [Color(0xFFAB47BC), Color(0xFF9C27B0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shape Valley Zone Colors
  static const shapeValleyOrange = Color(0xFFFF9800);
  static const shapeValleyLight = Color(0xFFFFB74D);
  static const shapeValleyDark = Color(0xFFF57C00);
  static const shapeValleyGradient = LinearGradient(
    colors: [Color(0xFFFFA726), Color(0xFFFF9800)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // UI Background Colors
  static const background = Color(0xFFF5F7FA);
  static const cardBackground = Colors.white;
  static const surfaceLight = Color(0xFFFAFBFC);
  static const surfaceDark = Color(0xFFE8EAED);

  // Feedback Colors
  static const successGreen = Color(0xFF4CAF50);
  static const errorRed = Color(0xFFFF5252);
  static const warningYellow = Color(0xFFFFC107);
  static const infoBlue = Color(0xFF2196F3);

  // Text Colors
  static const textPrimary = Color(0xFF2C3E50);
  static const textSecondary = Color(0xFF7F8C8D);
  static const textLight = Colors.white;
  static const textDisabled = Color(0xFFBDC3C7);

  // Accent Colors for UI Elements
  static const starGold = Color(0xFFFFD700);
  static const coinGold = Color(0xFFFFA000);
  static const lockGray = Color(0xFF95A5A6);

  // Overlay Colors
  static const overlayDark = Color(0x80000000); // 50% black
  static const overlayLight = Color(0x40FFFFFF); // 25% white

  // Gradient Helpers
  static LinearGradient getZoneGradient(String zoneId) {
    switch (zoneId) {
      case 'math_forest':
        return mathForestGradient;
      case 'logic_mountain':
        return logicMountainGradient;
      case 'memory_river':
        return memoryRiverGradient;
      case 'shape_valley':
        return shapeValleyGradient;
      default:
        return primaryGradient;
    }
  }

  static Color getZonePrimaryColor(String zoneId) {
    switch (zoneId) {
      case 'math_forest':
        return mathForestGreen;
      case 'logic_mountain':
        return logicMountainBlue;
      case 'memory_river':
        return memoryRiverPurple;
      case 'shape_valley':
        return shapeValleyOrange;
      default:
        return const Color(0xFF6B4CE6);
    }
  }

  static Color getZoneLightColor(String zoneId) {
    switch (zoneId) {
      case 'math_forest':
        return mathForestLight;
      case 'logic_mountain':
        return logicMountainLight;
      case 'memory_river':
        return memoryRiverLight;
      case 'shape_valley':
        return shapeValleyLight;
      default:
        return const Color(0xFF9B6CE8);
    }
  }

  // Button Gradients
  static const buttonPrimaryGradient = LinearGradient(
    colors: [Color(0xFF6B4CE6), Color(0xFF9B6CE8)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const buttonSuccessGradient = LinearGradient(
    colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const buttonDangerGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF5252)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Answer Bubble Gradients
  static const answerBubbleGradient = LinearGradient(
    colors: [Color(0xFF6B4CE6), Color(0xFF9B6CE8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const correctAnswerGradient = LinearGradient(
    colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const incorrectAnswerGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF5252)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Memory Card Gradients
  static const memoryCardBackGradient = LinearGradient(
    colors: [Color(0xFFAB47BC), Color(0xFF9C27B0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
