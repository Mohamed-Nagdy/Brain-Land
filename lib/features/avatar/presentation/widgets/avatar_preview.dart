import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/avatar.dart';
import '../../providers/avatar_provider.dart';
import '../../providers/customization_provider.dart';

/// Emoji-based avatar preview widget showing equipped items
class AvatarPreview extends ConsumerWidget {
  final double size;
  final bool showBackground;
  final bool enableAnimation;

  const AvatarPreview({
    super.key,
    this.size = 200,
    this.showBackground = true,
    this.enableAnimation = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatar = ref.watch(avatarNotifierProvider);
    final inventory = ref.watch(customizationInventoryProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background layer (furthest back)
          if (showBackground && avatar.background != null)
            _buildBackgroundLayer(avatar.background!, inventory),

          // Base avatar (body/face)
          _buildBaseAvatarLayer(avatar.baseType),

          // Clothing layer (on body)
          if (avatar.equippedClothing != null)
            _buildEmojiLayer(
              avatar.equippedClothing!,
              inventory,
              0.4,
              const Offset(0, 20),
            ),

          // Eyes layer (on face)
          if (avatar.equippedEyes != null)
            _buildEmojiLayer(
              avatar.equippedEyes!,
              inventory,
              0.35,
              const Offset(0, -10),
            ),

          // Hat layer (on top)
          if (avatar.equippedHat != null)
            _buildEmojiLayer(
              avatar.equippedHat!,
              inventory,
              0.4,
              const Offset(0, -50),
            ),

          // Companion pet (bottom right corner)
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
        emoji: '🌈', // Default rainbow background
        isUnlocked: false,
        unlockCost: 0,
      ),
    );

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: 0.3,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: _getBackgroundGradient(item.emoji),
        ),
        child: Center(
          child: Text(
            item.emoji,
            style: TextStyle(fontSize: size * 0.8, height: 1.0),
          ),
        ),
      ),
    );
  }

  Widget _buildBaseAvatarLayer(AvatarType baseType) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: animation,
          child: RotationTransition(
            turns: Tween<double>(begin: 0.1, end: 0.0).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(baseType),
        width: size * 0.7,
        height: size * 0.7,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: _getAvatarGradient(baseType),
          boxShadow: [
            BoxShadow(
              color: _getAvatarColor(baseType).withValues(alpha: 0.4),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            _getBaseAvatarEmoji(baseType),
            style: TextStyle(fontSize: size * 0.5, height: 1.0),
          ),
        ),
      ),
    );
  }

  Widget _buildEmojiLayer(
    String itemId,
    List<CustomizationItem> inventory,
    double sizeMultiplier,
    Offset offset,
  ) {
    final item = inventory.firstWhere(
      (item) => item.id == itemId,
      orElse: () => const CustomizationItem(
        id: '',
        name: '',
        description: '',
        category: ItemCategory.hat,
        emoji: '',
        isUnlocked: false,
        unlockCost: 0,
      ),
    );

    if (item.emoji.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      left: (size / 2) + offset.dx - (size * sizeMultiplier / 2),
      top: (size / 2) + offset.dy - (size * sizeMultiplier / 2),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: 1.0,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 400),
          curve: Curves.elasticOut,
          scale: 1.0,
          child: Container(
            width: size * sizeMultiplier,
            height: size * sizeMultiplier,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: Text(
                item.emoji,
                style: TextStyle(
                  fontSize: size * sizeMultiplier * 0.8,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPetLayer(String petId) {
    return Positioned(
      bottom: size * 0.05,
      right: size * 0.05,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.elasticOut,
        width: size * 0.25,
        height: size * 0.25,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF176), Color(0xFFFFD54F)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '🐾', // Pet paw print emoji
            style: TextStyle(fontSize: size * 0.15, height: 1.0),
          ),
        ),
      ),
    );
  }

  /// Get gradient for background based on emoji type
  LinearGradient _getBackgroundGradient(String emoji) {
    // Different backgrounds get different color schemes
    if (emoji.contains('🌲') || emoji.contains('🌳')) {
      return const LinearGradient(
        colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
      );
    } else if (emoji.contains('🏖️')) {
      return const LinearGradient(
        colors: [Color(0xFF03A9F4), Color(0xFF81D4FA)],
      );
    } else if (emoji.contains('🌌') || emoji.contains('🌠')) {
      return const LinearGradient(
        colors: [Color(0xFF1A237E), Color(0xFF5C6BC0)],
      );
    } else {
      return const LinearGradient(
        colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
      );
    }
  }

  /// Get gradient for base avatar
  LinearGradient _getAvatarGradient(AvatarType type) {
    switch (type) {
      case AvatarType.panda:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF757575), Color(0xFFBDBDBD)],
        );
      case AvatarType.robot:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
        );
      case AvatarType.cat:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
        );
    }
  }

  /// Get solid color for avatar shadow
  Color _getAvatarColor(AvatarType type) {
    switch (type) {
      case AvatarType.panda:
        return Colors.grey;
      case AvatarType.robot:
        return Colors.blue;
      case AvatarType.cat:
        return Colors.orange;
    }
  }

  /// Get base emoji for avatar type
  String _getBaseAvatarEmoji(AvatarType type) {
    switch (type) {
      case AvatarType.panda:
        return '🐼';
      case AvatarType.robot:
        return '🤖';
      case AvatarType.cat:
        return '😺';
    }
  }
}
