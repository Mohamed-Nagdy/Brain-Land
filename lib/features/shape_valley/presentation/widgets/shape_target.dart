import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../models/shape.dart';
import 'draggable_shape.dart';

/// A drop target zone for shapes with visual feedback
/// Features:
/// - Drop target zones
/// - Highlight on drag over
/// - Validation feedback
/// - Display placed shapes
class ShapeTargetWidget extends StatefulWidget {
  final ShapeTarget target;
  final Shape? placedShape;
  final Function(Shape shape)? onShapeDropped;
  final VoidCallback? onShapeRemoved;
  final bool isHighlighted;

  const ShapeTargetWidget({
    super.key,
    required this.target,
    this.placedShape,
    this.onShapeDropped,
    this.onShapeRemoved,
    this.isHighlighted = false,
  });

  @override
  State<ShapeTargetWidget> createState() => _ShapeTargetWidgetState();
}

class _ShapeTargetWidgetState extends State<ShapeTargetWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovering = false;
  bool _showFeedback = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showCorrectFeedback() {
    setState(() {
      _showFeedback = true;
      _isCorrect = true;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showFeedback = false;
        });
      }
    });
  }

  void _showIncorrectFeedback() {
    setState(() {
      _showFeedback = true;
      _isCorrect = false;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showFeedback = false;
        });
      }
    });
  }

  Color _getBorderColor() {
    if (_showFeedback) {
      return _isCorrect ? AppColors.successGreen : AppColors.errorRed;
    }
    if (_isHovering || widget.isHighlighted) {
      return AppColors.shapeValleyOrange;
    }
    if (widget.target.isFilled) {
      return AppColors.successGreen;
    }
    return Colors.grey.shade300; // Visible border for empty state
  }

  Color _getBackgroundColor() {
    if (_showFeedback) {
      return _isCorrect
          ? AppColors.successGreen.withValues(alpha: 0.1)
          : AppColors.errorRed.withValues(alpha: 0.1);
    }
    if (_isHovering || widget.isHighlighted) {
      return AppColors.shapeValleyOrange.withValues(alpha: 0.1);
    }
    // Solid white background as requested
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<Shape>(
      onWillAcceptWithDetails: (details) {
        final shape = details.data;
        setState(() {
          _isHovering = true;
        });
        _controller.forward();
        return widget.target.accepts(shape);
      },
      onLeave: (_) {
        setState(() {
          _isHovering = false;
        });
        _controller.reverse();
      },
      onAcceptWithDetails: (details) {
        final shape = details.data;
        setState(() {
          _isHovering = false;
        });
        _controller.reverse();

        if (widget.target.accepts(shape)) {
          _showCorrectFeedback();
          widget.onShapeDropped?.call(shape);
        } else {
          _showIncorrectFeedback();
        }
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: _getBackgroundColor(),
                  border: Border.all(
                    color: _getBorderColor(),
                    width: 3, // Thicker border
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                    if (_isHovering || widget.isHighlighted)
                      BoxShadow(
                        color: AppColors.shapeValleyOrange.withValues(
                          alpha: 0.4,
                        ),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.placedShape != null)
                      // Show placed shape
                      GestureDetector(
                        onTap: widget.onShapeRemoved,
                        child: DraggableShape(
                          shape: widget.placedShape!,
                          isEnabled: false,
                          size: 70, // Slightly larger
                        ),
                      )
                    else
                      // Show target label
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getTargetIcon(),
                              size: 48, // Larger icon
                              color: AppColors.shapeValleyDark, // Darker color
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.target.label,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textPrimary, // Darker text
                                fontWeight: FontWeight.w800, // Bolder
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  IconData _getTargetIcon() {
    switch (widget.target.rule) {
      case SortingRule.byType:
        return Icons.category;
      case SortingRule.byColor:
        return Icons.palette;
      case SortingRule.bySize:
        return Icons.straighten;
      case SortingRule.byTypeAndColor:
        return Icons.filter_list;
    }
  }
}
