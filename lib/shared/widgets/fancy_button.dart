import 'package:brain_land/core/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rippleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rippleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    // Scale animation for press effect
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    // Ripple animation for visual feedback
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      _scaleController.forward();
      _rippleController.forward(from: 0);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      _scaleController.reverse();
      // Play button click sound
      AudioManager.instance.playSound(SoundEffect.buttonClick.path);
    }
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  void _handleHoverEnter(PointerEnterEvent event) {
    setState(() {
      _isHovered = true;
    });
  }

  void _handleHoverExit(PointerExitEvent event) {
    setState(() {
      _isHovered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final gradient = widget.gradient ?? AppColors.buttonPrimaryGradient;
    final isEnabled = widget.onPressed != null;

    // Ensure minimum touch target size for accessibility
    final minHeight = ResponsiveUtils.minTouchTargetSize;
    final effectiveHeight = widget.height ?? minHeight;

    final buttonPadding =
        widget.padding ??
        (widget.isSmall
            ? EdgeInsets.symmetric(
                horizontal: context.responsiveValue(
                  mobile: 16.0,
                  tablet: 24.0,
                  desktop: 28.0,
                ),
                vertical: 8,
              )
            : EdgeInsets.symmetric(
                horizontal: context.responsiveValue(
                  mobile: 24.0,
                  tablet: 32.0,
                  desktop: 40.0,
                ),
                vertical: 12,
              ));

    final textStyle =
        widget.textStyle ??
        (widget.isSmall ? AppTextStyles.buttonSmall : AppTextStyles.button)
            .copyWith(
              fontSize: ResponsiveUtils.responsiveFontSize(
                context,
                mobile: widget.isSmall ? 14 : 18,
                tablet: widget.isSmall ? 16 : 20,
                desktop: widget.isSmall ? 18 : 22,
              ),
            );

    return MouseRegion(
      onEnter: isEnabled ? _handleHoverEnter : null,
      onExit: isEnabled ? _handleHoverExit : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width,
          height: effectiveHeight >= minHeight ? effectiveHeight : minHeight,
          constraints: BoxConstraints(
            minHeight: minHeight,
            minWidth: minHeight,
          ),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(30),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: gradient.colors.first.withValues(
                        alpha: _isHovered ? 0.5 : 0.3,
                      ),
                      blurRadius: _isHovered ? 25 : 20,
                      offset: Offset(0, _isHovered ? 12 : 10),
                    ),
                  ]
                : [],
          ),
          child: Opacity(
            opacity: isEnabled ? 1.0 : 0.5,
            child: Stack(
              children: [
                // Ripple effect overlay
                if (isEnabled)
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _rippleAnimation,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: RipplePainter(
                            progress: _rippleAnimation.value,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        );
                      },
                    ),
                  ),
                // Button content
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onPressed,
                    onTapDown: _handleTapDown,
                    onTapUp: _handleTapUp,
                    onTapCancel: _handleTapCancel,
                    borderRadius: BorderRadius.circular(30),
                    splashColor: Colors.white.withValues(alpha: 0.2),
                    highlightColor: Colors.white.withValues(alpha: 0.1),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// RipplePainter draws an expanding ripple effect
class RipplePainter extends CustomPainter {
  final double progress;
  final Color color;

  RipplePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final paint = Paint()
      ..color = color.withValues(alpha: (1.0 - progress) * 0.3)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width > size.height ? size.width : size.height;
    final radius = maxRadius * progress;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(RipplePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
