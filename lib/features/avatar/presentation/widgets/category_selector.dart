import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/avatar.dart';
import '../../providers/customization_provider.dart';

/// Super colorful emoji-based category selector for kids!
class CategorySelector extends ConsumerWidget {
  const CategorySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Container(
      height: 110, // Increased from 100 to prevent overflow
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.8),
            Colors.white.withValues(alpha: 0.4),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: -10.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) => _controller.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              0,
              _bounceAnimation.value * (widget.isSelected ? 1 : 0),
            ),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Emoji with background
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: widget.isSelected
                          ? _getSelectedGradient(widget.category)
                          : LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.grey.shade300,
                                Colors.grey.shade400,
                              ],
                            ),
                      shape: BoxShape.circle,
                      boxShadow: widget.isSelected
                          ? [
                              BoxShadow(
                                color: _getGlowColor(
                                  widget.category,
                                ).withValues(alpha: 0.6),
                                blurRadius: 16,
                                spreadRadius: 3,
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                      border: Border.all(
                        color: widget.isSelected
                            ? Colors.white
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _getCategoryEmoji(widget.category),
                        style: TextStyle(
                          fontSize: widget.isSelected ? 32 : 28,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4), // Reduced from 6
                  // Category name
                  Text(
                    _getCategoryName(widget.category),
                    style: TextStyle(
                      fontSize: 10, // Reduced from 11
                      fontWeight: widget.isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                      color: widget.isSelected
                          ? _getGlowColor(widget.category)
                          : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getCategoryEmoji(ItemCategory category) {
    switch (category) {
      case ItemCategory.hat:
        return '🎩';
      case ItemCategory.clothing:
        return '👕';
      case ItemCategory.eyes:
        return '👁️';
      case ItemCategory.background:
        return '🎨';
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

  LinearGradient _getSelectedGradient(ItemCategory category) {
    switch (category) {
      case ItemCategory.hat:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6B9D), Color(0xFFFF1493)], // Pink
        );
      case ItemCategory.clothing:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4FC3F7), Color(0xFF0288D1)], // Blue
        );
      case ItemCategory.eyes:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF81C784), Color(0xFF388E3C)], // Green
        );
      case ItemCategory.background:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD54F), Color(0xFFFFA000)], // Gold
        );
    }
  }

  Color _getGlowColor(ItemCategory category) {
    switch (category) {
      case ItemCategory.hat:
        return const Color(0xFFFF1493);
      case ItemCategory.clothing:
        return const Color(0xFF0288D1);
      case ItemCategory.eyes:
        return const Color(0xFF388E3C);
      case ItemCategory.background:
        return const Color(0xFFFFA000);
    }
  }
}
