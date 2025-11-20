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

  /// Get the default inventory with emoji-based items
  List<CustomizationItem> _getDefaultInventory() {
    return [
      // ========== HATS (15 items) ==========
      const CustomizationItem(
        id: 'hat_cap',
        name: 'Baseball Cap',
        description: 'A sporty cap for adventures!',
        category: ItemCategory.hat,
        emoji: '🧢',
        isUnlocked: true,
        unlockCost: 0,
      ),
      const CustomizationItem(
        id: 'hat_crown',
        name: 'Royal Crown',
        description: 'Fit for a king or queen!',
        category: ItemCategory.hat,
        emoji: '👑',
        isUnlocked: false,
        unlockCost: 150,
      ),
      const CustomizationItem(
        id: 'hat_tophat',
        name: 'Top Hat',
        description: 'Cl class and style!',
        category: ItemCategory.hat,
        emoji: '🎩',
        isUnlocked: false,
        unlockCost: 100,
      ),
      const CustomizationItem(
        id: 'hat_grad',
        name: 'Graduation Cap',
        description: 'Smart learner hat!',
        category: ItemCategory.hat,
        emoji: '🎓',
        isUnlocked: false,
        unlockCost: 75,
      ),
      const CustomizationItem(
        id: 'hat_santa',
        name: 'Santa Hat',
        description: 'Ho ho ho!',
        category: ItemCategory.hat,
        emoji: '🎅',
        isUnlocked: false,
        unlockCost: 120,
      ),
      const CustomizationItem(
        id: 'hat_cowboy',
        name: 'Cowboy Hat',
        description: 'Yeehaw, partner!',
        category: ItemCategory.hat,
        emoji: '🤠',
        isUnlocked: false,
        unlockCost: 90,
      ),
      const CustomizationItem(
        id: 'hat_chef',
        name: 'Chef Hat',
        description: 'Master chef in action!',
        category: ItemCategory.hat,
        emoji: '👨‍🍳',
        isUnlocked: false,
        unlockCost: 85,
      ),
      const CustomizationItem(
        id: 'hat_wizard',
        name: 'Wizard Hat',
        description: 'Magical powers!',
        category: ItemCategory.hat,
        emoji: '🧙',
        isUnlocked: false,
        unlockCost: 130,
      ),
      const CustomizationItem(
        id: 'hat_party',
        name: 'Party Hat',
        description: 'Time to celebrate!',
        category: ItemCategory.hat,
        emoji: '🎉',
        isUnlocked: false,
        unlockCost: 60,
      ),
      const CustomizationItem(
        id: 'hat_detective',
        name: 'Detective Hat',
        description: 'Solve the mystery!',
        category: ItemCategory.hat,
        emoji: '🕵️',
        isUnlocked: false,
        unlockCost: 95,
      ),
      const CustomizationItem(
        id: 'hat_pirate',
        name: 'Pirate Hat',
        description: 'Ahoy, matey!',
        category: ItemCategory.hat,
        emoji: '🏴‍☠️',
        isUnlocked: false,
        unlockCost: 110,
      ),
      const CustomizationItem(
        id: 'hat_ninja',
        name: 'Ninja Headband',
        description: 'Stealthy and cool!',
        category: ItemCategory.hat,
        emoji: '🥷',
        isUnlocked: false,
        unlockCost: 105,
      ),
      const CustomizationItem(
        id: 'hat_princess',
        name: 'Princess Tiara',
        description: 'Sparkly and beautiful!',
        category: ItemCategory.hat,
        emoji: '💍',
        isUnlocked: false,
        unlockCost: 140,
      ),
      const CustomizationItem(
        id: 'hat_astronaut',
        name: 'Space Helmet',
        description: 'To infinity and beyond!',
        category: ItemCategory.hat,
        emoji: '👨‍🚀',
        isUnlocked: false,
        unlockCost: 160,
      ),
      const CustomizationItem(
        id: 'hat_flower',
        name: 'Flower Crown',
        description: 'Fresh and pretty!',
        category: ItemCategory.hat,
        emoji: '🌸',
        isUnlocked: false,
        unlockCost: 70,
      ),

      // ========== CLOTHING (12 items) ==========
      const CustomizationItem(
        id: 'cloth_tshirt',
        name: 'T-Shirt',
        description: 'Comfy casual wear!',
        category: ItemCategory.clothing,
        emoji: '👕',
        isUnlocked: true,
        unlockCost: 0,
      ),
      const CustomizationItem(
        id: 'cloth_dress',
        name: 'Pretty Dress',
        description: 'Look fabulous!',
        category: ItemCategory.clothing,
        emoji: '👗',
        isUnlocked: false,
        unlockCost: 90,
      ),
      const CustomizationItem(
        id: 'cloth_suit',
        name: 'Fancy Suit',
        description: 'Dress to impress!',
        category: ItemCategory.clothing,
        emoji: '🤵',
        isUnlocked: false,
        unlockCost: 120,
      ),
      const CustomizationItem(
        id: 'cloth_kimono',
        name: 'Kimono',
        description: 'Traditional elegance!',
        category: ItemCategory.clothing,
        emoji: '👘',
        isUnlocked: false,
        unlockCost: 110,
      ),
      const CustomizationItem(
        id: 'cloth_superhero',
        name: 'Superhero Cape',
        description: 'Hero time!',
        category: ItemCategory.clothing,
        emoji: '🦸',
        isUnlocked: false,
        unlockCost: 130,
      ),
      const CustomizationItem(
        id: 'cloth_vest',
        name: 'Safety Vest',
        description: 'Stay safe and visible!',
        category: ItemCategory.clothing,
        emoji: '🦺',
        isUnlocked: false,
        unlockCost: 65,
      ),
      const CustomizationItem(
        id: 'cloth_jacket',
        name: 'Cool Jacket',
        description: 'Looking stylish!',
        category: ItemCategory.clothing,
        emoji: '🧥',
        isUnlocked: false,
        unlockCost: 85,
      ),
      const CustomizationItem(
        id: 'cloth_shirt_tie',
        name: 'Shirt & Tie',
        description: 'Professional look!',
        category: ItemCategory.clothing,
        emoji: '👔',
        isUnlocked: false,
        unlockCost: 95,
      ),
      const CustomizationItem(
        id: 'cloth_sports',
        name: 'Sports Jersey',
        description: 'Ready to play!',
        category: ItemCategory.clothing,
        emoji: '⚽',
        isUnlocked: false,
        unlockCost: 75,
      ),
      const CustomizationItem(
        id: 'cloth_rainbow',
        name: 'Rainbow Shirt',
        description: 'Colorful and bright!',
        category: ItemCategory.clothing,
        emoji: '🌈',
        isUnlocked: false,
        unlockCost: 100,
      ),
      const CustomizationItem(
        id: 'cloth_winter',
        name: 'Winter Coat',
        description: 'Warm and cozy!',
        category: ItemCategory.clothing,
        emoji: '🧣',
        isUnlocked: false,
        unlockCost: 80,
      ),
      const CustomizationItem(
        id: 'cloth_artist',
        name: 'Artist Smock',
        description: 'Creative and messy!',
        category: ItemCategory.clothing,
        emoji: '🎨',
        isUnlocked: false,
        unlockCost: 70,
      ),

      // ========== EYES (10 items) ==========
      const CustomizationItem(
        id: 'eyes_happy',
        name: 'Happy Eyes',
        description: 'Always smiling!',
        category: ItemCategory.eyes,
        emoji: '😊',
        isUnlocked: true,
        unlockCost: 0,
      ),
      const CustomizationItem(
        id: 'eyes_cool',
        name: 'Cool Shades',
        description: 'Too cool for school!',
        category: ItemCategory.eyes,
        emoji: '😎',
        isUnlocked: false,
        unlockCost: 85,
      ),
      const CustomizationItem(
        id: 'eyes_nerd',
        name: 'Smart Glasses',
        description: 'Brainy look!',
        category: ItemCategory.eyes,
        emoji: '🤓',
        isUnlocked: false,
        unlockCost: 60,
      ),
      const CustomizationItem(
        id: 'eyes_party',
        name: 'Party Eyes',
        description: 'Let\'s celebrate!',
        category: ItemCategory.eyes,
        emoji: '🥳',
        isUnlocked: false,
        unlockCost: 75,
      ),
      const CustomizationItem(
        id: 'eyes_love',
        name: 'Heart Eyes',
        description: 'Full of love!',
        category: ItemCategory.eyes,
        emoji: '😍',
        isUnlocked: false,
        unlockCost: 90,
      ),
      const CustomizationItem(
        id: 'eyes_think',
        name: 'Thinking Eyes',
        description: 'Deep in thought!',
        category: ItemCategory.eyes,
        emoji: '🤔',
        isUnlocked: false,
        unlockCost: 65,
      ),
      const CustomizationItem(
        id: 'eyes_star',
        name: 'Star Eyes',
        description: 'Starstruck!',
        category: ItemCategory.eyes,
        emoji: '🤩',
        isUnlocked: false,
        unlockCost: 95,
      ),
      const CustomizationItem(
        id: 'eyes_wink',
        name: 'Wink',
        description: 'Playful wink!',
        category: ItemCategory.eyes,
        emoji: '😉',
        isUnlocked: false,
        unlockCost: 55,
      ),
      const CustomizationItem(
        id: 'eyes_sleepy',
        name: 'Sleepy Eyes',
        description: 'Time for a nap!',
        category: ItemCategory.eyes,
        emoji: '😴',
        isUnlocked: false,
        unlockCost: 50,
      ),
      const CustomizationItem(
        id: 'eyes_robot',
        name: 'Robot Eyes',
        description: 'Beep boop!',
        category: ItemCategory.eyes,
        emoji: '🤖',
        isUnlocked: false,
        unlockCost: 110,
      ),

      // ========== BACKGROUNDS (15 items) ==========
      const CustomizationItem(
        id: 'bg_forest',
        name: 'Forest',
        description: 'Peaceful trees!',
        category: ItemCategory.background,
        emoji: '🌲',
        isUnlocked: true,
        unlockCost: 0,
      ),
      const CustomizationItem(
        id: 'bg_beach',
        name: 'Beach',
        description: 'Sunny paradise!',
        category: ItemCategory.background,
        emoji: '🏖️',
        isUnlocked: false,
        unlockCost: 100,
      ),
      const CustomizationItem(
        id: 'bg_space',
        name: 'Space',
        description: 'Among the stars!',
        category: ItemCategory.background,
        emoji: '🌌',
        isUnlocked: false,
        unlockCost: 150,
      ),
      const CustomizationItem(
        id: 'bg_castle',
        name: 'Castle',
        description: 'Medieval fortress!',
        category: ItemCategory.background,
        emoji: '🏰',
        isUnlocked: false,
        unlockCost: 130,
      ),
      const CustomizationItem(
        id: 'bg_circus',
        name: 'Circus',
        description: 'Big top fun!',
        category: ItemCategory.background,
        emoji: '🎪',
        isUnlocked: false,
        unlockCost: 120,
      ),
      const CustomizationItem(
        id: 'bg_rainbow',
        name: 'Rainbow',
        description: 'Colors everywhere!',
        category: ItemCategory.background,
        emoji: '🌈',
        isUnlocked: false,
        unlockCost: 110,
      ),
      const CustomizationItem(
        id: 'bg_city',
        name: 'City',
        description: 'Urban jungle!',
        category: ItemCategory.background,
        emoji: '🏙️',
        isUnlocked: false,
        unlockCost: 90,
      ),
      const CustomizationItem(
        id: 'bg_mountain',
        name: 'Mountain',
        description: 'Peaks and valleys!',
        category: ItemCategory.background,
        emoji: '⛰️',
        isUnlocked: false,
        unlockCost: 95,
      ),
      const CustomizationItem(
        id: 'bg_farm',
        name: 'Farm',
        description: 'Country life!',
        category: ItemCategory.background,
        emoji: '🚜',
        isUnlocked: false,
        unlockCost: 80,
      ),
      const CustomizationItem(
        id: 'bg_desert',
        name: 'Desert',
        description: 'Hot and sandy!',
        category: ItemCategory.background,
        emoji: '🏜️',
        isUnlocked: false,
        unlockCost: 85,
      ),
      const CustomizationItem(
        id: 'bg_underwater',
        name: 'Underwater',
        description: 'Deep sea adventure!',
        category: ItemCategory.background,
        emoji: '🐠',
        isUnlocked: false,
        unlockCost: 125,
      ),
      const CustomizationItem(
        id: 'bg_volcano',
        name: 'Volcano',
        description: 'Hot lava flow!',
        category: ItemCategory.background,
        emoji: '🌋',
        isUnlocked: false,
        unlockCost: 140,
      ),
      const CustomizationItem(
        id: 'bg_garden',
        name: 'Garden',
        description: 'Flowers bloom!',
        category: ItemCategory.background,
        emoji: '🌻',
        isUnlocked: false,
        unlockCost: 70,
      ),
      const CustomizationItem(
        id: 'bg_ice',
        name: 'Ice Land',
        description: 'Frozen wonderland!',
        category: ItemCategory.background,
        emoji: '❄️',
        isUnlocked: false,
        unlockCost: 105,
      ),
      const CustomizationItem(
        id: 'bg_candy',
        name: 'Candy Land',
        description: 'Sweet treats!',
        category: ItemCategory.background,
        emoji: '🍭',
        isUnlocked: false,
        unlockCost: 115,
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
