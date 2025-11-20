import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/colors.dart';
import '../../../../shared/services/analytics_service.dart';
import '../../../../shared/widgets/fancy_button.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../providers/avatar_provider.dart';
import '../../providers/customization_provider.dart';
import '../widgets/avatar_preview.dart';
import '../widgets/category_selector.dart';
import '../widgets/customization_item_card.dart';

/// Screen for customizing the player's avatar
class AvatarCustomizationScreen extends ConsumerStatefulWidget {
  const AvatarCustomizationScreen({super.key});

  @override
  ConsumerState<AvatarCustomizationScreen> createState() =>
      _AvatarCustomizationScreenState();
}

class _AvatarCustomizationScreenState
    extends ConsumerState<AvatarCustomizationScreen> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final inventory = ref.watch(customizationInventoryProvider);
    final categoryItems = inventory
        .where((item) => item.category == selectedCategory)
        .toList();

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button
              _buildHeader(context),

              // Avatar preview section
              _buildAvatarPreviewSection(),

              const SizedBox(height: 16),

              // Category selector
              const CategorySelector(),

              const SizedBox(height: 16),

              // Items grid
              Expanded(child: _buildItemsGrid(categoryItems)),

              // Save button
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
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          const Text(
            'Customize Avatar',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPreviewSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Center(
        child: AvatarPreview(size: 180, showBackground: true),
      ),
    );
  }

  Widget _buildItemsGrid(List items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: 16),
            Text(
              'No items in this category yet',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
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
    if (!isUnlocked) {
      // Show unlock dialog or message
      _showUnlockDialog(itemId);
      return;
    }

    // Select the item
    ref.read(selectedItemProvider.notifier).selectItem(itemId);

    // Equip the item immediately
    ref.read(avatarNotifierProvider.notifier).equipItem(itemId);

    // Track avatar customization event
    final item = ref
        .read(customizationInventoryProvider)
        .firstWhere((item) => item.id == itemId);
    AnalyticsService.instance.logAvatarCustomization(
      itemType: item.category.toString(),
      itemId: itemId,
    );
  }

  void _showUnlockDialog(String itemId) {
    final item = ref
        .read(customizationInventoryProvider)
        .firstWhere((item) => item.id == itemId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Unlock Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Unlock "${item.name}" for ${item.unlockCost} stars?',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              item.description,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _unlockItem(itemId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Unlock'),
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item unlocked!'),
            backgroundColor: AppColors.successGreen,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to unlock item: $e'),
            backgroundColor: AppColors.errorRed,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Widget _buildSaveButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: FancyButton(
        text: _isSaving ? 'Saving...' : 'Save & Exit',
        onPressed: _isSaving ? () {} : _handleSave,
        gradient: AppColors.buttonSuccessGradient,
      ),
    );
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);

    try {
      // Avatar is already saved when items are equipped
      // Just show success message and navigate back
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avatar saved successfully!'),
            backgroundColor: AppColors.successGreen,
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save avatar: $e'),
            backgroundColor: AppColors.errorRed,
            duration: const Duration(seconds: 2),
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
