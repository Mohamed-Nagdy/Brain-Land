import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/colors.dart';
import '../../../../shared/models/avatar.dart';
import '../../providers/customization_provider.dart';

/// Child-friendly emoji-based customization item card
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
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) => _controller.reverse());
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isEquipped = ref.watch(isItemEquippedProvider(widget.item.id));

    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: _getGradient(),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _getBorderColor(isEquipped), width: 3),
            boxShadow: [
              BoxShadow(
                color: _getBorderColor(isEquipped).withValues(alpha: 0.4),
                blurRadius: widget.isSelected ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Main content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Big emoji
                    Expanded(
                      child: Center(
                        child: Text(
                          widget.item.emoji,
                          style: TextStyle(
                            fontSize: widget.isSelected ? 56 : 48,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Item name
                    Text(
                      widget.item.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: widget.item.isUnlocked
                            ? Colors.white
                            : Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Cost (if locked)
                    if (!widget.item.isUnlocked) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🪙', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.item.unlockCost}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
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
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🔒', style: TextStyle(fontSize: 40)),
                          SizedBox(height: 4),
                          Text(
                            'Locked',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Equipped checkmark
              if (isEquipped && widget.item.isUnlocked)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.successGreen.withValues(alpha: 0.6),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      '✓',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // Selection glow
              if (widget.isSelected)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.8),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Text('⭐', style: TextStyle(fontSize: 16)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  LinearGradient _getGradient() {
    if (!widget.item.isUnlocked) {
      // Locked - gray gradient
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.grey.shade600, Colors.grey.shade800],
      );
    }

    if (widget.isSelected) {
      // Selected - rainbow gradient
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFF6B9D),
          Color(0xFFFFC371),
          Color(0xFFFFF200),
          Color(0xFF00F5FF),
          Color(0xFFB06AB3),
        ],
      );
    }

    // Unlocked - pastel gradient based on category
    switch (widget.item.category) {
      case ItemCategory.hat:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFB6C1), Color(0xFFFF69B4)], // Pink
        );
      case ItemCategory.clothing:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF87CEEB), Color(0xFF4682B4)], // Blue
        );
      case ItemCategory.eyes:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF98FB98), Color(0xFF3CB371)], // Green
        );
      case ItemCategory.background:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)], // Gold
        );
    }
  }

  Color _getBorderColor(bool isEquipped) {
    if (widget.isSelected) {
      return Colors.white;
    }
    if (isEquipped) {
      return AppColors.successGreen;
    }
    if (!widget.item.isUnlocked) {
      return Colors.grey.shade700;
    }
    return Colors.white.withValues(alpha: 0.5);
  }
}
