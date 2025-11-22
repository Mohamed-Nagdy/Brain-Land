import 'package:adventure_world/core/constants/game_assets.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../shared/models/zone.dart';

/// Child-friendly animated zone card with emojis and bright colors
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
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => _controller.reverse(),
        onTapUp: (_) => _controller.forward(),
        onTapCancel: () => _controller.forward(),
        child: Stack(
          children: [
            // Main Card
            Container(
              decoration: BoxDecoration(
                gradient: _getZoneGradient(),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: _getZoneColor().withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 3,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Stack(
                  children: [
                    // Decorative circles
                    _buildDecorations(),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Zone Emoji & Name
                          Row(
                            children: [
                              // Big emoji icon
                              Text(
                                _getZoneEmoji(),
                                style: const TextStyle(fontSize: 64),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.zone.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black26,
                                            offset: Offset(2, 2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                    _buildProgressBar(),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // Stats Row
                          Row(
                            children: [
                              _buildStatBubble(
                                '${widget.zone.completedLevels}/${widget.zone.totalLevels}',
                                '✅',
                              ),
                              const SizedBox(width: 8),
                              if (widget.zone.completedLevels >=
                                  widget.zone.totalLevels)
                                _buildStatBubble('Complete!', '🏆'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorations() {
    return Stack(
      children: [
        Positioned(
          top: -30,
          right: -30,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
        ),
        Positioned(
          bottom: -20,
          left: -20,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    final progress = widget.zone.totalLevels > 0
        ? widget.zone.completedLevels / widget.zone.totalLevels
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      height: 8,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.5),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBubble(String text, String emoji) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getZoneEmoji() {
    switch (widget.zone.id) {
      case 'math_forest':
        return GameAssets.mathForestEmoji;
      case 'logic_mountain':
        return GameAssets.logicMountainEmoji;
      case 'memory_river':
        return GameAssets.memoryRiverEmoji;
      case 'shape_valley':
        return GameAssets.shapeValleyEmoji;
      default:
        return '🎮';
    }
  }

  Color _getZoneColor() {
    switch (widget.zone.id) {
      case 'math_forest':
        return const Color(0xFF4CAF50); // Green
      case 'logic_mountain':
        return const Color(0xFF9C27B0); // Purple
      case 'memory_river':
        return const Color(0xFF2196F3); // Blue
      case 'shape_valley':
        return const Color(0xFFFF9800); // Orange
      default:
        return AppColors.primary;
    }
  }

  LinearGradient _getZoneGradient() {
    final baseColor = _getZoneColor();
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [baseColor, baseColor.withValues(alpha: 0.7)],
    );
  }
}
