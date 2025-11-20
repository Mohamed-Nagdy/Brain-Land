import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/constants/animations.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/text_styles.dart';

/// A celebration widget that displays confetti and success animations
/// Features:
/// - Confetti particle animation
/// - Star burst effect
/// - "Great job!" text animation
/// - Customizable celebration messages
class CelebrationWidget extends StatefulWidget {
  final String message;
  final int stars;
  final VoidCallback? onComplete;
  final bool showConfetti;

  const CelebrationWidget({
    super.key,
    this.message = 'Great job!',
    this.stars = 3,
    this.onComplete,
    this.showConfetti = true,
  });

  @override
  State<CelebrationWidget> createState() => _CelebrationWidgetState();
}

class _CelebrationWidgetState extends State<CelebrationWidget>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _starController;
  late AnimationController _textController;
  late Animation<double> _textScaleAnimation;
  late Animation<double> _textFadeAnimation;
  late List<ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();

    // Confetti animation
    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Star burst animation
    _starController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Text animation
    _textController = AnimationController(
      duration: AnimationConstants.slow,
      vsync: this,
    );

    _textScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: AnimationConstants.bounceIn,
      ),
    );

    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    // Initialize confetti particles
    _particles = _generateConfettiParticles();

    // Start animations
    _confettiController.forward();
    _starController.repeat(reverse: true);
    _textController.forward();

    // Call onComplete when animations finish
    _confettiController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _starController.dispose();
    _textController.dispose();
    super.dispose();
  }

  List<ConfettiParticle> _generateConfettiParticles() {
    final random = Random();
    return List.generate(
      AnimationConstants.confettiParticleCount,
      (index) => ConfettiParticle(
        color: _getRandomColor(random),
        startX: random.nextDouble(),
        startY: -0.1,
        velocityX: (random.nextDouble() - 0.5) * 2,
        velocityY:
            AnimationConstants.confettiVelocityMin +
            random.nextDouble() *
                (AnimationConstants.confettiVelocityMax -
                    AnimationConstants.confettiVelocityMin),
        rotation: random.nextDouble() * 2 * pi,
        rotationSpeed: (random.nextDouble() - 0.5) * 4,
        size: 8 + random.nextDouble() * 8,
      ),
    );
  }

  Color _getRandomColor(Random random) {
    final colors = [
      AppColors.successGreen,
      AppColors.starGold,
      AppColors.mathForestLight,
      AppColors.logicMountainLight,
      AppColors.memoryRiverLight,
      AppColors.shapeValleyLight,
      Colors.pink,
      Colors.cyan,
    ];
    return colors[random.nextInt(colors.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Confetti particles
        if (widget.showConfetti)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _confettiController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ConfettiPainter(
                    particles: _particles,
                    progress: _confettiController.value,
                  ),
                );
              },
            ),
          ),

        // Center content
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Star burst
              AnimatedBuilder(
                animation: _starController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_starController.value * 0.2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.stars,
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(
                            Icons.star,
                            size: 80,
                            color: AppColors.starGold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Celebration text
              FadeTransition(
                opacity: _textFadeAnimation,
                child: ScaleTransition(
                  scale: _textScaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.message,
                      style: AppTextStyles.heading1.copyWith(
                        color: AppColors.successGreen,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Data class for confetti particles
class ConfettiParticle {
  final Color color;
  final double startX;
  final double startY;
  final double velocityX;
  final double velocityY;
  final double rotation;
  final double rotationSpeed;
  final double size;

  ConfettiParticle({
    required this.color,
    required this.startX,
    required this.startY,
    required this.velocityX,
    required this.velocityY,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
  });
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
        ..color = particle.color
        ..style = PaintingStyle.fill;

      // Calculate particle position based on progress
      final x =
          size.width * particle.startX +
          particle.velocityX * progress * size.width * 0.3;
      final y =
          size.height * particle.startY +
          particle.velocityY * progress * size.height * 0.15 +
          AnimationConstants.confettiGravity *
              progress *
              progress *
              size.height *
              0.5;

      // Calculate rotation
      final rotation = particle.rotation + particle.rotationSpeed * progress;

      // Draw particle as rotated rectangle
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size * 0.6,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// A simple celebration overlay that can be shown on top of other widgets
class CelebrationOverlay extends StatelessWidget {
  final Widget child;
  final bool showCelebration;
  final String message;
  final int stars;
  final VoidCallback? onComplete;

  const CelebrationOverlay({
    super.key,
    required this.child,
    required this.showCelebration,
    this.message = 'Great job!',
    this.stars = 3,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (showCelebration)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: CelebrationWidget(
                message: message,
                stars: stars,
                onComplete: onComplete,
              ),
            ),
          ),
      ],
    );
  }
}
