import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../shared/models/zone.dart';

/// A fancy animated card widget for displaying zones on the world map
class AnimatedZoneCard extends StatefulWidget {
  final Zone zone;
  final VoidCallback onTap;

  const AnimatedZoneCard({super.key, required this.zone, required this.onTap});

  @override
  State<AnimatedZoneCard> createState() => _AnimatedZoneCardState();
}

class _AnimatedZoneCardState extends State<AnimatedZoneCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = AppColors.getZoneGradient(widget.zone.id);
    final primaryColor = AppColors.getZonePrimaryColor(widget.zone.id);

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        if (widget.zone.isUnlocked) {
          widget.onTap();
        }
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Animated background particles
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: CustomPaint(
                    painter: ParticlesPainter(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ),
              // Zone content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Zone icon and name
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildZoneIcon(),
                        const SizedBox(height: 12),
                        Text(
                          widget.zone.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.zone.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    // Progress bar
                    _buildProgressBar(),
                  ],
                ),
              ),
              // Lock overlay if locked
              if (!widget.zone.isUnlocked)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(
                      child: Icon(Icons.lock, size: 64, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZoneIcon() {
    IconData iconData;
    switch (widget.zone.type) {
      case ZoneType.mathForest:
        iconData = Icons.calculate;
        break;
      case ZoneType.logicMountain:
        iconData = Icons.psychology;
        break;
      case ZoneType.memoryRiver:
        iconData = Icons.memory;
        break;
      case ZoneType.shapeValley:
        iconData = Icons.category;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(iconData, size: 32, color: Colors.white),
    );
  }

  Widget _buildProgressBar() {
    final progress = widget.zone.totalLevels > 0
        ? widget.zone.completedLevels / widget.zone.totalLevels
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${widget.zone.completedLevels}/${widget.zone.totalLevels} Levels',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.zone.completedLevels >= widget.zone.totalLevels)
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

/// Custom painter for animated particle effects in the background
class ParticlesPainter extends CustomPainter {
  final Color color;
  final Random _random = Random(42); // Fixed seed for consistent particles

  ParticlesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw random particles
    for (int i = 0; i < 20; i++) {
      final x = _random.nextDouble() * size.width;
      final y = _random.nextDouble() * size.height;
      final radius = _random.nextDouble() * 3 + 1;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
