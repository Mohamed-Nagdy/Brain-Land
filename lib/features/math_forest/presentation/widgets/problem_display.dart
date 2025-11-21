import 'package:flutter/material.dart';

import '../../../../core/constants/animations.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../models/math_problem.dart';

/// A widget that displays a math problem with large, clear text
/// Features:
/// - Large, child-friendly typography
/// - Animated appearance (fade in + slide up)
/// - Clear visual hierarchy
/// - Accessible for children aged 5-11
class ProblemDisplay extends StatefulWidget {
  final MathProblem problem;
  final Color? textColor;

  const ProblemDisplay({super.key, required this.problem, this.textColor});

  @override
  State<ProblemDisplay> createState() => _ProblemDisplayState();
}

class _ProblemDisplayState extends State<ProblemDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AnimationConstants.normal,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AnimationConstants.gentle),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: AnimationConstants.smooth,
          ),
        );

    // Start animation when widget is built
    _controller.forward();
  }

  @override
  void didUpdateWidget(ProblemDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Restart animation when problem changes
    if (oldWidget.problem.id != widget.problem.id) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Problem text
            Text(
              widget.problem.getQuestion(),
              style: AppTextStyles.gameNumberLarge.copyWith(
                color: widget.textColor ?? Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Difficulty indicator (optional visual feedback)
            _buildDifficultyIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyIndicator() {
    // Show subtle difficulty indicator for older children
    if (widget.problem.difficulty <= 2) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.problem.difficulty.clamp(1, 5),
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}

/// A simplified version of ProblemDisplay for compact layouts
class CompactProblemDisplay extends StatelessWidget {
  final MathProblem problem;
  final Color? textColor;

  const CompactProblemDisplay({
    super.key,
    required this.problem,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      problem.getQuestion(),
      style: AppTextStyles.gameNumber.copyWith(
        color: textColor ?? AppColors.textPrimary,
      ),
      textAlign: TextAlign.center,
    );
  }
}
