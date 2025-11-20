import 'dart:math';

import 'package:flutter/material.dart';

/// ConfettiOverlay displays animated confetti particles
/// Used for celebration effects when opening chests or earning rewards
class ConfettiOverlay extends StatefulWidget {
  final int particleCount;
  final Duration duration;

  const ConfettiOverlay({
    super.key,
    this.particleCount = 100,
    this.duration = const Duration(seconds: 3),
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

    _particles = List.generate(
      widget.particleCount,
      (index) => ConfettiParticle(),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
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
    );
  }
}

/// Individual confetti particle with properties
class ConfettiParticle {
  final double startX;
  final double velocityX;
  final double velocityY;
  final double rotation;
  final double rotationSpeed;
  final Color color;
  final double size;

  ConfettiParticle()
    : startX = Random().nextDouble(),
      velocityX = (Random().nextDouble() - 0.5) * 2,
      velocityY = Random().nextDouble() * 2 + 1,
      rotation = Random().nextDouble() * 2 * pi,
      rotationSpeed = (Random().nextDouble() - 0.5) * 4,
      color = _randomColor(),
      size = Random().nextDouble() * 8 + 4;

  static Color _randomColor() {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.amber,
      Colors.cyan,
    ];
    return colors[Random().nextInt(colors.length)];
  }
}

/// Custom painter for confetti particles
class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: 1.0 - progress)
        ..style = PaintingStyle.fill;

      // Calculate position
      final x =
          particle.startX * size.width +
          particle.velocityX * progress * size.width * 0.3;
      final y = particle.velocityY * progress * size.height;

      // Calculate rotation
      final rotation = particle.rotation + particle.rotationSpeed * progress;

      // Draw particle
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      // Draw as rectangle (confetti piece)
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: particle.size,
        height: particle.size * 1.5,
      );
      canvas.drawRect(rect, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Simple confetti burst effect
class ConfettiBurst extends StatefulWidget {
  final VoidCallback? onComplete;

  const ConfettiBurst({super.key, this.onComplete});

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: BurstPainter(progress: _controller.value),
          child: Container(),
        );
      },
    );
  }
}

/// Painter for burst effect
class BurstPainter extends CustomPainter {
  final double progress;

  BurstPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
    ];

    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * (pi / 180);
      final distance = progress * 100;
      final x = center.dx + cos(angle) * distance;
      final y = center.dy + sin(angle) * distance;

      final paint = Paint()
        ..color = colors[i % colors.length].withValues(alpha: 1.0 - progress)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 8 * (1 - progress), paint);
    }
  }

  @override
  bool shouldRepaint(BurstPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
