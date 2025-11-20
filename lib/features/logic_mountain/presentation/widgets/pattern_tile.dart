import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/pattern_problem.dart';

/// Widget for displaying a single pattern element (color, shape, number, or size)
class PatternTile extends StatelessWidget {
  final PatternElement element;
  final bool isPlaceholder;
  final double size;

  const PatternTile({
    super.key,
    required this.element,
    this.isPlaceholder = false,
    this.size = 80.0,
  });

  @override
  Widget build(BuildContext context) {
    if (isPlaceholder) {
      return _buildPlaceholder();
    }

    // Determine what to display based on element properties
    if (element.color != null && element.shape == null) {
      return _buildColorTile();
    } else if (element.shape != null) {
      return _buildShapeTile();
    } else if (element.number != null) {
      return _buildNumberTile();
    } else if (element.size != null) {
      return _buildSizeTile();
    }

    return _buildPlaceholder();
  }

  /// Build a placeholder tile (question mark)
  Widget _buildPlaceholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[400]!, width: 2),
      ),
      child: Center(
        child: Icon(
          Icons.question_mark,
          size: size * 0.5,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  /// Build a color tile
  Widget _buildColorTile() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getColorFromEnum(element.color!),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _getColorFromEnum(element.color!).withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }

  /// Build a shape tile
  Widget _buildShapeTile() {
    final color = element.color != null
        ? _getColorFromEnum(element.color!)
        : Colors.blue;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 2),
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.6, size * 0.6),
          painter: _ShapePainter(shape: element.shape!, color: color),
        ),
      ),
    );
  }

  /// Build a number tile
  Widget _buildNumberTile() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[400]!, Colors.blue[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '${element.number}',
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Build a size tile (circle with varying size)
  Widget _buildSizeTile() {
    final circleSize = size * 0.2 * element.size!;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 2),
      ),
      child: Center(
        child: Container(
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            color: Colors.purple[400],
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  /// Convert PatternColor enum to Flutter Color
  Color _getColorFromEnum(PatternColor patternColor) {
    switch (patternColor) {
      case PatternColor.red:
        return Colors.red[400]!;
      case PatternColor.blue:
        return Colors.blue[400]!;
      case PatternColor.green:
        return Colors.green[400]!;
      case PatternColor.yellow:
        return Colors.yellow[600]!;
      case PatternColor.purple:
        return Colors.purple[400]!;
      case PatternColor.orange:
        return Colors.orange[400]!;
    }
  }
}

/// Custom painter for drawing shapes
class _ShapePainter extends CustomPainter {
  final PatternShape shape;
  final Color color;

  _ShapePainter({required this.shape, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    switch (shape) {
      case PatternShape.circle:
        canvas.drawCircle(center, radius, paint);
        break;

      case PatternShape.square:
        final rect = Rect.fromCenter(
          center: center,
          width: size.width,
          height: size.height,
        );
        canvas.drawRect(rect, paint);
        break;

      case PatternShape.triangle:
        final path = Path()
          ..moveTo(center.dx, center.dy - radius)
          ..lineTo(center.dx - radius, center.dy + radius)
          ..lineTo(center.dx + radius, center.dy + radius)
          ..close();
        canvas.drawPath(path, paint);
        break;

      case PatternShape.star:
        _drawStar(canvas, center, radius, paint);
        break;

      case PatternShape.heart:
        _drawHeart(canvas, center, radius, paint);
        break;

      case PatternShape.diamond:
        final path = Path()
          ..moveTo(center.dx, center.dy - radius)
          ..lineTo(center.dx + radius, center.dy)
          ..lineTo(center.dx, center.dy + radius)
          ..lineTo(center.dx - radius, center.dy)
          ..close();
        canvas.drawPath(path, paint);
        break;
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    final outerRadius = radius;
    final innerRadius = radius * 0.4;

    for (int i = 0; i < 10; i++) {
      final angle = (i * 36 - 90) * math.pi / 180;
      final r = i.isEven ? outerRadius : innerRadius;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawHeart(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    final width = radius * 2;
    final height = radius * 2;

    path.moveTo(center.dx, center.dy + height * 0.3);

    // Left curve
    path.cubicTo(
      center.dx - width * 0.5,
      center.dy - height * 0.1,
      center.dx - width * 0.5,
      center.dy - height * 0.5,
      center.dx,
      center.dy - height * 0.3,
    );

    // Right curve
    path.cubicTo(
      center.dx + width * 0.5,
      center.dy - height * 0.5,
      center.dx + width * 0.5,
      center.dy - height * 0.1,
      center.dx,
      center.dy + height * 0.3,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ShapePainter oldDelegate) =>
      shape != oldDelegate.shape || color != oldDelegate.color;
}
