import 'dart:io';
import 'dart:math';

import 'package:brain_land/core/constants/app_constants.dart';
import 'package:brain_land/features/avatar/services/avatar_storage_service.dart';
import 'package:brain_land/shared/models/avatar.dart';
import 'package:brain_land/shared/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Avatar System Properties', () {
    late StorageService storage;
    late AvatarStorageService avatarService;
    late Directory testDir;

    setUp(() async {
      // Create a temporary directory for testing
      testDir = await Directory.systemTemp.createTemp('hive_test_');

      // Initialize storage with the test directory
      storage = StorageService.instance;
      await storage.initialize(path: testDir.path);

      avatarService = AvatarStorageService(storageService: storage);
    });

    tearDown(() async {
      // Clean up after each test
      await storage.clearBox(AppConstants.avatarBoxName);
      await storage.dispose();

      // Delete the test directory
      if (await testDir.exists()) {
        await testDir.delete(recursive: true);
      }
    });

    // **Feature: brainland-game, Property 23: Unlocked items added to inventory**
    test('unlocked items are added to inventory', () async {
      final random = Random();

      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        // Start with default inventory
        final initialInventory = avatarService.loadInventory();
        final lockedItems = initialInventory
            .where((item) => !item.isUnlocked)
            .toList();

        if (lockedItems.isEmpty) {
          // If all items are unlocked, skip this iteration
          continue;
        }

        // Pick a random locked item
        final itemToUnlock = lockedItems[random.nextInt(lockedItems.length)];
        final itemId = itemToUnlock.id;

        // Unlock the item
        await avatarService.unlockItem(itemId);

        // Load inventory and verify the item is now unlocked
        final updatedInventory = avatarService.loadInventory();
        final unlockedItem = updatedInventory.firstWhere(
          (item) => item.id == itemId,
        );

        expect(
          unlockedItem.isUnlocked,
          isTrue,
          reason: 'Item $itemId should be unlocked after calling unlockItem',
        );

        // Verify it appears in the unlocked items list
        final unlockedItems = avatarService.getUnlockedItems();
        expect(
          unlockedItems.any((item) => item.id == itemId),
          isTrue,
          reason: 'Unlocked item should appear in getUnlockedItems list',
        );

        // Reset for next iteration
        await avatarService.clearAvatarData();
      }
    });

    // **Feature: brainland-game, Property 24: Item selection updates avatar immediately**
    test('item selection updates avatar immediately', () async {
      final random = Random();

      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        // Get default avatar
        final initialAvatar = avatarService.getDefaultAvatar();
        await avatarService.saveAvatar(initialAvatar);

        // Get unlocked items
        final unlockedItems = avatarService.getUnlockedItems();
        if (unlockedItems.isEmpty) {
          continue;
        }

        // Pick a random unlocked item
        final itemToEquip = unlockedItems[random.nextInt(unlockedItems.length)];

        // Equip the item
        await avatarService.equipItem(itemToEquip.id);

        // Load avatar immediately and verify the item is equipped
        final updatedAvatar = avatarService.loadAvatar();
        expect(updatedAvatar, isNotNull);

        switch (itemToEquip.category) {
          case ItemCategory.hat:
            expect(
              updatedAvatar!.equippedHat,
              equals(itemToEquip.id),
              reason: 'Hat should be equipped immediately',
            );
            break;
          case ItemCategory.clothing:
            expect(
              updatedAvatar!.equippedClothing,
              equals(itemToEquip.id),
              reason: 'Clothing should be equipped immediately',
            );
            break;
          case ItemCategory.eyes:
            expect(
              updatedAvatar!.equippedEyes,
              equals(itemToEquip.id),
              reason: 'Eyes should be equipped immediately',
            );
            break;
          case ItemCategory.background:
            expect(
              updatedAvatar!.background,
              equals(itemToEquip.id),
              reason: 'Background should be equipped immediately',
            );
            break;
        }

        // Reset for next iteration
        await avatarService.clearAvatarData();
      }
    });

    // **Feature: brainland-game, Property 25: Avatar displays all equipped items**
    test('avatar displays all equipped items', () async {
      final random = Random();

      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        // Start with default avatar
        final initialAvatar = avatarService.getDefaultAvatar();
        await avatarService.saveAvatar(initialAvatar);

        // Get unlocked items by category
        final unlockedHats = avatarService
            .getItemsByCategory(ItemCategory.hat)
            .where((item) => item.isUnlocked)
            .toList();
        final unlockedClothing = avatarService
            .getItemsByCategory(ItemCategory.clothing)
            .where((item) => item.isUnlocked)
            .toList();
        final unlockedEyes = avatarService
            .getItemsByCategory(ItemCategory.eyes)
            .where((item) => item.isUnlocked)
            .toList();
        final unlockedBackgrounds = avatarService
            .getItemsByCategory(ItemCategory.background)
            .where((item) => item.isUnlocked)
            .toList();

        // Equip one item from each category (if available)
        final equippedItems = <String, String>{};

        if (unlockedHats.isNotEmpty) {
          final hat = unlockedHats[random.nextInt(unlockedHats.length)];
          await avatarService.equipItem(hat.id);
          equippedItems['hat'] = hat.id;
        }

        if (unlockedClothing.isNotEmpty) {
          final clothing =
              unlockedClothing[random.nextInt(unlockedClothing.length)];
          await avatarService.equipItem(clothing.id);
          equippedItems['clothing'] = clothing.id;
        }

        if (unlockedEyes.isNotEmpty) {
          final eyes = unlockedEyes[random.nextInt(unlockedEyes.length)];
          await avatarService.equipItem(eyes.id);
          equippedItems['eyes'] = eyes.id;
        }

        if (unlockedBackgrounds.isNotEmpty) {
          final background =
              unlockedBackgrounds[random.nextInt(unlockedBackgrounds.length)];
          await avatarService.equipItem(background.id);
          equippedItems['background'] = background.id;
        }

        // Load avatar and verify all equipped items are present
        final avatar = avatarService.loadAvatar();
        expect(avatar, isNotNull);

        if (equippedItems.containsKey('hat')) {
          expect(
            avatar!.equippedHat,
            equals(equippedItems['hat']),
            reason: 'Avatar should display equipped hat',
          );
        }

        if (equippedItems.containsKey('clothing')) {
          expect(
            avatar!.equippedClothing,
            equals(equippedItems['clothing']),
            reason: 'Avatar should display equipped clothing',
          );
        }

        if (equippedItems.containsKey('eyes')) {
          expect(
            avatar!.equippedEyes,
            equals(equippedItems['eyes']),
            reason: 'Avatar should display equipped eyes',
          );
        }

        if (equippedItems.containsKey('background')) {
          expect(
            avatar!.background,
            equals(equippedItems['background']),
            reason: 'Avatar should display equipped background',
          );
        }

        // Reset for next iteration
        await avatarService.clearAvatarData();
      }
    });

    // **Feature: brainland-game, Property 26: Items are properly categorized**
    test('items are properly categorized', () async {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        // Load inventory
        final inventory = avatarService.loadInventory();

        // Verify each item has exactly one valid category
        for (final item in inventory) {
          expect(
            item.category,
            isIn([
              ItemCategory.hat,
              ItemCategory.clothing,
              ItemCategory.eyes,
              ItemCategory.background,
            ]),
            reason: 'Item ${item.id} should have a valid category',
          );

          // Verify the item appears in the correct category list
          final categoryItems = avatarService.getItemsByCategory(item.category);
          expect(
            categoryItems.any((catItem) => catItem.id == item.id),
            isTrue,
            reason:
                'Item ${item.id} should appear in its category (${item.category}) list',
          );

          // Verify the item does NOT appear in other category lists
          for (final otherCategory in ItemCategory.values) {
            if (otherCategory != item.category) {
              final otherCategoryItems = avatarService.getItemsByCategory(
                otherCategory,
              );
              expect(
                otherCategoryItems.any((catItem) => catItem.id == item.id),
                isFalse,
                reason:
                    'Item ${item.id} should NOT appear in other category ($otherCategory) lists',
              );
            }
          }
        }
      }
    });

    // **Feature: brainland-game, Property 41: Avatar customization persists**
    test('avatar customization persists across save and load', () async {
      final random = Random();

      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        // Create a random avatar configuration
        final avatarTypes = AvatarType.values;
        final baseType = avatarTypes[random.nextInt(avatarTypes.length)];

        // Get some unlocked items
        final unlockedItems = avatarService.getUnlockedItems();
        final hats = unlockedItems
            .where((item) => item.category == ItemCategory.hat)
            .toList();
        final clothing = unlockedItems
            .where((item) => item.category == ItemCategory.clothing)
            .toList();
        final eyes = unlockedItems
            .where((item) => item.category == ItemCategory.eyes)
            .toList();
        final backgrounds = unlockedItems
            .where((item) => item.category == ItemCategory.background)
            .toList();

        final originalAvatar = Avatar(
          id: 'test_avatar_$i',
          baseType: baseType,
          equippedHat: hats.isNotEmpty
              ? hats[random.nextInt(hats.length)].id
              : null,
          equippedClothing: clothing.isNotEmpty
              ? clothing[random.nextInt(clothing.length)].id
              : null,
          equippedEyes: eyes.isNotEmpty
              ? eyes[random.nextInt(eyes.length)].id
              : null,
          background: backgrounds.isNotEmpty
              ? backgrounds[random.nextInt(backgrounds.length)].id
              : null,
        );

        // Save the avatar
        await avatarService.saveAvatar(originalAvatar);

        // Load the avatar back
        final loadedAvatar = avatarService.loadAvatar();

        // Verify all customization is preserved
        expect(loadedAvatar, isNotNull);
        expect(
          loadedAvatar!.id,
          equals(originalAvatar.id),
          reason: 'Avatar ID should be preserved',
        );
        expect(
          loadedAvatar.baseType,
          equals(originalAvatar.baseType),
          reason: 'Base type should be preserved',
        );
        expect(
          loadedAvatar.equippedHat,
          equals(originalAvatar.equippedHat),
          reason: 'Equipped hat should be preserved',
        );
        expect(
          loadedAvatar.equippedClothing,
          equals(originalAvatar.equippedClothing),
          reason: 'Equipped clothing should be preserved',
        );
        expect(
          loadedAvatar.equippedEyes,
          equals(originalAvatar.equippedEyes),
          reason: 'Equipped eyes should be preserved',
        );
        expect(
          loadedAvatar.background,
          equals(originalAvatar.background),
          reason: 'Background should be preserved',
        );

        // Reset for next iteration
        await avatarService.clearAvatarData();
      }
    });

    test('cannot equip locked items', () async {
      // Get a locked item
      final inventory = avatarService.loadInventory();
      final lockedItems = inventory.where((item) => !item.isUnlocked).toList();

      if (lockedItems.isEmpty) {
        // Skip if no locked items
        return;
      }

      final lockedItem = lockedItems.first;

      // Attempt to equip the locked item should throw
      expect(
        () async => await avatarService.equipItem(lockedItem.id),
        throwsA(isA<Exception>()),
        reason: 'Should not be able to equip locked items',
      );
    });

    test('unequipping items removes them from avatar', () async {
      // Start with default avatar
      final initialAvatar = avatarService.getDefaultAvatar();
      await avatarService.saveAvatar(initialAvatar);

      // Get an unlocked hat and equip it
      final hats = avatarService
          .getItemsByCategory(ItemCategory.hat)
          .where((item) => item.isUnlocked)
          .toList();

      if (hats.isEmpty) {
        return;
      }

      final hat = hats.first;
      await avatarService.equipItem(hat.id);

      // Verify it's equipped
      var avatar = avatarService.loadAvatar();
      expect(avatar!.equippedHat, equals(hat.id));

      // Unequip the hat
      await avatarService.unequipItem(ItemCategory.hat);

      // Verify it's no longer equipped
      avatar = avatarService.loadAvatar();
      expect(avatar!.equippedHat, isNull);
    });
  });
}
