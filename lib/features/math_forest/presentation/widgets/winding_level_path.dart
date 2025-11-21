import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/text_styles.dart';
import '../../models/math_level.dart';

/// Winding path widget for Math Forest level selection
class WindingLevelPath extends StatefulWidget {
  final List<MathLevel> levels;
  final int levelsCompleted;
  final Function(String) onLevelTap;

  const WindingLevelPath({
    super.key,
    required this.levels,
    required this.levelsCompleted,
    required this.onLevelTap,
  });

  @override
  State<WindingLevelPath> createState() => _WindingLevelPathState();
}

class _WindingLevelPathState extends State<WindingLevelPath> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentLevel();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentLevel() {
    if (!mounted) return;

    final levelHeight = 120.0;
    final targetIndex = widget.levelsCompleted;
    final totalLevels = widget.levels.length;
    final y = (totalLevels - 1 - targetIndex) * levelHeight;

    final viewportHeight = _scrollController.position.viewportDimension;
    final targetScroll = y - viewportHeight / 2 + levelHeight / 2;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final clampedScroll = targetScroll.clamp(0.0, maxScroll);

    _scrollController.jumpTo(clampedScroll);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.only(bottom: 100),
          child: CustomPaint(
            painter: PathPainter(
              itemCount: widget.levels.length,
              itemHeight: 120.0,
              pathColor: const Color(0xFF81C784), // Forest green
              width: constraints.maxWidth,
            ),
            child: SizedBox(
              height: widget.levels.length * 120.0 + 100,
              child: Stack(
                children: List.generate(widget.levels.length, (index) {
                  final level = widget.levels[index];
                  final isUnlocked =
                      level.levelNumber <= widget.levelsCompleted + 1;
                  final isCurrent =
                      level.levelNumber == widget.levelsCompleted + 1;

                  // Calculate position along the sine wave path
                  final y = (widget.levels.length - 1 - index) * 120.0 + 60;
                  final xOffset =
                      math.sin(index * 0.8) * (constraints.maxWidth * 0.35);
                  final x =
                      constraints.maxWidth / 2 +
                      xOffset -
                      40; // Center - half button width

                  return Positioned(
                    top: y,
                    left: x,
                    child: _LevelNode(
                      level: level,
                      isUnlocked: isUnlocked,
                      isCurrent: isCurrent,
                      onTap: () {
                        if (isUnlocked) {
                          widget.onLevelTap(level.id);
                        }
                      },
                    ),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Custom painter for the winding path
class PathPainter extends CustomPainter {
  final int itemCount;
  final double itemHeight;
  final Color pathColor;
  final double width;

  PathPainter({
    required this.itemCount,
    required this.itemHeight,
    required this.pathColor,
    required this.width,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = pathColor.withValues(alpha: 0.3)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final centerX = width / 2;

    // Start from bottom
    path.moveTo(centerX, size.height);

    // Draw winding path
    for (int i = 0; i < itemCount; i++) {
      final y = (itemCount - 1 - i) * itemHeight + 60;
      final xOffset = math.sin(i * 0.8) * (width * 0.35);
      final x = centerX + xOffset;

      if (i == 0) {
        path.lineTo(x, y);
      } else {
        final prevY = (itemCount - i) * itemHeight + 60;
        final prevXOffset = math.sin((i - 1) * 0.8) * (width * 0.35);
        final prevX = centerX + prevXOffset;

        // Smooth curve between points
        final controlY = (y + prevY) / 2;
        path.quadraticBezierTo(prevX, controlY, x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw leaves along the path
    final leafPaint = Paint()
      ..color = pathColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < itemCount; i += 3) {
      final y = (itemCount - 1 - i) * itemHeight + 60;
      final xOffset = math.sin(i * 0.8) * (width * 0.35);
      final x = centerX + xOffset + 15;
      canvas.drawCircle(Offset(x, y), 4, leafPaint);
    }
  }

  @override
  bool shouldRepaint(PathPainter oldDelegate) => false;
}

/// Individual level node widget
class _LevelNode extends StatelessWidget {
  final MathLevel level;
  final bool isUnlocked;
  final bool isCurrent;
  final VoidCallback onTap;

  const _LevelNode({
    required this.level,
    required this.isUnlocked,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUnlocked ? onTap : null,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isUnlocked
              ? level.isCompleted
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF4CAF50), // Green for completed
                          Color(0xFF388E3C),
                        ],
                      )
                    : isCurrent
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF2196F3), // Blue for current
                          Color(0xFF1976D2),
                        ],
                      )
                    : const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF66BB6A), // Light Green
                          Color(0xFF43A047), // Medium Green
                        ],
                      )
              : LinearGradient(
                  colors: [Colors.grey.shade400, Colors.grey.shade600],
                ),
          boxShadow: [
            BoxShadow(
              color: isUnlocked
                  ? const Color(0xFF4CAF50).withValues(alpha: 0.4)
                  : Colors.black26,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isCurrent
                ? Colors.yellow
                : Colors.white.withValues(alpha: 0.3),
            width: isCurrent ? 4 : 2,
          ),
        ),
        child: Stack(
          children: [
            // Level number
            Center(
              child: Text(
                '${level.levelNumber}',
                style: AppTextStyles.heading3.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Stars
            if (level.starsEarned > 0)
              Positioned(
                bottom: 4,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    level.starsEarned,
                    (index) =>
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                  ),
                ),
              ),
            // Lock icon
            if (!isUnlocked)
              const Center(
                child: Icon(Icons.lock, color: Colors.white, size: 32),
              ),
          ],
        ),
      ),
    );
  }
}
