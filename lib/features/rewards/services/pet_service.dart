import 'dart:math';

import '../../../shared/models/pet.dart';

/// Service for managing pet unlocking and selection
class PetService {
  static final PetService _instance = PetService._();
  static PetService get instance => _instance;

  PetService._();

  /// All available pets in the game
  final List<Pet> _allPets = [
    const Pet(
      id: 'pet_dragon',
      type: PetType.dragon,
      name: 'Sparky',
      description: 'A friendly dragon who loves math!',
      iconPath: 'assets/pets/dragon.png',
      rarity: 5,
    ),
    const Pet(
      id: 'pet_unicorn',
      type: PetType.unicorn,
      name: 'Rainbow',
      description: 'A magical unicorn with a colorful mane',
      iconPath: 'assets/pets/unicorn.png',
      rarity: 4,
    ),
    const Pet(
      id: 'pet_phoenix',
      type: PetType.phoenix,
      name: 'Blaze',
      description: 'A fiery phoenix that rises from the ashes',
      iconPath: 'assets/pets/phoenix.png',
      rarity: 5,
    ),
    const Pet(
      id: 'pet_owl',
      type: PetType.owl,
      name: 'Wisdom',
      description: 'A wise owl who helps you learn',
      iconPath: 'assets/pets/owl.png',
      rarity: 3,
    ),
    const Pet(
      id: 'pet_fox',
      type: PetType.fox,
      name: 'Clever',
      description: 'A clever fox with quick thinking',
      iconPath: 'assets/pets/fox.png',
      rarity: 3,
    ),
    const Pet(
      id: 'pet_bunny',
      type: PetType.bunny,
      name: 'Hoppy',
      description: 'A bouncy bunny full of energy',
      iconPath: 'assets/pets/bunny.png',
      rarity: 2,
    ),
    const Pet(
      id: 'pet_panda',
      type: PetType.panda,
      name: 'Bamboo',
      description: 'A cuddly panda who loves to play',
      iconPath: 'assets/pets/panda.png',
      rarity: 3,
    ),
    const Pet(
      id: 'pet_robot',
      type: PetType.robot,
      name: 'Bolt',
      description: 'A helpful robot companion',
      iconPath: 'assets/pets/robot.png',
      rarity: 4,
    ),
  ];

  /// Get all available pets
  List<Pet> getAllPets() {
    return List.unmodifiable(_allPets);
  }

  /// Get a pet by ID
  Pet? getPetById(String id) {
    try {
      return _allPets.firstWhere((pet) => pet.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get a random pet to unlock
  /// Weighted by rarity (lower rarity = higher chance)
  Pet getRandomPetToUnlock(List<String> alreadyUnlockedIds) {
    // Filter out already unlocked pets
    final availablePets = _allPets
        .where((pet) => !alreadyUnlockedIds.contains(pet.id))
        .toList();

    if (availablePets.isEmpty) {
      // If all pets are unlocked, return a random one
      return _allPets[Random().nextInt(_allPets.length)];
    }

    // Calculate total weight (inverse of rarity for weighted selection)
    final totalWeight = availablePets.fold<int>(
      0,
      (sum, pet) => sum + (6 - pet.rarity), // Higher rarity = lower weight
    );

    // Select a random pet based on weight
    final random = Random().nextInt(totalWeight);
    int currentWeight = 0;

    for (final pet in availablePets) {
      currentWeight += (6 - pet.rarity);
      if (random < currentWeight) {
        return pet;
      }
    }

    // Fallback (should never reach here)
    return availablePets.first;
  }

  /// Check if a pet should be unlocked based on consecutive levels
  bool shouldUnlockPet(int consecutiveLevels) {
    return consecutiveLevels > 0 && consecutiveLevels % 5 == 0;
  }

  /// Unlock a pet and return the unlocked pet
  Pet unlockPet(Pet pet) {
    return pet.copyWith(isUnlocked: true, unlockedAt: DateTime.now());
  }
}
