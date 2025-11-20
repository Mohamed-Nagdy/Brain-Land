import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';

/// GradientBackground provides a beautiful gradient background for screens
/// Supports zone-specific gradients and custom gradients
class GradientBackground extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;
  final String? zoneId;
  final List<Color>? colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const GradientBackground({
    super.key,
    required this.child,
    this.gradient,
    this.zoneId,
    this.colors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });

  @override
  Widget build(BuildContext context) {
    Gradient effectiveGradient;

    if (gradient != null) {
      effectiveGradient = gradient!;
    } else if (zoneId != null) {
      effectiveGradient = AppColors.getZoneGradient(zoneId!);
    } else if (colors != null && colors!.isNotEmpty) {
      effectiveGradient = LinearGradient(
        colors: colors!,
        begin: begin,
        end: end,
      );
    } else {
      effectiveGradient = AppColors.primaryGradient;
    }

    return Container(
      decoration: BoxDecoration(gradient: effectiveGradient),
      child: child,
    );
  }
}

/// AnimatedGradientBackground provides a gradient background with animation
class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final List<Color> colors;
  final Duration duration;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const AnimatedGradientBackground({
    super.key,
    required this.child,
    required this.colors,
    this.duration = const Duration(seconds: 3),
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.colors,
              begin: widget.begin,
              end: widget.end,
              stops: [0.0, _animation.value, 1.0],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// SimpleBackground provides a solid color background
class SimpleBackground extends StatelessWidget {
  final Widget child;
  final Color? color;

  const SimpleBackground({super.key, required this.child, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(color: color ?? AppColors.background, child: child);
  }
}
