import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/avatar_provider.dart';
import '../../providers/customization_provider.dart';
import '../widgets/avatar_preview.dart';
import '../widgets/category_selector.dart';
import '../widgets/customization_item_card.dart';

/// Super colorful avatar customization screen for kids!
class AvatarCustomizationScreen extends ConsumerStatefulWidget {
  const AvatarCustomizationScreen({super.key});

  @override
  ConsumerState<AvatarCustomizationScreen> createState() =>
      _AvatarCustomizationScreenState();
}

class _AvatarCustomizationScreenState
    extends ConsumerState<AvatarCustomizationScreen>
    with SingleTickerProviderStateMixin {
  bool _isSaving = false;
  late AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final inventory = ref.watch(customizationInventoryProvider);
    final categoryItems = inventory
        .where((item) => item.category == selectedCategory)
        .toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFE5F1), // Pink
              Color(0xFFFFE5B4), // Peach
              Color(0xFFFFFACD), // Yellow
              Color(0xFFE0F2F7), // Cyan
              Color(0xFFF3E5F5), // Purple
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button and title
              _buildHeader(context),

              // Avatar preview with sparkles!
              _buildAvatarPreviewSection(),

              const SizedBox(height: 8),

              // Category tabs
              const CategorySelector(),

              const SizedBox(height: 12),

              // Items grid
              Expanded(child: _buildItemsGrid(categoryItems)),

              // Save button at bottom
              _buildSaveButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Back button
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 12),
          // Title
          const Expanded(
            child: Text(
              'Customize Me! ✨',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                shadows: [
                  Shadow(
                    color: Colors.white,
                    offset: Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          // Coins display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              children: [
                Text('🪙', style: TextStyle(fontSize: 20)),
                SizedBox(width: 6),
                Text(
                  '500',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPreviewSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Sparkles around avatar
          ..._buildSparkles(),

          // Avatar in center
          const AvatarPreview(size: 200, showBackground: true),

          // Top left corner sparkle
          const Positioned(
            top: 10,
            left: 10,
            child: Text('✨', style: TextStyle(fontSize: 24)),
          ),

          // Top right corner sparkle
          const Positioned(
            top: 10,
            right: 10,
            child: Text('⭐', style: TextStyle(fontSize: 24)),
          ),

          // Bottom decoration
          const Positioned(
            bottom: 5,
            child: Text(
              'Your Cool Avatar!',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSparkles() {
    return [
      _buildAnimatedSparkle(30, 50, 0.0),
      _buildAnimatedSparkle(80, 30, 0.3),
      _buildAnimatedSparkle(250, 40, 0.6),
      _buildAnimatedSparkle(280, 80, 0.9),
      _buildAnimatedSparkle(50, 180, 0.4),
      _buildAnimatedSparkle(260, 160, 0.7),
    ];
  }

  Widget _buildAnimatedSparkle(double left, double top, double delay) {
    return Positioned(
      left: left,
      top: top,
      child: AnimatedBuilder(
        animation: _sparkleController,
        builder: (context, child) {
          final value = (_sparkleController.value + delay) % 1.0;
          final opacity = (1 - value).clamp(0.0, 1.0);
          final scale = 0.5 + (value * 0.5);

          return Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: const Text('✨', style: TextStyle(fontSize: 20)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemsGrid(List items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎁', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text(
              'No items here yet!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Keep playing to unlock more!',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final selectedItem = ref.watch(selectedItemProvider);
        final isSelected = selectedItem == item.id;

        return CustomizationItemCard(
          item: item,
          isSelected: isSelected,
          onTap: () => _handleItemTap(item.id, item.isUnlocked),
        );
      },
    );
  }

  void _handleItemTap(String itemId, bool isUnlocked) {
    if (isUnlocked) {
      // Select the item
      ref.read(selectedItemProvider.notifier).selectItem(itemId);

      // Equip it immediately
      ref.read(avatarNotifierProvider.notifier).equipItem(itemId);

      // Track analytics (TODO: Add analytics integration)
      // ref
      //     .read(analyticsProviderProvider)
      //     .logEvent(
      //       name: 'avatar_item_equipped',
      //       parameters: {'item_id': itemId},
      //     );
    } else {
      // Show unlock dialog
      _showUnlockDialog(itemId);
    }
  }

  void _showUnlockDialog(String itemId) {
    final item = ref
        .read(customizationInventoryProvider)
        .firstWhere((item) => item.id == itemId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Text(item.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Unlock ${item.name}?',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(item.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Text(
                    '${item.unlockCost}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => _unlockItem(itemId),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Unlock! 🎉',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _unlockItem(String itemId) async {
    try {
      await ref
          .read(customizationInventoryProvider.notifier)
          .unlockItem(itemId);

      // Close dialog
      if (mounted) {
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Item unlocked!'),
            backgroundColor: Color(0xFF4CAF50),
            duration: Duration(seconds: 2),
          ),
        );

        // Track analytics (TODO: Add analytics integration)
        // ref
        //     .read(analyticsProviderProvider)
        //     .logEvent(
        //       name: 'avatar_item_unlocked',
        //       parameters: {'item_id': itemId},
        //     );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to unlock item: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildSaveButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.white.withValues(alpha: 0.8)],
        ),
      ),
      child: ElevatedButton(
        onPressed: _isSaving ? null : _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9C27B0),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 8,
          shadowColor: Colors.purple.withValues(alpha: 0.5),
        ),
        child: _isSaving
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Save & Done',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '✓',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);

    try {
      // Avatar is already saved automatically when items are equipped
      // Just track analytics and show success message

      // Track analytics (TODO: Add analytics integration)
      // ref
      //     .read(analyticsProviderProvider)
      //     .logEvent(name: 'avatar_customization_completed');

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ Avatar saved successfully!'),
            backgroundColor: Color(0xFF4CAF50),
            duration: Duration(seconds: 2),
          ),
        );

        // Wait a bit then go back
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
