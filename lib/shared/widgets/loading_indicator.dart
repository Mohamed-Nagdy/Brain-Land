import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';

/// LoadingIndicator provides a fancy animated loading spinner
/// Uses gradient colors and smooth animations
class LoadingIndicator extends StatefulWidget {
  final double size;
  final double strokeWidth;
  final Gradient? gradient;
  final String? message;

  const LoadingIndicator({
    super.key,
    this.size = 50,
    this.strokeWidth = 4,
    this.gradient,
    this.message,
  });

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: RotationTransition(
            turns: _controller,
            child: CustomPaint(
              painter: _GradientCircularProgressPainter(
                gradient: widget.gradient ?? AppColors.primaryGradient,
                strokeWidth: widget.strokeWidth,
              ),
            ),
          ),
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _GradientCircularProgressPainter extends CustomPainter {
  final Gradient gradient;
  final double strokeWidth;

  _GradientCircularProgressPainter({
    required this.gradient,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw arc (3/4 of circle)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.57, // Start from top (-90 degrees in radians)
      4.71, // Draw 3/4 of circle (270 degrees in radians)
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_GradientCircularProgressPainter oldDelegate) {
    return oldDelegate.gradient != gradient ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// SimpleLoadingIndicator provides a basic circular progress indicator
class SimpleLoadingIndicator extends StatelessWidget {
  final Color? color;
  final double size;

  const SimpleLoadingIndicator({super.key, this.color, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.primaryGradient.colors.first,
        ),
        strokeWidth: 4,
      ),
    );
  }
}

/// FullScreenLoadingIndicator shows a loading indicator in the center of the screen
class FullScreenLoadingIndicator extends StatelessWidget {
  final String? message;
  final bool showOverlay;

  const FullScreenLoadingIndicator({
    super.key,
    this.message,
    this.showOverlay = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Center(child: LoadingIndicator(message: message));

    if (showOverlay) {
      return Container(
        color: Colors.black.withValues(alpha: 0.3),
        child: content,
      );
    }

    return content;
  }
}

/// PulsingDot provides a simple pulsing dot animation
class PulsingDot extends StatefulWidget {
  final Color color;
  final double size;

  const PulsingDot({
    super.key,
    this.color = AppColors.successGreen,
    this.size = 12,
  });

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}
