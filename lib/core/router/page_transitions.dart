import 'package:flutter/material.dart';

import '../constants/animations.dart';

/// Custom page transitions for BrainLand
/// Provides smooth, child-friendly animations between screens

/// SlideAndFadeTransition combines slide and fade effects
class SlideAndFadeTransition<T> extends PageRouteBuilder<T> {
  final Widget page;
  final AxisDirection direction;

  SlideAndFadeTransition({
    required this.page,
    this.direction = AxisDirection.left,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => page,
         transitionDuration: AnimationConstants.normal,
         reverseTransitionDuration: AnimationConstants.normal,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           // Determine slide offset based on direction
           Offset begin;
           switch (direction) {
             case AxisDirection.up:
               begin = const Offset(0, 1);
               break;
             case AxisDirection.down:
               begin = const Offset(0, -1);
               break;
             case AxisDirection.left:
               begin = const Offset(1, 0);
               break;
             case AxisDirection.right:
               begin = const Offset(-1, 0);
               break;
           }

           const end = Offset.zero;
           final slideTween = Tween(begin: begin, end: end);
           final fadeTween = Tween<double>(begin: 0.0, end: 1.0);

           final curvedAnimation = CurvedAnimation(
             parent: animation,
             curve: AnimationConstants.smooth,
           );

           return SlideTransition(
             position: slideTween.animate(curvedAnimation),
             child: FadeTransition(
               opacity: fadeTween.animate(curvedAnimation),
               child: child,
             ),
           );
         },
       );
}

/// ScaleAndFadeTransition provides a zoom-in effect with fade
class ScaleAndFadeTransition<T> extends PageRouteBuilder<T> {
  final Widget page;

  ScaleAndFadeTransition({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: AnimationConstants.normal,
        reverseTransitionDuration: AnimationConstants.normal,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final scaleTween = Tween<double>(begin: 0.8, end: 1.0);
          final fadeTween = Tween<double>(begin: 0.0, end: 1.0);

          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: AnimationConstants.bounceIn,
          );

          return ScaleTransition(
            scale: scaleTween.animate(curvedAnimation),
            child: FadeTransition(
              opacity: fadeTween.animate(animation),
              child: child,
            ),
          );
        },
      );
}

/// BounceTransition provides a playful bounce effect
class BounceTransition<T> extends PageRouteBuilder<T> {
  final Widget page;

  BounceTransition({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: AnimationConstants.slow,
        reverseTransitionDuration: AnimationConstants.normal,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final scaleTween = Tween<double>(begin: 0.0, end: 1.0);
          final fadeTween = Tween<double>(begin: 0.0, end: 1.0);

          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: AnimationConstants.bounceIn,
          );

          return ScaleTransition(
            scale: scaleTween.animate(curvedAnimation),
            child: FadeTransition(
              opacity: fadeTween.animate(animation),
              child: child,
            ),
          );
        },
      );
}

/// FadeTransitionRoute provides a simple fade effect
class FadeTransitionRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadeTransitionRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: AnimationConstants.fast,
        reverseTransitionDuration: AnimationConstants.fast,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );
}

/// RotateAndFadeTransition provides a rotating entrance effect
class RotateAndFadeTransition<T> extends PageRouteBuilder<T> {
  final Widget page;

  RotateAndFadeTransition({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: AnimationConstants.normal,
        reverseTransitionDuration: AnimationConstants.normal,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final rotateTween = Tween<double>(begin: 0.0, end: 1.0);
          final fadeTween = Tween<double>(begin: 0.0, end: 1.0);

          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: AnimationConstants.smooth,
          );

          return RotationTransition(
            turns: rotateTween.animate(curvedAnimation),
            child: FadeTransition(
              opacity: fadeTween.animate(animation),
              child: child,
            ),
          );
        },
      );
}

/// Helper extension for easy navigation with custom transitions
extension NavigationExtensions on BuildContext {
  /// Navigate with slide and fade transition
  Future<T?> pushWithSlideAndFade<T>(
    Widget page, {
    AxisDirection direction = AxisDirection.left,
  }) {
    return Navigator.of(
      this,
    ).push<T>(SlideAndFadeTransition(page: page, direction: direction));
  }

  /// Navigate with scale and fade transition
  Future<T?> pushWithScaleAndFade<T>(Widget page) {
    return Navigator.of(this).push<T>(ScaleAndFadeTransition(page: page));
  }

  /// Navigate with bounce transition
  Future<T?> pushWithBounce<T>(Widget page) {
    return Navigator.of(this).push<T>(BounceTransition(page: page));
  }

  /// Navigate with fade transition
  Future<T?> pushWithFade<T>(Widget page) {
    return Navigator.of(this).push<T>(FadeTransitionRoute(page: page));
  }

  /// Replace with slide and fade transition
  Future<T?> replaceWithSlideAndFade<T, TO>(
    Widget page, {
    AxisDirection direction = AxisDirection.left,
    TO? result,
  }) {
    return Navigator.of(this).pushReplacement<T, TO>(
      SlideAndFadeTransition(page: page, direction: direction),
      result: result,
    );
  }
}

/// PageTransitionType enum for go_router integration
enum PageTransitionType {
  slideAndFade,
  scaleAndFade,
  bounce,
  fade,
  rotateAndFade,
}

/// Helper function to create custom transitions for go_router
Widget buildPageTransition({
  required BuildContext context,
  required Animation<double> animation,
  required Animation<double> secondaryAnimation,
  required Widget child,
  PageTransitionType type = PageTransitionType.slideAndFade,
  AxisDirection direction = AxisDirection.left,
}) {
  switch (type) {
    case PageTransitionType.slideAndFade:
      Offset begin;
      switch (direction) {
        case AxisDirection.up:
          begin = const Offset(0, 1);
          break;
        case AxisDirection.down:
          begin = const Offset(0, -1);
          break;
        case AxisDirection.left:
          begin = const Offset(1, 0);
          break;
        case AxisDirection.right:
          begin = const Offset(-1, 0);
          break;
      }

      const end = Offset.zero;
      final slideTween = Tween(begin: begin, end: end);
      final fadeTween = Tween<double>(begin: 0.0, end: 1.0);

      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: AnimationConstants.smooth,
      );

      return SlideTransition(
        position: slideTween.animate(curvedAnimation),
        child: FadeTransition(
          opacity: fadeTween.animate(curvedAnimation),
          child: child,
        ),
      );

    case PageTransitionType.scaleAndFade:
      final scaleTween = Tween<double>(begin: 0.8, end: 1.0);
      final fadeTween = Tween<double>(begin: 0.0, end: 1.0);

      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: AnimationConstants.bounceIn,
      );

      return ScaleTransition(
        scale: scaleTween.animate(curvedAnimation),
        child: FadeTransition(
          opacity: fadeTween.animate(animation),
          child: child,
        ),
      );

    case PageTransitionType.bounce:
      final scaleTween = Tween<double>(begin: 0.0, end: 1.0);
      final fadeTween = Tween<double>(begin: 0.0, end: 1.0);

      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: AnimationConstants.bounceIn,
      );

      return ScaleTransition(
        scale: scaleTween.animate(curvedAnimation),
        child: FadeTransition(
          opacity: fadeTween.animate(animation),
          child: child,
        ),
      );

    case PageTransitionType.fade:
      return FadeTransition(opacity: animation, child: child);

    case PageTransitionType.rotateAndFade:
      final rotateTween = Tween<double>(begin: 0.0, end: 1.0);
      final fadeTween = Tween<double>(begin: 0.0, end: 1.0);

      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: AnimationConstants.smooth,
      );

      return RotationTransition(
        turns: rotateTween.animate(curvedAnimation),
        child: FadeTransition(
          opacity: fadeTween.animate(animation),
          child: child,
        ),
      );
  }
}
