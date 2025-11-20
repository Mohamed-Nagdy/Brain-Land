import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../models/logic_level.dart';

class WindingLogicPath extends StatefulWidget {
  final List<LogicLevel> levels;
  final int levelsCompleted;
  final Function(String) onLevelTap;

  const WindingLogicPath({
    super.key,
    required this.levels,
    required this.levelsCompleted,
    required this.onLevelTap,
  });

  @override
  State<WindingLogicPath> createState() => _WindingLogicPathState();
}

class _WindingLogicPathState extends State<WindingLogicPath> {
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
    // Calculate the target level index (0-based)
    // If levelsCompleted is 0, we want to show level 1 (index 0)
    final targetIndex = widget.levelsCompleted;

    // Calculate y position of the target level
    // Note: The path is drawn from bottom to top, so index 0 is at the bottom
    // y = (total - 1 - index) * height
    final totalLevels = widget.levels.length;
    final y = (totalLevels - 1 - targetIndex) * levelHeight;

    // We want this y to be roughly in the middle of the screen
    // But we need to clamp it to the scroll extents
    final viewportHeight = _scrollController.position.viewportDimension;
    final targetScroll = y - viewportHeight / 2 + levelHeight / 2;

    // Clamp to valid range
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
              pathColor: const Color(0xFF90CAF9), // Light Blue path
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
                  // Start from bottom (like Math Forest)
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
      ..color = pathColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 40.0
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Start from the bottom (first level)
    final startY = (itemCount - 1) * itemHeight + 60;
    final startXOffset = math.sin(0) * (width * 0.35);
    path.moveTo(width / 2 + startXOffset, startY);

    for (int i = 1; i < itemCount; i++) {
      final y = (itemCount - 1 - i) * itemHeight + 60;
      final xOffset = math.sin(i * 0.8) * (width * 0.35);
      final x = width / 2 + xOffset;

      // Draw quadratic bezier to next point for smoothness
      final prevY = (itemCount - 1 - (i - 1)) * itemHeight + 60;
      final prevXOffset = math.sin((i - 1) * 0.8) * (width * 0.35);
      final prevX = width / 2 + prevXOffset;

      final controlX = (prevX + x) / 2;
      final controlY = (prevY + y) / 2;

      path.quadraticBezierTo(controlX, controlY, x, y);
    }

    // Draw path border/shadow (snowy effect)
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 48.0
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, borderPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LevelNode extends StatelessWidget {
  final LogicLevel level;
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
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
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
                          Color(0xFF64B5F6), // Light Blue
                          Color(0xFF42A5F5),
                        ],
                      )
              : LinearGradient(
                  colors: [Colors.grey.shade400, Colors.grey.shade600],
                ),
          shape: BoxShape.circle,
          border: Border.all(
            color: isCurrent ? Colors.white : const Color(0xFF1976D2),
            width: isCurrent ? 4 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Snowflake pattern
            if (isUnlocked)
              const Icon(Icons.ac_unit, color: Colors.white24, size: 48),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isUnlocked)
                  const Icon(Icons.lock, color: Colors.white54, size: 32)
                else ...[
                  Text(
                    '${level.levelNumber}',
                    style: AppTextStyles.heading3.copyWith(
                      color: Colors.white,
                      fontSize: 24,
                      shadows: [
                        const Shadow(
                          color: Colors.black45,
                          blurRadius: 2,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                  if (level.starsEarned > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return Icon(
                          index < level.starsEarned
                              ? Icons.star
                              : Icons.star_border,
                          color: index < level.starsEarned
                              ? Colors.amber
                              : Colors.white38,
                          size: 12,
                        );
                      }),
                    ),
                ],
              ],
            ),

            // Checkmark if completed
            if (level.isCompleted)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.successGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
