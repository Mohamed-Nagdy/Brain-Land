import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/pet.dart';
import '../../progress/providers/progress_provider.dart';
import '../services/pet_service.dart';

/// Provider for the pet service
final petServiceProvider = Provider<PetService>((ref) {
  return PetService.instance;
});

/// Provider for all available pets
final allPetsProvider = Provider<List<Pet>>((ref) {
  final petService = ref.watch(petServiceProvider);
  return petService.getAllPets();
});

/// Provider for unlocked pets
final unlockedPetsProvider = Provider<List<Pet>>((ref) {
  final allPets = ref.watch(allPetsProvider);
  final progress = ref.watch(progressNotifierProvider);

  return progress.when(
    data: (playerProgress) {
      return allPets
          .where((pet) => playerProgress.unlockedPets.contains(pet.id))
          .map((pet) => pet.copyWith(isUnlocked: true))
          .toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for locked pets
final lockedPetsProvider = Provider<List<Pet>>((ref) {
  final allPets = ref.watch(allPetsProvider);
  final progress = ref.watch(progressNotifierProvider);

  return progress.when(
    data: (playerProgress) {
      return allPets
          .where((pet) => !playerProgress.unlockedPets.contains(pet.id))
          .toList();
    },
    loading: () => allPets,
    error: (_, __) => allPets,
  );
});

/// Provider to check if a pet should be unlocked
final shouldUnlockPetProvider = Provider<bool>((ref) {
  final progress = ref.watch(progressNotifierProvider);
  final petService = ref.watch(petServiceProvider);

  return progress.when(
    data: (playerProgress) {
      return petService.shouldUnlockPet(
        playerProgress.consecutiveLevelsCompleted,
      );
    },
    loading: () => false,
    error: (_, __) => false,
  );
});
