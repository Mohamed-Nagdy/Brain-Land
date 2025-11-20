import 'package:flutter/material.dart';

import '../../models/pattern_problem.dart';
import 'pattern_tile.dart';

/// Widget for displaying a selectable pattern option
class PatternOption extends StatefulWidget {
  final PatternElement element;
  final VoidCallback onTap;
  final bool isSelected;

  const PatternOption({
    super.key,
    required this.element,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  State<PatternOption> createState() => _PatternOptionState();
}

class _PatternOptionState extends State<PatternOption>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: widget.isSelected
                ? Border.all(color: Colors.green, width: 3)
                : Border.all(color: Colors.grey[300]!, width: 2),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: PatternTile(element: widget.element, size: 80),
        ),
      ),
    );
  }
}
