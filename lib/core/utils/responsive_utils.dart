import 'package:flutter/material.dart';

/// ResponsiveUtils provides utilities for responsive design
/// Helps adapt layouts for different screen sizes (mobile, tablet)
class ResponsiveUtils {
  // Prevent instantiation
  ResponsiveUtils._();

  // Breakpoints
  static const double mobileMaxWidth = 600;
  static const double tabletMaxWidth = 900;
  static const double desktopMinWidth = 901;

  // Minimum touch target sizes (accessibility)
  static const double minTouchTargetSize = 48.0; // Material Design guideline
  static const double minTouchTargetSizeIOS = 44.0; // iOS guideline

  /// Check if device is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileMaxWidth;
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileMaxWidth && width < desktopMinWidth;
  }

  /// Check if device is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopMinWidth;
  }

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Check if device is in portrait mode
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Get screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Get responsive value based on screen size
  static T responsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    }
    return mobile;
  }

  /// Get responsive padding
  static EdgeInsets responsivePadding(BuildContext context) {
    return responsiveValue(
      context,
      mobile: const EdgeInsets.all(16),
      tablet: const EdgeInsets.all(24),
      desktop: const EdgeInsets.all(32),
    );
  }

  /// Get responsive horizontal padding
  static EdgeInsets responsiveHorizontalPadding(BuildContext context) {
    return responsiveValue(
      context,
      mobile: const EdgeInsets.symmetric(horizontal: 16),
      tablet: const EdgeInsets.symmetric(horizontal: 32),
      desktop: const EdgeInsets.symmetric(horizontal: 48),
    );
  }

  /// Get responsive vertical padding
  static EdgeInsets responsiveVerticalPadding(BuildContext context) {
    return responsiveValue(
      context,
      mobile: const EdgeInsets.symmetric(vertical: 16),
      tablet: const EdgeInsets.symmetric(vertical: 24),
      desktop: const EdgeInsets.symmetric(vertical: 32),
    );
  }

  /// Get responsive font size
  static double responsiveFontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return responsiveValue(
      context,
      mobile: mobile,
      tablet: tablet ?? mobile * 1.1,
      desktop: desktop ?? mobile * 1.2,
    );
  }

  /// Get responsive spacing
  static double responsiveSpacing(BuildContext context) {
    return responsiveValue(context, mobile: 8.0, tablet: 12.0, desktop: 16.0);
  }

  /// Get grid column count based on screen size
  static int getGridColumnCount(BuildContext context) {
    return responsiveValue(context, mobile: 2, tablet: 3, desktop: 4);
  }

  /// Get responsive card width
  static double getCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return responsiveValue(
      context,
      mobile: screenWidth * 0.9,
      tablet: screenWidth * 0.45,
      desktop: screenWidth * 0.3,
    );
  }

  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Calculate responsive size based on screen width percentage
  static double widthPercentage(BuildContext context, double percentage) {
    return screenWidth(context) * (percentage / 100);
  }

  /// Calculate responsive size based on screen height percentage
  static double heightPercentage(BuildContext context, double percentage) {
    return screenHeight(context) * (percentage / 100);
  }
}

/// ResponsiveBuilder widget for building responsive layouts
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints)
  mobile;
  final Widget Function(BuildContext context, BoxConstraints constraints)?
  tablet;
  final Widget Function(BuildContext context, BoxConstraints constraints)?
  desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ResponsiveUtils.desktopMinWidth &&
            desktop != null) {
          return desktop!(context, constraints);
        } else if (constraints.maxWidth >= ResponsiveUtils.mobileMaxWidth &&
            tablet != null) {
          return tablet!(context, constraints);
        }
        return mobile(context, constraints);
      },
    );
  }
}

/// OrientationBuilder widget for building orientation-specific layouts
class OrientationLayoutBuilder extends StatelessWidget {
  final Widget Function(BuildContext context) portrait;
  final Widget Function(BuildContext context)? landscape;

  const OrientationLayoutBuilder({
    super.key,
    required this.portrait,
    this.landscape,
  });

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape && landscape != null) {
          return landscape!(context);
        }
        return portrait(context);
      },
    );
  }
}

/// Extension on BuildContext for easier access to responsive utilities
extension ResponsiveContext on BuildContext {
  bool get isMobile => ResponsiveUtils.isMobile(this);
  bool get isTablet => ResponsiveUtils.isTablet(this);
  bool get isDesktop => ResponsiveUtils.isDesktop(this);
  bool get isLandscape => ResponsiveUtils.isLandscape(this);
  bool get isPortrait => ResponsiveUtils.isPortrait(this);

  double get screenWidth => ResponsiveUtils.screenWidth(this);
  double get screenHeight => ResponsiveUtils.screenHeight(this);

  EdgeInsets get responsivePadding => ResponsiveUtils.responsivePadding(this);
  EdgeInsets get responsiveHorizontalPadding =>
      ResponsiveUtils.responsiveHorizontalPadding(this);
  EdgeInsets get responsiveVerticalPadding =>
      ResponsiveUtils.responsiveVerticalPadding(this);

  double get responsiveSpacing => ResponsiveUtils.responsiveSpacing(this);
  int get gridColumnCount => ResponsiveUtils.getGridColumnCount(this);

  T responsiveValue<T>({required T mobile, T? tablet, T? desktop}) =>
      ResponsiveUtils.responsiveValue(
        this,
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
      );
}
