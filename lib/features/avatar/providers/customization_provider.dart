import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/models/avatar.dart';
import '../services/avatar_storage_service.dart';
import 'avatar_provider.dart';

part 'customization_provider.g.dart';

/// Customization inventory state notifier
@riverpod
class CustomizationInventory extends _$CustomizationInventory {
  @override
  List<CustomizationItem> build() {
    _loadInventory();
    return [];
  }

  AvatarStorageService get _service => ref.read(avatarStorageServiceProvider);

  /// Load inventory from storage
  Future<void> _loadInventory() async {
    try {
      final inventory = _service.loadInventory();
      state = inventory;
    } catch (e) {
      log('Failed to load inventory: $e');
    }
  }

  /// Unlock an item
  Future<void> unlockItem(String itemId) async {
    try {
      await _service.unlockItem(itemId);
      // Reload inventory to reflect changes
      await _loadInventory();
    } catch (e) {
      log('Failed to unlock item: $e');
      rethrow;
    }
  }

  /// Get all unlocked items
  List<CustomizationItem> getUnlockedItems() {
    return state.where((item) => item.isUnlocked).toList();
  }

  /// Get items by category
  List<CustomizationItem> getItemsByCategory(ItemCategory category) {
    return state.where((item) => item.category == category).toList();
  }

  /// Get unlocked items by category
  List<CustomizationItem> getUnlockedItemsByCategory(ItemCategory category) {
    return state
        .where((item) => item.category == category && item.isUnlocked)
        .toList();
  }

  /// Check if an item is unlocked
  bool isItemUnlocked(String itemId) {
    final item = state.firstWhere(
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
    return item.isUnlocked;
  }

  /// Get item by ID
  CustomizationItem? getItemById(String itemId) {
    try {
      return state.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }

  /// Refresh inventory (reload from storage)
  Future<void> refresh() async {
    await _loadInventory();
  }
}

/// Provider for currently selected category
@riverpod
class SelectedCategory extends _$SelectedCategory {
  @override
  ItemCategory build() {
    return ItemCategory.hat;
  }

  void setCategory(ItemCategory category) {
    state = category;
  }
}

/// Provider for currently selected item in customization screen
@riverpod
class SelectedItem extends _$SelectedItem {
  @override
  String? build() {
    return null;
  }

  void selectItem(String? itemId) {
    state = itemId;
  }

  void clearSelection() {
    state = null;
  }
}

/// Provider for equipped items (derived from avatar)
@riverpod
Map<ItemCategory, String?> equippedItems(EquippedItemsRef ref) {
  final avatar = ref.watch(avatarNotifierProvider);
  return {
    ItemCategory.hat: avatar.equippedHat,
    ItemCategory.clothing: avatar.equippedClothing,
    ItemCategory.eyes: avatar.equippedEyes,
    ItemCategory.background: avatar.background,
  };
}

/// Provider to check if an item is currently equipped
@riverpod
bool isItemEquipped(IsItemEquippedRef ref, String itemId) {
  final equipped = ref.watch(equippedItemsProvider);
  return equipped.values.contains(itemId);
}
