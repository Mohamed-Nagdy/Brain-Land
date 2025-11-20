import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../shared/models/avatar.dart';
import '../../../shared/services/storage_service.dart';

/// Service for managing avatar data persistence
class AvatarStorageService {
  final StorageService _storageService;

  AvatarStorageService({StorageService? storageService})
    : _storageService = storageService ?? StorageService.instance;

  static const String _avatarKey = 'current_avatar';
  static const String _inventoryKey = 'customization_inventory';

  /// Save the current avatar configuration
  Future<void> saveAvatar(Avatar avatar) async {
    try {
      await _storageService.save(
        boxName: AppConstants.avatarBoxName,
        key: _avatarKey,
        value: avatar,
      );
    } catch (e, stackTrace) {
      throw StorageException(
        message: 'Failed to save avatar: $e',
        severity: ErrorSeverity.high,
        stackTrace: stackTrace,
      );
    }
  }

  /// Load the current avatar configuration
  Avatar? loadAvatar() {
    try {
      return _storageService.load<Avatar>(
        boxName: AppConstants.avatarBoxName,
        key: _avatarKey,
      );
    } catch (e, stackTrace) {
      throw StorageException(
        message: 'Failed to load avatar: $e',
        severity: ErrorSeverity.medium,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get the default avatar for new players
  Avatar getDefaultAvatar() {
    return const Avatar(id: 'default_avatar', baseType: AvatarType.panda);
  }

  /// Save the customization inventory
  Future<void> saveInventory(List<CustomizationItem> items) async {
    try {
      await _storageService.save(
        boxName: AppConstants.avatarBoxName,
        key: _inventoryKey,
        value: items,
      );
    } catch (e, stackTrace) {
      throw StorageException(
        message: 'Failed to save inventory: $e',
        severity: ErrorSeverity.high,
        stackTrace: stackTrace,
      );
    }
  }

  /// Load the customization inventory
  List<CustomizationItem> loadInventory() {
    try {
      final items = _storageService.load<List>(
        boxName: AppConstants.avatarBoxName,
        key: _inventoryKey,
      );

      if (items == null) {
        return _getDefaultInventory();
      }

      return items.cast<CustomizationItem>();
    } catch (e, stackTrace) {
      throw StorageException(
        message: 'Failed to load inventory: $e',
        severity: ErrorSeverity.medium,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get the default inventory with some starter items
  List<CustomizationItem> _getDefaultInventory() {
    return [
      // Default hats
      const CustomizationItem(
        id: 'hat_basic_red',
        name: 'Red Cap',
        description: 'A simple red cap',
        category: ItemCategory.hat,
        iconPath: 'assets/items/hats/red_cap.png',
        isUnlocked: true,
        unlockCost: 0,
      ),
      const CustomizationItem(
        id: 'hat_basic_blue',
        name: 'Blue Cap',
        description: 'A simple blue cap',
        category: ItemCategory.hat,
        iconPath: 'assets/items/hats/blue_cap.png',
        isUnlocked: false,
        unlockCost: 50,
      ),

      // Default clothing
      const CustomizationItem(
        id: 'clothing_basic_shirt',
        name: 'Basic Shirt',
        description: 'A comfortable shirt',
        category: ItemCategory.clothing,
        iconPath: 'assets/items/clothing/basic_shirt.png',
        isUnlocked: true,
        unlockCost: 0,
      ),
      const CustomizationItem(
        id: 'clothing_cool_jacket',
        name: 'Cool Jacket',
        description: 'A stylish jacket',
        category: ItemCategory.clothing,
        iconPath: 'assets/items/clothing/cool_jacket.png',
        isUnlocked: false,
        unlockCost: 100,
      ),

      // Default eyes
      const CustomizationItem(
        id: 'eyes_normal',
        name: 'Normal Eyes',
        description: 'Regular eyes',
        category: ItemCategory.eyes,
        iconPath: 'assets/items/eyes/normal.png',
        isUnlocked: true,
        unlockCost: 0,
      ),
      const CustomizationItem(
        id: 'eyes_sparkle',
        name: 'Sparkle Eyes',
        description: 'Eyes that sparkle',
        category: ItemCategory.eyes,
        iconPath: 'assets/items/eyes/sparkle.png',
        isUnlocked: false,
        unlockCost: 75,
      ),

      // Default backgrounds
      const CustomizationItem(
        id: 'bg_forest',
        name: 'Forest',
        description: 'A peaceful forest',
        category: ItemCategory.background,
        iconPath: 'assets/items/backgrounds/forest.png',
        isUnlocked: true,
        unlockCost: 0,
      ),
      const CustomizationItem(
        id: 'bg_space',
        name: 'Space',
        description: 'The vast cosmos',
        category: ItemCategory.background,
        iconPath: 'assets/items/backgrounds/space.png',
        isUnlocked: false,
        unlockCost: 150,
      ),
    ];
  }

  /// Unlock a customization item
  Future<void> unlockItem(String itemId) async {
    try {
      final inventory = loadInventory();
      final itemIndex = inventory.indexWhere((item) => item.id == itemId);

      if (itemIndex == -1) {
        throw StorageException(
          message: 'Item not found: $itemId',
          severity: ErrorSeverity.medium,
        );
      }

      final item = inventory[itemIndex];
      if (item.isUnlocked) {
        return; // Already unlocked
      }

      final unlockedItem = item.copyWith(isUnlocked: true);
      inventory[itemIndex] = unlockedItem;

      await saveInventory(inventory);
    } catch (e, stackTrace) {
      throw StorageException(
        message: 'Failed to unlock item: $e',
        severity: ErrorSeverity.medium,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get all unlocked items
  List<CustomizationItem> getUnlockedItems() {
    final inventory = loadInventory();
    return inventory.where((item) => item.isUnlocked).toList();
  }

  /// Get items by category
  List<CustomizationItem> getItemsByCategory(ItemCategory category) {
    final inventory = loadInventory();
    return inventory.where((item) => item.category == category).toList();
  }

  /// Equip an item to the avatar
  Future<void> equipItem(String itemId) async {
    try {
      final avatar = loadAvatar() ?? getDefaultAvatar();
      final inventory = loadInventory();

      final item = inventory.firstWhere(
        (item) => item.id == itemId,
        orElse: () => throw StorageException(
          message: 'Item not found: $itemId',
          severity: ErrorSeverity.medium,
        ),
      );

      if (!item.isUnlocked) {
        throw StorageException(
          message: 'Cannot equip locked item: $itemId',
          severity: ErrorSeverity.medium,
        );
      }

      Avatar updatedAvatar;
      switch (item.category) {
        case ItemCategory.hat:
          updatedAvatar = avatar.copyWith(equippedHat: itemId);
          break;
        case ItemCategory.clothing:
          updatedAvatar = avatar.copyWith(equippedClothing: itemId);
          break;
        case ItemCategory.eyes:
          updatedAvatar = avatar.copyWith(equippedEyes: itemId);
          break;
        case ItemCategory.background:
          updatedAvatar = avatar.copyWith(background: itemId);
          break;
      }

      await saveAvatar(updatedAvatar);
    } catch (e, stackTrace) {
      throw StorageException(
        message: 'Failed to equip item: $e',
        severity: ErrorSeverity.medium,
        stackTrace: stackTrace,
      );
    }
  }

  /// Unequip an item from the avatar
  Future<void> unequipItem(ItemCategory category) async {
    try {
      final avatar = loadAvatar() ?? getDefaultAvatar();

      // Create a new avatar with the item unequipped
      // We need to explicitly create a new Avatar instead of using copyWith
      // because copyWith doesn't properly handle setting values to null
      Avatar updatedAvatar;
      switch (category) {
        case ItemCategory.hat:
          updatedAvatar = Avatar(
            id: avatar.id,
            baseType: avatar.baseType,
            equippedHat: null,
            equippedClothing: avatar.equippedClothing,
            equippedEyes: avatar.equippedEyes,
            background: avatar.background,
            companionPet: avatar.companionPet,
          );
          break;
        case ItemCategory.clothing:
          updatedAvatar = Avatar(
            id: avatar.id,
            baseType: avatar.baseType,
            equippedHat: avatar.equippedHat,
            equippedClothing: null,
            equippedEyes: avatar.equippedEyes,
            background: avatar.background,
            companionPet: avatar.companionPet,
          );
          break;
        case ItemCategory.eyes:
          updatedAvatar = Avatar(
            id: avatar.id,
            baseType: avatar.baseType,
            equippedHat: avatar.equippedHat,
            equippedClothing: avatar.equippedClothing,
            equippedEyes: null,
            background: avatar.background,
            companionPet: avatar.companionPet,
          );
          break;
        case ItemCategory.background:
          updatedAvatar = Avatar(
            id: avatar.id,
            baseType: avatar.baseType,
            equippedHat: avatar.equippedHat,
            equippedClothing: avatar.equippedClothing,
            equippedEyes: avatar.equippedEyes,
            background: null,
            companionPet: avatar.companionPet,
          );
          break;
      }

      await saveAvatar(updatedAvatar);
    } catch (e, stackTrace) {
      throw StorageException(
        message: 'Failed to unequip item: $e',
        severity: ErrorSeverity.medium,
        stackTrace: stackTrace,
      );
    }
  }

  /// Clear all avatar data (for testing or reset)
  Future<void> clearAvatarData() async {
    try {
      await _storageService.clearBox(AppConstants.avatarBoxName);
    } catch (e, stackTrace) {
      throw StorageException(
        message: 'Failed to clear avatar data: $e',
        severity: ErrorSeverity.medium,
        stackTrace: stackTrace,
      );
    }
  }
}
