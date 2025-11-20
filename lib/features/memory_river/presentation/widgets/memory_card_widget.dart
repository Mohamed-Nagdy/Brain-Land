import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/animations.dart';
import '../../../../core/constants/colors.dart';
import '../../models/memory_card.dart';

/// A memory card widget with 3D flip animation
/// Features:
/// - 3D flip animation when card is revealed
/// - Front face (card back) and back face (card image)
/// - Different states: face-down, face-up, matched
/// - Tap interaction
/// - Child-friendly design with rounded corners and shadows
class MemoryCardWidget extends StatefulWidget {
  final MemoryCard card;
  final VoidCallback onTap;
  final bool isEnabled;

  const MemoryCardWidget({
    super.key,
    required this.card,
    required this.onTap,
    this.isEnabled = true,
  });

  @override
  State<MemoryCardWidget> createState() => _MemoryCardWidgetState();
}

class _MemoryCardWidgetState extends State<MemoryCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _flipAnimation = Tween<double>(begin: 0.0, end: math.pi).animate(
      CurvedAnimation(
        parent: _flipController,
        curve: AnimationConstants.bounceIn,
      ),
    );

    // Set initial animation state based on card state
    if (widget.card.isFaceUp) {
      _flipController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(MemoryCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Animate flip when card state changes
    if (oldWidget.card.state != widget.card.state) {
      if (widget.card.isFaceUp && !oldWidget.card.isFaceUp) {
        // Flip to face-up
        _flipController.forward();
      } else if (!widget.card.isFaceUp && oldWidget.card.isFaceUp) {
        // Flip to face-down
        _flipController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isEnabled ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          // Determine which side to show based on rotation
          final isFrontSide = _flipAnimation.value < math.pi / 2;
          final rotationAngle = isFrontSide
              ? _flipAnimation.value
              : math.pi - _flipAnimation.value;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspective
              ..rotateY(rotationAngle),
            child: isFrontSide ? _buildFrontFace() : _buildBackFace(),
          );
        },
      ),
    );
  }

  /// Build the front face (card back) - shown when face-down
  Widget _buildFrontFace() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E88E5).withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 3,
        ),
      ),
      child: Stack(
        children: [
          // Decorative pattern
          Positioned.fill(child: CustomPaint(painter: _CardPatternPainter())),
          // Question mark
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Text(
                '?',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the back face (card image) - shown when face-up
  Widget _buildBackFace() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(math.pi), // Flip horizontally
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: widget.card.isMatched
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color(0xFFF5F5F5)],
                ),
          border: Border.all(
            color: widget.card.isMatched
                ? const Color(0xFF4CAF50)
                : const Color(0xFF42A5F5),
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.card.isMatched
                  ? const Color(0xFF4CAF50).withValues(alpha: 0.5)
                  : const Color(0xFF42A5F5).withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.card.isMatched
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: _buildCardImage(),
          ),
        ),
      ),
    );
  }

  /// Build the card image
  /// In a full implementation, this would load the actual image asset
  Widget _buildCardImage() {
    // For now, use a placeholder icon
    // In production, this would be: Image.asset(widget.card.imageAsset)
    return Icon(
      _getIconForAsset(widget.card.imageAsset),
      size: 60,
      color: widget.card.isMatched
          ? AppColors.successGreen
          : AppColors.memoryRiverPurple,
    );
  }

  /// Get an icon based on the asset path
  /// This is a placeholder - in production, actual images would be used
  IconData _getIconForAsset(String assetPath) {
    if (assetPath.contains('apple')) return Icons.apple;
    if (assetPath.contains('banana')) return Icons.emoji_food_beverage;
    if (assetPath.contains('cherry')) return Icons.local_florist;
    if (assetPath.contains('grape')) return Icons.bubble_chart;
    if (assetPath.contains('orange')) return Icons.circle;
    if (assetPath.contains('pear')) return Icons.lightbulb;
    if (assetPath.contains('strawberry')) return Icons.favorite;
    if (assetPath.contains('watermelon')) return Icons.water_drop;
    if (assetPath.contains('pineapple')) return Icons.park;
    if (assetPath.contains('kiwi')) return Icons.eco;
    if (assetPath.contains('mango')) return Icons.wb_sunny;
    if (assetPath.contains('peach')) return Icons.spa;
    if (assetPath.contains('plum')) return Icons.brightness_1;
    if (assetPath.contains('lemon')) return Icons.star;
    if (assetPath.contains('lime')) return Icons.stars;
    return Icons.help_outline;
  }
}

/// Custom painter for decorative pattern on card back
class _CardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw decorative circles
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.3, size.height * (0.3 + i * 0.2)),
        10 + i * 5,
        paint,
      );
      canvas.drawCircle(
        Offset(size.width * 0.7, size.height * (0.3 + i * 0.2)),
        10 + i * 5,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_CardPatternPainter oldDelegate) => false;
}
