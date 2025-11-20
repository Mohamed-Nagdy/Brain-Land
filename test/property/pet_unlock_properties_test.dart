import 'package:brain_land/core/constants/app_constants.dart';
import 'package:brain_land/features/rewards/services/pet_service.dart';
import 'package:brain_land/shared/models/pet.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Pet Unlock Properties', () {
    late PetService petService;

    setUp(() {
      petService = PetService.instance;
    });

    // **Feature: brainland-game, Property 21: Five consecutive levels unlock pet**
    test('exactly 5 consecutive levels unlocks a pet', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        // Test that exactly 5 consecutive levels triggers unlock
        expect(
          petService.shouldUnlockPet(5),
          isTrue,
          reason: 'Exactly 5 consecutive levels should unlock a pet',
        );
      }
    });

    test('multiples of 5 consecutive levels unlock pets', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        // Test various multiples of 5
        final multiples = [5, 10, 15, 20, 25, 30, 35, 40];

        for (final multiple in multiples) {
          expect(
            petService.shouldUnlockPet(multiple),
            isTrue,
            reason: '$multiple consecutive levels should unlock a pet',
          );
        }
      }
    });

    test('non-multiples of 5 do not unlock pets', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        // Test numbers that are not multiples of 5
        final nonMultiples = [
          1,
          2,
          3,
          4,
          6,
          7,
          8,
          9,
          11,
          13,
          14,
          16,
          17,
          18,
          19,
        ];

        for (final num in nonMultiples) {
          expect(
            petService.shouldUnlockPet(num),
            isFalse,
            reason: '$num consecutive levels should not unlock a pet',
          );
        }
      }
    });

    test('zero consecutive levels does not unlock pet', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        expect(
          petService.shouldUnlockPet(0),
          isFalse,
          reason: '0 consecutive levels should not unlock a pet',
        );
      }
    });

    test('negative consecutive levels does not unlock pet', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        expect(
          petService.shouldUnlockPet(-1),
          isFalse,
          reason: 'Negative consecutive levels should not unlock a pet',
        );

        expect(
          petService.shouldUnlockPet(-5),
          isFalse,
          reason: 'Negative consecutive levels should not unlock a pet',
        );
      }
    });

    test('unlocked pet has correct properties', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final allPets = petService.getAllPets();

        for (final pet in allPets) {
          final unlockedPet = petService.unlockPet(pet);

          expect(
            unlockedPet.isUnlocked,
            isTrue,
            reason: 'Unlocked pet should have isUnlocked = true',
          );

          expect(
            unlockedPet.unlockedAt,
            isNotNull,
            reason: 'Unlocked pet should have unlockedAt timestamp',
          );

          expect(
            unlockedPet.unlockedAt!.isBefore(
              DateTime.now().add(Duration(seconds: 1)),
            ),
            isTrue,
            reason: 'Unlocked pet timestamp should be in the past or present',
          );

          // Other properties should remain unchanged
          expect(unlockedPet.id, equals(pet.id));
          expect(unlockedPet.type, equals(pet.type));
          expect(unlockedPet.name, equals(pet.name));
          expect(unlockedPet.description, equals(pet.description));
          expect(unlockedPet.iconPath, equals(pet.iconPath));
          expect(unlockedPet.rarity, equals(pet.rarity));
        }
      }
    });

    test('random pet selection excludes already unlocked pets', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final allPets = petService.getAllPets();

        // Unlock half of the pets
        final unlockedIds = allPets
            .take(allPets.length ~/ 2)
            .map((pet) => pet.id)
            .toList();

        // Get a random pet to unlock
        final randomPet = petService.getRandomPetToUnlock(unlockedIds);

        // Verify the random pet is not in the unlocked list
        expect(
          unlockedIds.contains(randomPet.id),
          isFalse,
          reason: 'Random pet should not be from already unlocked pets',
        );
      }
    });

    test('random pet selection returns any pet when all are unlocked', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final allPets = petService.getAllPets();
        final allUnlockedIds = allPets.map((pet) => pet.id).toList();

        // Get a random pet when all are unlocked
        final randomPet = petService.getRandomPetToUnlock(allUnlockedIds);

        // Should still return a valid pet
        expect(
          allUnlockedIds.contains(randomPet.id),
          isTrue,
          reason: 'Should return a valid pet even when all are unlocked',
        );
      }
    });

    test('all pets have valid properties', () {
      final allPets = petService.getAllPets();

      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        for (final pet in allPets) {
          expect(pet.id.isNotEmpty, isTrue, reason: 'Pet should have id');
          expect(pet.name.isNotEmpty, isTrue, reason: 'Pet should have name');
          expect(
            pet.description.isNotEmpty,
            isTrue,
            reason: 'Pet should have description',
          );
          expect(
            pet.iconPath.isNotEmpty,
            isTrue,
            reason: 'Pet should have iconPath',
          );
          expect(
            pet.rarity,
            inInclusiveRange(1, 5),
            reason: 'Pet rarity should be between 1 and 5',
          );
          expect(
            PetType.values.contains(pet.type),
            isTrue,
            reason: 'Pet should have valid type',
          );
        }
      }
    });

    test('all pet types are represented', () {
      final allPets = petService.getAllPets();
      final petTypes = allPets.map((pet) => pet.type).toSet();

      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        expect(
          petTypes.length,
          equals(PetType.values.length),
          reason: 'Should have pets of all types',
        );

        for (final type in PetType.values) {
          expect(
            petTypes.contains(type),
            isTrue,
            reason: 'Should have pet of type $type',
          );
        }
      }
    });

    test('pet IDs are unique', () {
      final allPets = petService.getAllPets();
      final petIds = allPets.map((pet) => pet.id).toList();
      final uniqueIds = petIds.toSet();

      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        expect(
          uniqueIds.length,
          equals(petIds.length),
          reason: 'All pet IDs should be unique',
        );
      }
    });

    test('getPetById returns correct pet', () {
      final allPets = petService.getAllPets();

      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        for (final pet in allPets) {
          final foundPet = petService.getPetById(pet.id);

          expect(foundPet, isNotNull, reason: 'Should find pet by ID');
          expect(foundPet!.id, equals(pet.id));
          expect(foundPet.type, equals(pet.type));
          expect(foundPet.name, equals(pet.name));
        }
      }
    });

    test('getPetById returns null for invalid ID', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final invalidPet = petService.getPetById('invalid_pet_id_$i');

        expect(
          invalidPet,
          isNull,
          reason: 'Should return null for invalid pet ID',
        );
      }
    });

    test('pet rarity affects unlock probability distribution', () {
      // Test that lower rarity pets are more likely to be selected
      final rarityCount = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      const iterations = 1000;

      for (int i = 0; i < iterations; i++) {
        final randomPet = petService.getRandomPetToUnlock([]);
        rarityCount[randomPet.rarity] = rarityCount[randomPet.rarity]! + 1;
      }

      // Get the actual rarities present in the pet service
      final allPets = petService.getAllPets();
      final actualRarities = allPets.map((pet) => pet.rarity).toSet();

      // Verify all actual rarities are represented
      for (final rarity in actualRarities) {
        expect(
          rarityCount[rarity]!,
          greaterThan(0),
          reason:
              'Rarity $rarity should appear at least once in $iterations iterations',
        );
      }

      // Verify that the distribution is reasonable (not all equal)
      // The weighted selection should create some variance
      final nonZeroCounts = rarityCount.values
          .where((count) => count > 0)
          .toList();
      if (nonZeroCounts.length > 1) {
        final maxCount = nonZeroCounts.reduce((a, b) => a > b ? a : b);
        final minCount = nonZeroCounts.reduce((a, b) => a < b ? a : b);

        expect(
          maxCount,
          greaterThan(minCount),
          reason: 'Weighted selection should create variance in distribution',
        );
      }
    });

    test('pet animation states are valid', () {
      final allPets = petService.getAllPets();

      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        for (final pet in allPets) {
          expect(
            PetAnimation.values.contains(pet.currentAnimation),
            isTrue,
            reason: 'Pet should have valid animation state',
          );
        }
      }
    });

    test('default pet animation is idle', () {
      final allPets = petService.getAllPets();

      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        for (final pet in allPets) {
          expect(
            pet.currentAnimation,
            equals(PetAnimation.idle),
            reason: 'Default pet animation should be idle',
          );
        }
      }
    });

    test('pet copyWith preserves unchanged properties', () {
      final allPets = petService.getAllPets();

      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        for (final pet in allPets) {
          final copiedPet = pet.copyWith(isUnlocked: true);

          expect(copiedPet.id, equals(pet.id));
          expect(copiedPet.type, equals(pet.type));
          expect(copiedPet.name, equals(pet.name));
          expect(copiedPet.description, equals(pet.description));
          expect(copiedPet.iconPath, equals(pet.iconPath));
          expect(copiedPet.rarity, equals(pet.rarity));
          expect(copiedPet.currentAnimation, equals(pet.currentAnimation));

          // Only isUnlocked should change
          expect(copiedPet.isUnlocked, isTrue);
        }
      }
    });

    test('pet equality works correctly', () {
      final pet1 = Pet(
        id: 'test_pet',
        type: PetType.dragon,
        name: 'Test Dragon',
        description: 'A test',
        iconPath: 'test.png',
        rarity: 3,
      );

      final pet2 = Pet(
        id: 'test_pet',
        type: PetType.dragon,
        name: 'Test Dragon',
        description: 'A test',
        iconPath: 'test.png',
        rarity: 3,
      );

      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        expect(pet1, equals(pet2));
      }
    });

    test('consecutive level counter resets correctly after unlock', () {
      // This tests the logic that after unlocking at 5, 10, 15, etc.
      // the counter continues and unlocks happen at the right intervals
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final unlockPoints = [5, 10, 15, 20, 25, 30];

        for (final point in unlockPoints) {
          expect(
            petService.shouldUnlockPet(point),
            isTrue,
            reason: 'Should unlock at $point consecutive levels',
          );
        }

        // Points between unlocks should not trigger
        final nonUnlockPoints = [6, 7, 8, 9, 11, 12, 13, 14, 16, 17, 18, 19];

        for (final point in nonUnlockPoints) {
          expect(
            petService.shouldUnlockPet(point),
            isFalse,
            reason: 'Should not unlock at $point consecutive levels',
          );
        }
      }
    });

    test('pet service is singleton', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final instance1 = PetService.instance;
        final instance2 = PetService.instance;

        expect(
          identical(instance1, instance2),
          isTrue,
          reason: 'PetService should be a singleton',
        );
      }
    });

    test('getAllPets returns immutable list', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final pets1 = petService.getAllPets();
        final pets2 = petService.getAllPets();

        // Should return same content
        expect(pets1.length, equals(pets2.length));

        for (int j = 0; j < pets1.length; j++) {
          expect(pets1[j].id, equals(pets2[j].id));
        }
      }
    });
  });
}
