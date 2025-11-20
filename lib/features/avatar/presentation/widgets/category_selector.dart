import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/colors.dart';
import '../../../../shared/models/avatar.dart';
import '../../providers/customization_provider.dart';

/// Widget that displays a tab bar for selecting customization categories
class CategorySelector extends ConsumerWidget {
  const CategorySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: ItemCategory.values.map((category) {
          final isSelected = category == selectedCategory;
          return Expanded(
            child: _CategoryTab(
              category: category,
              isSelected: isSelected,
              onTap: () {
                ref
                    .read(selectedCategoryProvider.notifier)
                    .setCategory(category);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CategoryTab extends StatefulWidget {
  final ItemCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryTab({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_CategoryTab> createState() => _CategoryTabState();
}

class _CategoryTabState extends State<_CategoryTab>
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
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: widget.isSelected
                    ? AppColors.primary
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getCategoryIcon(widget.category),
                  size: 24,
                  color: widget.isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getCategoryName(widget.category),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: widget.isSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: widget.isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
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

  String _getCategoryName(ItemCategory category) {
    switch (category) {
      case ItemCategory.hat:
        return 'Hats';
      case ItemCategory.clothing:
        return 'Clothes';
      case ItemCategory.eyes:
        return 'Eyes';
      case ItemCategory.background:
        return 'Backgrounds';
    }
  }
}
