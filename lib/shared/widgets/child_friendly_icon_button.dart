import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

/// A child-friendly icon button that enforces minimum touch target sizes
/// 
/// This widget wraps Flutter's IconButton to ensure all interactive elements
/// meet the minimum touch target size requirements for children (48x48 dp).
/// 
/// Usage:
/// ```dart
/// ChildFriendlyIconButton(
///   icon: Icons.close,
///   onPressed: () => Navigator.pop(context),
///   tooltip: 'Close',
/// )
/// ```
class ChildFriendlyIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final double? iconSize;
  final EdgeInsets? padding;
  final BoxConstraints? constraints;

  const ChildFriendlyIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
    this.iconSize,
    this.padding,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure minimum touch target size for children
    final effectiveConstraints = constraints ??
        BoxConstraints(
          minWidth: AppConstants.minTouchTargetSize,
          minHeight: AppConstants.minTouchTargetSize,
        );

    // Default icon size that's easy for children to see
    final effectiveIconSize = iconSize ?? 28.0;

    // Adequate padding for comfortable tapping
    final effectivePadding = padding ?? const EdgeInsets.all(12.0);

    return IconButton(
      icon: Icon(icon, size: effectiveIconSize),
      onPressed: onPressed,
      tooltip: tooltip,
      color: color,
      padding: effectivePadding,
      constraints: effectiveConstraints,
      // Ensure the icon button has a visible tap area
      splashRadius: AppConstants.minTouchTargetSize / 2,
    );
  }
}
