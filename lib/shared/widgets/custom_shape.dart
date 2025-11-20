import 'dart:math' as dart_math;

import 'package:flutter/material.dart';

/// Custom painter for creating geometric shapes
/// Used in Shape Valley and other games where custom shapes are needed
class ShapePainter extends CustomPainter {
  final ShapeType shapeType;
  final Color color;
  final double size;

  ShapePainter({
    required this.shapeType,
    required this.color,
    this.size = 100,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final radius = size / 2;

    switch (shapeType) {
      case ShapeType.circle:
        canvas.drawCircle(center, radius, paint);
        break;

      case ShapeType.square:
        final rect = Rect.fromCenter(
          center: center,
          width: size,
          height: size,
        );
        canvas.drawRect(rect, paint);
        break;

      case ShapeType.triangle:
        final path = Path();
        path.moveTo(center.dx, center.dy - radius);
        path.lineTo(center.dx - radius, center.dy + radius);
        path.lineTo(center.dx + radius, center.dy + radius);
        path.close();
        canvas.drawPath(path, paint);
        break;

      case ShapeType.star:
        _drawStar(canvas, center, radius, paint);
        break;

      case ShapeType.heart:
        _drawHeart(canvas, center, radius, paint);
        break;

      case ShapeType.diamond:
        final path = Path();
        path.moveTo(center.dx, center.dy - radius);
        path.lineTo(center.dx + radius, center.dy);
        path.lineTo(center.dx, center.dy + radius);
        path.lineTo(center.dx - radius, center.dy);
        path.close();
        canvas.drawPath(path, paint);
        break;
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    const points = 5;
    const angle = (3.14159 * 2) / points;

    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? radius : radius / 2;
      final x = center.dx + r * cos(i * angle - 3.14159 / 2);
      final y = center.dy + r * sin(i * angle - 3.14159 / 2);

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

    path.moveTo(center.dx, center.dy + height / 4);

    // Left curve
    path.cubicTo(
      center.dx - width / 2,
      center.dy - height / 4,
      center.dx - width / 2,
      center.dy - height / 2,
      center.dx,
      center.dy - height / 6,
    );

    // Right curve
    path.cubicTo(
      center.dx + width / 2,
      center.dy - height / 2,
      center.dx + width / 2,
      center.dy - height / 4,
      center.dx,
      center.dy + height / 4,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ShapePainter oldDelegate) {
    return oldDelegate.shapeType != shapeType ||
        oldDelegate.color != color ||
        oldDelegate.size != size;
  }

  double cos(double angle) => angle.cos();
  double sin(double angle) => angle.sin();
}

enum ShapeType {
  circle,
  square,
  triangle,
  star,
  heart,
  diamond,
}

/// Widget that displays a custom painted shape
class CustomShape extends StatelessWidget {
  final ShapeType shapeType;
  final Color color;
  final double size;

  const CustomShape({
    super.key,
    required this.shapeType,
    required this.color,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: ShapePainter(
        shapeType: shapeType,
        color: color,
        size: size,
      ),
    );
  }
}

extension on double {
  double cos() => dart_math.cos(this);
  double sin() => dart_math.sin(this);
}
