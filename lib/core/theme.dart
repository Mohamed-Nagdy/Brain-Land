import 'package:flutter/material.dart';

/// Brain Land design tokens. One palette, one type family, one spacing scale.
abstract final class Palette {
  static const purple = Color(0xFF6B4CE6);
  static const purpleLight = Color(0xFF9B6CE8);
  static const indigo = Color(0xFF667EEA);
  static const ink = Color(0xFF2E2240);
  static const inkSoft = Color(0xFF5B4E6E);
  static const cream = Color(0xFFFFF6E6);
  static const paper = Color(0xFFFFFCF6);
  static const sand = Color(0xFFF1E4CC);
  static const gold = Color(0xFFFFC83D);
  static const good = Color(0xFF2E9E4F);
  static const oops = Color(0xFFE0673A);

  static const math = Color(0xFF3FAE5A);
  static const logic = Color(0xFF3B8BEB);
  static const memory = Color(0xFF1BAFC2);
  static const shape = Color(0xFFFF8A4C);
}

abstract final class Space {
  static const xs = 4.0;
  static const s = 8.0;
  static const m = 16.0;
  static const l = 24.0;
  static const xl = 32.0;
}

abstract final class Radii {
  static const card = BorderRadius.all(Radius.circular(28));
  static const button = BorderRadius.all(Radius.circular(22));
  static const chip = BorderRadius.all(Radius.circular(14));
}

/// Minimum interactive size for small hands (above the 48dp platform minimum).
const double kTouchTarget = 56;

TextStyle _baloo(double size, double weight, {Color color = Palette.ink}) =>
    TextStyle(
      fontFamily: 'Baloo',
      fontSize: size,
      height: 1.25,
      color: color,
      fontVariations: [FontVariation('wght', weight)],
    );

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: Palette.purple,
    primary: Palette.purple,
    surface: Palette.paper,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Palette.cream,
    fontFamily: 'Baloo',
    textTheme: TextTheme(
      displaySmall: _baloo(34, 800),
      headlineMedium: _baloo(28, 800),
      headlineSmall: _baloo(24, 750),
      titleLarge: _baloo(22, 700),
      titleMedium: _baloo(18, 650),
      bodyLarge: _baloo(18, 500),
      bodyMedium: _baloo(16, 500, color: Palette.inkSoft),
      labelLarge: _baloo(20, 750),
      labelMedium: _baloo(15, 650),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(Colors.white),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? Palette.good
            : Palette.inkSoft.withValues(alpha: .35),
      ),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
  );
}
