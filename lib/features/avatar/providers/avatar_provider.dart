import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/models/avatar.dart';
import '../services/avatar_storage_service.dart';

part 'avatar_provider.g.dart';

/// Provider for the avatar storage service
@riverpod
AvatarStorageService avatarStorageService(AvatarStorageServiceRef ref) {
  return AvatarStorageService();
}

/// Avatar state notifier with code generation
@riverpod
class AvatarNotifier extends _$AvatarNotifier {
  @override
  Avatar build() {
    _loadAvatar();
    return _getDefaultAvatar();
  }

  AvatarStorageService get _service => ref.read(avatarStorageServiceProvider);

  Avatar _getDefaultAvatar() {
    return _service.getDefaultAvatar();
  }

  /// Load avatar from storage
  Future<void> _loadAvatar() async {
    try {
      final avatar = _service.loadAvatar();
      if (avatar != null) {
        state = avatar;
      }
    } catch (e) {
      log('Failed to load avatar: $e');
    }
  }

  /// Save avatar to storage
  Future<void> _saveAvatar() async {
    try {
      await _service.saveAvatar(state);
    } catch (e) {
      log('Failed to save avatar: $e');
    }
  }

  /// Change the base avatar type
  Future<void> changeBaseType(AvatarType baseType) async {
    state = Avatar(
      id: state.id,
      baseType: baseType,
      equippedHat: state.equippedHat,
      equippedClothing: state.equippedClothing,
      equippedEyes: state.equippedEyes,
      background: state.background,
      companionPet: state.companionPet,
    );
    await _saveAvatar();
  }

  /// Equip an item to the avatar
  Future<void> equipItem(String itemId) async {
    try {
      await _service.equipItem(itemId);
      // Reload avatar to reflect changes
      await _loadAvatar();
    } catch (e) {
      log('Failed to equip item: $e');
      rethrow;
    }
  }

  /// Unequip an item from the avatar
  Future<void> unequipItem(ItemCategory category) async {
    try {
      await _service.unequipItem(category);
      // Reload avatar to reflect changes
      await _loadAvatar();
    } catch (e) {
      log('Failed to unequip item: $e');
      rethrow;
    }
  }

  /// Set companion pet
  Future<void> setCompanionPet(String? petId) async {
    state = Avatar(
      id: state.id,
      baseType: state.baseType,
      equippedHat: state.equippedHat,
      equippedClothing: state.equippedClothing,
      equippedEyes: state.equippedEyes,
      background: state.background,
      companionPet: petId,
    );
    await _saveAvatar();
  }

  /// Reset avatar to default
  Future<void> reset() async {
    state = _getDefaultAvatar();
    await _saveAvatar();
  }
}
