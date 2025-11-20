import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';

/// FancyCard is a reusable card widget with rounded corners and elevation
/// Provides a professional and child-friendly container for content
class FancyCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final Gradient? gradient;
  final double? width;
  final double? height;
  final double borderRadius;
  final double elevation;
  final VoidCallback? onTap;
  final Border? border;

  const FancyCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.gradient,
    this.width,
    this.height,
    this.borderRadius = 24,
    this.elevation = 4,
    this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: gradient == null
            ? (backgroundColor ?? AppColors.cardBackground)
            : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: elevation * 4,
            offset: Offset(0, elevation),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Container(
        margin: margin,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            child: cardContent,
          ),
        ),
      );
    }

    return Container(margin: margin, child: cardContent);
  }
}

/// AnimatedFancyCard provides a card with scale animation on press
class AnimatedFancyCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final Gradient? gradient;
  final double? width;
  final double? height;
  final double borderRadius;
  final double elevation;
  final VoidCallback? onTap;
  final Border? border;

  const AnimatedFancyCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.gradient,
    this.width,
    this.height,
    this.borderRadius = 24,
    this.elevation = 4,
    this.onTap,
    this.border,
  });

  @override
  State<AnimatedFancyCard> createState() => _AnimatedFancyCardState();
}

class _AnimatedFancyCardState extends State<AnimatedFancyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _controller.reverse();
      widget.onTap!();
    }
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FancyCard(
          padding: widget.padding,
          margin: widget.margin,
          backgroundColor: widget.backgroundColor,
          gradient: widget.gradient,
          width: widget.width,
          height: widget.height,
          borderRadius: widget.borderRadius,
          elevation: widget.elevation,
          border: widget.border,
          child: widget.child,
        ),
      ),
    );
  }
}
