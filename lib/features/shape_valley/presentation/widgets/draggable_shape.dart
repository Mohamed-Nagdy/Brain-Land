import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/shape.dart';

/// A draggable shape widget with visual feedback
/// Features:
/// - Drag functionality
/// - Shadow during drag
/// - Snap-to-position animation
/// - Color and shape rendering
class DraggableShape extends StatefulWidget {
  final Shape shape;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnd;
  final Function(String targetId)? onAccepted;
  final bool isEnabled;
  final double size;
  final bool isHighlighted;

  const DraggableShape({
    super.key,
    required this.shape,
    this.onDragStarted,
    this.onDragEnd,
    this.onAccepted,
    this.isEnabled = true,
    this.size = 80.0,
    this.isHighlighted = false,
  });

  @override
  State<DraggableShape> createState() => _DraggableShapeState();
}

class _DraggableShapeState extends State<DraggableShape>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(DraggableShape oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHighlighted && !oldWidget.isHighlighted) {
      _controller.repeat(reverse: true);
    } else if (!widget.isHighlighted && oldWidget.isHighlighted) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getShapeColor() {
    switch (widget.shape.color) {
      case ShapeColor.red:
        return const Color(0xFFFF6B6B); // Coral Red
      case ShapeColor.blue:
        return const Color(0xFF4ECDC4); // Turquoise Blue
      case ShapeColor.green:
        return const Color(0xFF2ECC71); // Emerald Green
      case ShapeColor.yellow:
        return const Color(0xFFFFD93D); // Sunny Yellow
      case ShapeColor.purple:
        return const Color(0xFF9B59B6); // Amethyst Purple
      case ShapeColor.orange:
        return const Color(0xFFFF9F43); // Tangerine Orange
      case ShapeColor.pink:
        return const Color(0xFFFF8FAB); // Light Pink
      case ShapeColor.cyan:
        return const Color(0xFF00E5FF); // Bright Cyan
    }
  }

  Widget _buildShape() {
    final color = _getShapeColor();
    final shapeSize =
        widget.size * (widget.shape.size / 2.0); // Scale by size property

    Widget shapeWidget;
    switch (widget.shape.type) {
      case ShapeType.circle:
        shapeWidget = Container(
          width: shapeSize,
          height: shapeSize,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: _isDragging
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
            border: widget.isHighlighted
                ? Border.all(color: Colors.white, width: 4)
                : null,
          ),
        );
        break;

      case ShapeType.square:
        shapeWidget = Container(
          width: shapeSize,
          height: shapeSize,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            boxShadow: _isDragging
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
            border: widget.isHighlighted
                ? Border.all(color: Colors.white, width: 4)
                : null,
          ),
        );
        break;

      case ShapeType.triangle:
        shapeWidget = CustomPaint(
          size: Size(shapeSize, shapeSize),
          painter: TrianglePainter(
            color: color,
            hasShadow: _isDragging,
            isHighlighted: widget.isHighlighted,
          ),
        );
        break;

      case ShapeType.rectangle:
        shapeWidget = Container(
          width: shapeSize * 1.5,
          height: shapeSize,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            boxShadow: _isDragging
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
            border: widget.isHighlighted
                ? Border.all(color: Colors.white, width: 4)
                : null,
          ),
        );
        break;

      case ShapeType.star:
        shapeWidget = CustomPaint(
          size: Size(shapeSize, shapeSize),
          painter: StarPainter(
            color: color,
            hasShadow: _isDragging,
            isHighlighted: widget.isHighlighted,
          ),
        );
        break;

      case ShapeType.heart:
        shapeWidget = CustomPaint(
          size: Size(shapeSize, shapeSize),
          painter: HeartPainter(
            color: color,
            hasShadow: _isDragging,
            isHighlighted: widget.isHighlighted,
          ),
        );
        break;

      case ShapeType.diamond:
        shapeWidget = CustomPaint(
          size: Size(shapeSize, shapeSize),
          painter: DiamondPainter(
            color: color,
            hasShadow: _isDragging,
            isHighlighted: widget.isHighlighted,
          ),
        );
        break;

      case ShapeType.hexagon:
        shapeWidget = CustomPaint(
          size: Size(shapeSize, shapeSize),
          painter: HexagonPainter(
            color: color,
            hasShadow: _isDragging,
            isHighlighted: widget.isHighlighted,
          ),
        );
        break;
    }

    if (widget.isHighlighted) {
      return ScaleTransition(scale: _scaleAnimation, child: shapeWidget);
    }
    return shapeWidget;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEnabled) {
      return _buildShape();
    }

    return Draggable<Shape>(
      data: widget.shape,
      feedback: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(opacity: 0.8, child: _buildShape()),
          );
        },
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: _buildShape()),
      onDragStarted: () {
        setState(() {
          _isDragging = true;
        });
        _controller.forward();
        widget.onDragStarted?.call();
      },
      onDragEnd: (_) {
        setState(() {
          _isDragging = false;
        });
        _controller.reverse();
        widget.onDragEnd?.call();
      },
      child: _buildShape(),
    );
  }
}

/// Custom painter for triangle shape
class TrianglePainter extends CustomPainter {
  final Color color;
  final bool hasShadow;
  final bool isHighlighted;

  TrianglePainter({
    required this.color,
    this.hasShadow = false,
    this.isHighlighted = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    if (hasShadow) {
      final shadowPaint = Paint()
        ..color = color.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawPath(_getTrianglePath(size), shadowPaint);
    }

    canvas.drawPath(_getTrianglePath(size), paint);

    if (isHighlighted) {
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      canvas.drawPath(_getTrianglePath(size), borderPaint);
    }
  }

  Path _getTrianglePath(Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) =>
      color != oldDelegate.color ||
      hasShadow != oldDelegate.hasShadow ||
      isHighlighted != oldDelegate.isHighlighted;
}

/// Custom painter for star shape
class StarPainter extends CustomPainter {
  final Color color;
  final bool hasShadow;
  final bool isHighlighted;

  StarPainter({
    required this.color,
    this.hasShadow = false,
    this.isHighlighted = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    if (hasShadow) {
      final shadowPaint = Paint()
        ..color = color.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawPath(_getStarPath(size), shadowPaint);
    }

    canvas.drawPath(_getStarPath(size), paint);

    if (isHighlighted) {
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      canvas.drawPath(_getStarPath(size), borderPaint);
    }
  }

  Path _getStarPath(Size size) {
    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.4;

    for (int i = 0; i < 10; i++) {
      final angle = (i * 36 - 90) * 3.14159 / 180;
      final radius = i.isEven ? outerRadius : innerRadius;
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(StarPainter oldDelegate) =>
      color != oldDelegate.color ||
      hasShadow != oldDelegate.hasShadow ||
      isHighlighted != oldDelegate.isHighlighted;
}

/// Custom painter for heart shape
class HeartPainter extends CustomPainter {
  final Color color;
  final bool hasShadow;
  final bool isHighlighted;

  HeartPainter({
    required this.color,
    this.hasShadow = false,
    this.isHighlighted = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    if (hasShadow) {
      final shadowPaint = Paint()
        ..color = color.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawPath(_getHeartPath(size), shadowPaint);
    }

    canvas.drawPath(_getHeartPath(size), paint);

    if (isHighlighted) {
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      canvas.drawPath(_getHeartPath(size), borderPaint);
    }
  }

  Path _getHeartPath(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;

    path.moveTo(width / 2, height * 0.3);
    path.cubicTo(
      width / 2,
      height * 0.2,
      width * 0.3,
      height * 0.1,
      width * 0.2,
      height * 0.2,
    );
    path.cubicTo(0, height * 0.3, 0, height * 0.5, 0, height * 0.5);
    path.cubicTo(0, height * 0.7, width / 2, height, width / 2, height);
    path.cubicTo(width / 2, height, width, height * 0.7, width, height * 0.5);
    path.cubicTo(
      width,
      height * 0.5,
      width,
      height * 0.3,
      width * 0.8,
      height * 0.2,
    );
    path.cubicTo(
      width * 0.7,
      height * 0.1,
      width / 2,
      height * 0.2,
      width / 2,
      height * 0.3,
    );
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(HeartPainter oldDelegate) =>
      color != oldDelegate.color ||
      hasShadow != oldDelegate.hasShadow ||
      isHighlighted != oldDelegate.isHighlighted;
}

/// Custom painter for diamond shape
class DiamondPainter extends CustomPainter {
  final Color color;
  final bool hasShadow;
  final bool isHighlighted;

  DiamondPainter({
    required this.color,
    this.hasShadow = false,
    this.isHighlighted = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    if (hasShadow) {
      final shadowPaint = Paint()
        ..color = color.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawPath(_getDiamondPath(size), shadowPaint);
    }

    canvas.drawPath(_getDiamondPath(size), paint);

    if (isHighlighted) {
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      canvas.drawPath(_getDiamondPath(size), borderPaint);
    }
  }

  Path _getDiamondPath(Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(0, size.height / 2);
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(DiamondPainter oldDelegate) =>
      color != oldDelegate.color ||
      hasShadow != oldDelegate.hasShadow ||
      isHighlighted != oldDelegate.isHighlighted;
}

/// Custom painter for hexagon shape
class HexagonPainter extends CustomPainter {
  final Color color;
  final bool hasShadow;
  final bool isHighlighted;

  HexagonPainter({
    required this.color,
    this.hasShadow = false,
    this.isHighlighted = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    if (hasShadow) {
      final shadowPaint = Paint()
        ..color = color.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawPath(_getHexagonPath(size), shadowPaint);
    }

    canvas.drawPath(_getHexagonPath(size), paint);

    if (isHighlighted) {
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      canvas.drawPath(_getHexagonPath(size), borderPaint);
    }
  }

  Path _getHexagonPath(Size size) {
    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 2;

    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 30) * 3.14159 / 180;
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(HexagonPainter oldDelegate) =>
      color != oldDelegate.color ||
      hasShadow != oldDelegate.hasShadow ||
      isHighlighted != oldDelegate.isHighlighted;
}

// Helper functions for trigonometry
double cos(double angle) => math.cos(angle);
double sin(double angle) => math.sin(angle);
