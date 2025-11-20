import 'package:flutter/animation.dart';

/// Animation constants and curves for BrainLand
class AnimationConstants {
  // Prevent instantiation
  AnimationConstants._();

  // Duration constants
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 800);
  static const Duration verySlow = Duration(milliseconds: 1200);

  // Curves - Child-friendly bouncy animations
  static const Curve bounceIn = Curves.elasticOut;
  static const Curve bounceOut = Curves.elasticIn;
  static const Curve smooth = Curves.easeInOutCubic;
  static const Curve quick = Curves.easeOut;
  static const Curve gentle = Curves.easeInOut;

  // Scale factors
  static const double scaleDown = 0.95;
  static const double scaleUp = 1.05;
  static const double scaleNormal = 1.0;

  // Rotation angles (in radians)
  static const double rotateSlightly = 0.05;
  static const double rotateModerate = 0.1;

  // Confetti settings
  static const int confettiParticleCount = 50;
  static const double confettiGravity = 0.5;
  static const double confettiVelocityMin = 2.0;
  static const double confettiVelocityMax = 8.0;
}
