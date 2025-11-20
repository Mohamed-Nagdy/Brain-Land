import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/constants/animations.dart';
import '../../core/constants/colors.dart';

/// ConfettiOverlay displays celebratory confetti particles
/// Uses custom painting with physics-based particle animation
class ConfettiOverlay extends StatefulWidget {
  final bool isActive;
  final Duration duration;
  final int particleCount;
  final VoidCallback? onComplete;

  const ConfettiOverlay({
    super.key,
    this.isActive = true,
    this.duration = const Duration(seconds: 3),
    this.particleCount = AnimationConstants.confettiParticleCount,
    this.onComplete,
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _initializeParticles();

    if (widget.isActive) {
      _controller.forward().then((_) {
        widget.onComplete?.call();
      });
    }

    _controller.addListener(() {
      setState(() {
        _updateParticles();
      });
    });
  }

  void _initializeParticles() {
    final random = Random();
    _particles = List.generate(widget.particleCount, (index) {
      return ConfettiParticle(
        x: random.nextDouble(),
        y: -0.1,
        velocityX: (random.nextDouble() - 0.5) * 2,
        velocityY:
            AnimationConstants.confettiVelocityMin +
            random.nextDouble() *
                (AnimationConstants.confettiVelocityMax -
                    AnimationConstants.confettiVelocityMin),
        color: _getRandomConfettiColor(random),
        size: 8 + random.nextDouble() * 8,
        rotation: random.nextDouble() * 2 * pi,
        rotationSpeed: (random.nextDouble() - 0.5) * 0.2,
        shape:
            ConfettiShape.values[random.nextInt(ConfettiShape.values.length)],
      );
    });
  }

  Color _getRandomConfettiColor(Random random) {
    final colors = [
      AppColors.mathForestGreen,
      AppColors.logicMountainBlue,
      AppColors.memoryRiverPurple,
      AppColors.shapeValleyOrange,
      AppColors.successGreen,
      AppColors.warningYellow,
      Colors.pink,
      Colors.cyan,
      Colors.amber,
      Colors.red,
    ];
    return colors[random.nextInt(colors.length)];
  }

  void _updateParticles() {
    for (var particle in _particles) {
      particle.update();
    }
  }

  @override
  void didUpdateWidget(ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _initializeParticles();
      _controller.forward(from: 0).then((_) {
        widget.onComplete?.call();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive && _controller.value == 0) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: ConfettiPainter(
              particles: _particles,
              progress: _controller.value,
            ),
            child: Container(),
          );
        },
      ),
    );
  }
}

/// ConfettiPainter draws confetti particles on canvas
class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: 1.0 - progress * 0.5)
        ..style = PaintingStyle.fill;

      final x = particle.x * size.width;
      final y = particle.y * size.height;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.rotation);

      switch (particle.shape) {
        case ConfettiShape.circle:
          canvas.drawCircle(Offset.zero, particle.size / 2, paint);
          break;
        case ConfettiShape.square:
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size,
              height: particle.size,
            ),
            paint,
          );
          break;
        case ConfettiShape.triangle:
          final path = Path()
            ..moveTo(0, -particle.size / 2)
            ..lineTo(particle.size / 2, particle.size / 2)
            ..lineTo(-particle.size / 2, particle.size / 2)
            ..close();
          canvas.drawPath(path, paint);
          break;
        case ConfettiShape.star:
          _drawStar(canvas, paint, particle.size);
          break;
      }

      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, Paint paint, double size) {
    final path = Path();
    final outerRadius = size / 2;
    final innerRadius = size / 4;
    final points = 5;

    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = (i * pi / points) - pi / 2;
      final x = radius * cos(angle);
      final y = radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// ConfettiParticle represents a single confetti piece with physics
class ConfettiParticle {
  double x;
  double y;
  double velocityX;
  double velocityY;
  final Color color;
  final double size;
  double rotation;
  final double rotationSpeed;
  final ConfettiShape shape;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.velocityX,
    required this.velocityY,
    required this.color,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.shape,
  });

  void update() {
    // Apply gravity
    velocityY += AnimationConstants.confettiGravity * 0.01;

    // Update position
    x += velocityX * 0.01;
    y += velocityY * 0.01;

    // Update rotation
    rotation += rotationSpeed;

    // Add some air resistance
    velocityX *= 0.99;
    velocityY *= 0.99;
  }
}

/// ConfettiShape defines the shape of confetti particles
enum ConfettiShape { circle, square, triangle, star }
