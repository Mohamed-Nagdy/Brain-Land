import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../shared/models/pet.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../providers/pet_provider.dart';
import '../widgets/pet_display.dart';

/// Screen to display all pets (locked and unlocked)
class PetCollectionScreen extends ConsumerStatefulWidget {
  const PetCollectionScreen({super.key});

  @override
  ConsumerState<PetCollectionScreen> createState() =>
      _PetCollectionScreenState();
}

class _PetCollectionScreenState extends ConsumerState<PetCollectionScreen> {
  Pet? _selectedPet;

  @override
  Widget build(BuildContext context) {
    final allPets = ref.watch(allPetsProvider);
    final unlockedPets = ref.watch(unlockedPetsProvider);
    final unlockedPetIds = unlockedPets.map((pet) => pet.id).toSet();

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildStats(unlockedPets.length, allPets.length),
              const SizedBox(height: 20),
              Expanded(child: _buildPetGrid(allPets, unlockedPetIds)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Text(
            'Pet Collection',
            style: AppTextStyles.heading1.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(int unlocked, int total) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.pets, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          Text(
            '$unlocked / $total Pets Unlocked',
            style: AppTextStyles.heading2.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildPetGrid(List<Pet> allPets, Set<String> unlockedPetIds) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: allPets.length,
      itemBuilder: (context, index) {
        final pet = allPets[index];
        final isUnlocked = unlockedPetIds.contains(pet.id);
        final displayPet = pet.copyWith(isUnlocked: isUnlocked);

        return _buildPetCard(displayPet);
      },
    );
  }

  Widget _buildPetCard(Pet pet) {
    final isSelected = _selectedPet?.id == pet.id;

    return GestureDetector(
      onTap: () => _selectPet(pet),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PetDisplay(pet: pet, size: 80, showAnimation: pet.isUnlocked),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                pet.name,
                style: AppTextStyles.heading3.copyWith(
                  color: pet.isUnlocked ? AppColors.textPrimary : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
            if (pet.isUnlocked) _buildRarityStars(pet.rarity),
            if (!pet.isUnlocked)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Locked',
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRarityStars(int rarity) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        rarity,
        (index) => const Icon(Icons.star, color: Colors.amber, size: 16),
      ),
    );
  }

  void _selectPet(Pet pet) {
    if (!pet.isUnlocked) {
      _showLockedPetDialog(pet);
      return;
    }

    setState(() {
      _selectedPet = pet;
    });

    _showPetDetailsDialog(pet);
  }

  void _showPetDetailsDialog(Pet pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          pet.name,
          style: AppTextStyles.heading2,
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PetDisplay(pet: pet, size: 120, showAnimation: true),
            const SizedBox(height: 16),
            Text(
              pet.description,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            _buildRarityStars(pet.rarity),
            const SizedBox(height: 8),
            Text(
              'Rarity: ${'★' * pet.rarity}',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
            ),
            if (pet.unlockedAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Unlocked: ${_formatDate(pet.unlockedAt!)}',
                style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: AppTextStyles.button.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLockedPetDialog(Pet pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Locked Pet',
          style: AppTextStyles.heading2,
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PetDisplay(pet: pet, size: 120, showAnimation: false),
            const SizedBox(height: 16),
            Text(
              'Complete 5 consecutive levels to unlock a new pet!',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Keep playing to unlock!',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Got it!',
              style: AppTextStyles.button.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
