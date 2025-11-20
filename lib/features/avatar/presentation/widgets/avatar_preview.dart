import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/avatar.dart';
import '../../providers/avatar_provider.dart';
import '../../providers/customization_provider.dart';

/// Widget that displays the avatar with all equipped items
class AvatarPreview extends ConsumerWidget {
  final double size;
  final bool showBackground;
  final bool enableInteraction;

  const AvatarPreview({
    super.key,
    this.size = 200,
    this.showBackground = true,
    this.enableInteraction = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatar = ref.watch(avatarNotifierProvider);
    final inventory = ref.watch(customizationInventoryProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background layer
          if (showBackground && avatar.background != null)
            _buildBackgroundLayer(avatar.background!, inventory),

          // Base avatar layer
          _buildBaseAvatarLayer(avatar.baseType),

          // Clothing layer
          if (avatar.equippedClothing != null)
            _buildItemLayer(avatar.equippedClothing!, inventory),

          // Eyes layer
          if (avatar.equippedEyes != null)
            _buildItemLayer(avatar.equippedEyes!, inventory),

          // Hat layer
          if (avatar.equippedHat != null)
            _buildItemLayer(avatar.equippedHat!, inventory),

          // Companion pet (if any)
          if (avatar.companionPet != null) _buildPetLayer(avatar.companionPet!),
        ],
      ),
    );
  }

  Widget _buildBackgroundLayer(
    String backgroundId,
    List<CustomizationItem> inventory,
  ) {
    final item = inventory.firstWhere(
      (item) => item.id == backgroundId,
      orElse: () => const CustomizationItem(
        id: '',
        name: '',
        description: '',
        category: ItemCategory.background,
        iconPath: '',
        isUnlocked: false,
        unlockCost: 0,
      ),
    );

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: 1.0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size / 2),
          image: item.iconPath.isNotEmpty
              ? DecorationImage(
                  image: AssetImage(item.iconPath),
                  fit: BoxFit.cover,
                )
              : null,
          gradient: item.iconPath.isEmpty
              ? LinearGradient(
                  colors: [Colors.blue.shade200, Colors.purple.shade200],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildBaseAvatarLayer(AvatarType baseType) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: Container(
        key: ValueKey(baseType),
        width: size * 0.7,
        height: size * 0.7,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _getBaseAvatarColor(baseType),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            _getBaseAvatarIcon(baseType),
            size: size * 0.4,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildItemLayer(String itemId, List<CustomizationItem> inventory) {
    final item = inventory.firstWhere(
      (item) => item.id == itemId,
      orElse: () => const CustomizationItem(
        id: '',
        name: '',
        description: '',
        category: ItemCategory.hat,
        iconPath: '',
        isUnlocked: false,
        unlockCost: 0,
      ),
    );

    if (item.iconPath.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: 1.0,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 300),
        scale: 1.0,
        child: Image.asset(
          item.iconPath,
          width: size * 0.8,
          height: size * 0.8,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback if image doesn't exist
            return Icon(
              _getCategoryIcon(item.category),
              size: size * 0.3,
              color: Colors.grey.shade400,
            );
          },
        ),
      ),
    );
  }

  Widget _buildPetLayer(String petId) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: size * 0.3,
        height: size * 0.3,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.amber.shade200,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.pets, color: Colors.white),
      ),
    );
  }

  Color _getBaseAvatarColor(AvatarType type) {
    switch (type) {
      case AvatarType.panda:
        return Colors.grey.shade700;
      case AvatarType.robot:
        return Colors.blue.shade400;
      case AvatarType.cat:
        return Colors.orange.shade400;
    }
  }

  IconData _getBaseAvatarIcon(AvatarType type) {
    switch (type) {
      case AvatarType.panda:
        return Icons.face;
      case AvatarType.robot:
        return Icons.smart_toy;
      case AvatarType.cat:
        return Icons.pets;
    }
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
