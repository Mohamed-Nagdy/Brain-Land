import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/constants/animations.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/text_styles.dart';
import 'confetti_overlay.dart';

/// MilestoneCelebration displays special animations for achievements
/// Includes trophy/badge reveal effects and confetti
class MilestoneCelebration extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback? onComplete;
  final bool showConfetti;

  const MilestoneCelebration({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.color = AppColors.successGreen,
    this.onComplete,
    this.showConfetti = true,
  });

  @override
  State<MilestoneCelebration> createState() => _MilestoneCelebrationState();
}

class _MilestoneCelebrationState extends State<MilestoneCelebration>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Scale animation for trophy/badge entrance
    _scaleController = AnimationController(
      duration: AnimationConstants.slow,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: AnimationConstants.bounceIn,
      ),
    );

    // Rotation animation for trophy/badge
    _rotateController = AnimationController(
      duration: AnimationConstants.verySlow,
      vsync: this,
    );
    _rotateAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeInOut),
    );

    // Glow animation for pulsing effect
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Start animations
    _scaleController.forward();
    _rotateController.repeat(reverse: true);
    _glowController.repeat(reverse: true);

    // Auto-complete after duration
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotateController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.7),
      child: Stack(
        children: [
          // Confetti overlay
          if (widget.showConfetti)
            ConfettiOverlay(
              isActive: true,
              duration: const Duration(seconds: 3),
            ),
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Trophy/Badge with animations
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: RotationTransition(
                    turns: _rotateAnimation,
                    child: AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.color.withValues(alpha: 0.2),
                            boxShadow: [
                              BoxShadow(
                                color: widget.color.withValues(
                                  alpha: _glowAnimation.value * 0.6,
                                ),
                                blurRadius: 40 * _glowAnimation.value,
                                spreadRadius: 10 * _glowAnimation.value,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              widget.icon,
                              size: 80,
                              color: widget.color,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Title with fade-in
                FadeTransition(
                  opacity: _scaleAnimation,
                  child: Text(
                    widget.title,
                    style: AppTextStyles.heading1.copyWith(
                      color: Colors.white,
                      fontSize: 36,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                // Description with fade-in
                FadeTransition(
                  opacity: _scaleAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      widget.description,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// BadgeReveal displays an animated badge reveal effect
class BadgeReveal extends StatefulWidget {
  final String badgeName;
  final IconData badgeIcon;
  final Color badgeColor;
  final VoidCallback? onComplete;

  const BadgeReveal({
    super.key,
    required this.badgeName,
    required this.badgeIcon,
    this.badgeColor = AppColors.successGreen,
    this.onComplete,
  });

  @override
  State<BadgeReveal> createState() => _BadgeRevealState();
}

class _BadgeRevealState extends State<BadgeReveal>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeIn),
      ),
    );

    _controller.forward().then((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          widget.onComplete?.call();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Badge with reveal animation
          ScaleTransition(
            scale: _scaleAnimation,
            child: RotationTransition(
              turns: _rotateAnimation,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      widget.badgeColor,
                      widget.badgeColor.withValues(alpha: 0.6),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.badgeColor.withValues(alpha: 0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(widget.badgeIcon, size: 60, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Badge name with fade-in
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              widget.badgeName,
              style: AppTextStyles.heading2.copyWith(color: widget.badgeColor),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// TrophyReveal displays an animated trophy reveal effect
class TrophyReveal extends StatefulWidget {
  final String achievementName;
  final String achievementDescription;
  final VoidCallback? onComplete;

  const TrophyReveal({
    super.key,
    required this.achievementName,
    required this.achievementDescription,
    this.onComplete,
  });

  @override
  State<TrophyReveal> createState() => _TrophyRevealState();
}

class _TrophyRevealState extends State<TrophyReveal>
    with TickerProviderStateMixin {
  late AnimationController _riseController;
  late AnimationController _shineController;
  late Animation<double> _riseAnimation;
  late Animation<double> _shineAnimation;

  @override
  void initState() {
    super.initState();

    // Trophy rising animation
    _riseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _riseAnimation = Tween<double>(begin: 200.0, end: 0.0).animate(
      CurvedAnimation(parent: _riseController, curve: Curves.easeOutCubic),
    );

    // Shine animation
    _shineController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _shineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shineController, curve: Curves.easeInOut),
    );

    _riseController.forward();
    _shineController.repeat();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _riseController.dispose();
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _riseAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _riseAnimation.value),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Trophy with shine effect
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Shine effect
                    AnimatedBuilder(
                      animation: _shineAnimation,
                      builder: (context, child) {
                        return CustomPaint(
                          size: const Size(200, 200),
                          painter: ShinePainter(
                            progress: _shineAnimation.value,
                            color: Colors.amber,
                          ),
                        );
                      },
                    ),
                    // Trophy icon
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [Colors.amber, Colors.orange],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.6),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.emoji_events,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Achievement name
                FadeTransition(
                  opacity: _riseController,
                  child: Text(
                    widget.achievementName,
                    style: AppTextStyles.heading1.copyWith(color: Colors.amber),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                // Achievement description
                FadeTransition(
                  opacity: _riseController,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      widget.achievementDescription,
                      style: AppTextStyles.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// ShinePainter draws a rotating shine effect
class ShinePainter extends CustomPainter {
  final double progress;
  final Color color;

  ShinePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw rotating rays
    for (int i = 0; i < 8; i++) {
      final angle = (i * pi / 4) + (progress * 2 * pi);
      final startX = center.dx + (radius * 0.5) * cos(angle);
      final startY = center.dy + (radius * 0.5) * sin(angle);
      final endX = center.dx + radius * cos(angle);
      final endY = center.dy + radius * sin(angle);

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(ShinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// StarBurst displays an animated star burst effect
class StarBurst extends StatefulWidget {
  final int starCount;
  final Color color;
  final Duration duration;

  const StarBurst({
    super.key,
    this.starCount = 12,
    this.color = Colors.amber,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<StarBurst> createState() => _StarBurstState();
}

class _StarBurstState extends State<StarBurst>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..forward();
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
          painter: StarBurstPainter(
            progress: _controller.value,
            starCount: widget.starCount,
            color: widget.color,
          ),
          child: Container(),
        );
      },
    );
  }
}

/// StarBurstPainter draws an expanding star burst
class StarBurstPainter extends CustomPainter {
  final double progress;
  final int starCount;
  final Color color;

  StarBurstPainter({
    required this.progress,
    required this.starCount,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    final radius = maxRadius * progress;

    for (int i = 0; i < starCount; i++) {
      final angle = (i * 2 * pi / starCount);
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);

      final paint = Paint()
        ..color = color.withValues(alpha: 1.0 - progress)
        ..style = PaintingStyle.fill;

      // Draw star
      _drawStar(canvas, Offset(x, y), 10 * (1 - progress * 0.5), paint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    final outerRadius = size;
    final innerRadius = size / 2;
    final points = 5;

    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = (i * pi / points) - pi / 2;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);

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
  bool shouldRepaint(StarBurstPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
