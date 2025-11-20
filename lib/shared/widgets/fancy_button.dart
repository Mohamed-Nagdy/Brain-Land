import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/audio_manager.dart';

/// FancyButton is a reusable button widget with gradient background and shadow
/// Provides a delightful press animation for children
class FancyButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final TextStyle? textStyle;
  final IconData? icon;
  final bool isSmall;

  const FancyButton({
    super.key,
    required this.text,
    this.onPressed,
    this.gradient,
    this.width,
    this.height,
    this.padding,
    this.textStyle,
    this.icon,
    this.isSmall = false,
  });

  @override
  State<FancyButton> createState() => _FancyButtonState();
}

class _FancyButtonState extends State<FancyButton>
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
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      _controller.reverse();
      // Play button click sound
      AudioManager.instance.playSound(SoundEffect.buttonClick.path);
    }
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = widget.gradient ?? AppColors.buttonPrimaryGradient;
    final isEnabled = widget.onPressed != null;
    final buttonPadding =
        widget.padding ??
        (widget.isSmall
            ? const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
            : const EdgeInsets.symmetric(horizontal: 40, vertical: 16));
    final textStyle =
        widget.textStyle ??
        (widget.isSmall ? AppTextStyles.buttonSmall : AppTextStyles.button);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(30),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: gradient.colors.first.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              borderRadius: BorderRadius.circular(30),
              child: Padding(
                padding: buttonPadding,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: Colors.white,
                        size: widget.isSmall ? 18 : 24,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.text,
                      style: textStyle,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
