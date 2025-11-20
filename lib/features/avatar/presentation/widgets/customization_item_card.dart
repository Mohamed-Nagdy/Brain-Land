import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/colors.dart';
import '../../../../shared/models/avatar.dart';
import '../../providers/customization_provider.dart';

/// Widget that displays a customization item card
class CustomizationItemCard extends ConsumerStatefulWidget {
  final CustomizationItem item;
  final VoidCallback? onTap;
  final bool isSelected;

  const CustomizationItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.isSelected = false,
  });

  @override
  ConsumerState<CustomizationItemCard> createState() =>
      _CustomizationItemCardState();
}

class _CustomizationItemCardState extends ConsumerState<CustomizationItemCard>
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
    if (widget.item.isUnlocked) {
      setState(() {});
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.item.isUnlocked) {
      setState(() {});
      _controller.reverse();
      widget.onTap?.call();
    }
  }

  void _handleTapCancel() {
    if (widget.item.isUnlocked) {
      setState(() {});
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEquipped = ref.watch(isItemEquippedProvider(widget.item.id));

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.primary
                  : isEquipped
                  ? AppColors.successGreen
                  : Colors.transparent,
              width: widget.isSelected || isEquipped ? 3 : 0,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isSelected
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.1),
                blurRadius: widget.isSelected ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Item content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Item icon/image
                    Expanded(child: _buildItemImage()),
                    const SizedBox(height: 8),
                    // Item name
                    Text(
                      widget.item.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: widget.item.isUnlocked
                            ? AppColors.textPrimary
                            : AppColors.textDisabled,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Cost (if locked)
                    if (!widget.item.isUnlocked) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star, size: 12, color: AppColors.starGold),
                          const SizedBox(width: 2),
                          Text(
                            '${widget.item.unlockCost}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Lock overlay for locked items
              if (!widget.item.isUnlocked)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Icon(Icons.lock, size: 32, color: Colors.white),
                    ),
                  ),
                ),

              // Equipped indicator
              if (isEquipped && widget.item.isUnlocked)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.successGreen.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),

              // Selection indicator
              if (widget.isSelected)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.radio_button_checked,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemImage() {
    if (widget.item.iconPath.isEmpty) {
      return Icon(
        _getCategoryIcon(widget.item.category),
        size: 48,
        color: widget.item.isUnlocked
            ? AppColors.primary
            : AppColors.textDisabled,
      );
    }

    return Image.asset(
      widget.item.iconPath,
      fit: BoxFit.contain,
      color: widget.item.isUnlocked ? null : Colors.grey,
      colorBlendMode: widget.item.isUnlocked ? null : BlendMode.saturation,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          _getCategoryIcon(widget.item.category),
          size: 48,
          color: widget.item.isUnlocked
              ? AppColors.primary
              : AppColors.textDisabled,
        );
      },
    );
  }

  IconData _getCategoryIcon(ItemCategory category) {
    switch (category) {
      case ItemCategory.hat:
        return Icons.sports_baseball;
      case ItemCategory.clothing:
        return Icons.checkroom;
      case ItemCategory.eyes:
        return Icons.visibility;
      case ItemCategory.background:
        return Icons.landscape;
    }
  }
}
