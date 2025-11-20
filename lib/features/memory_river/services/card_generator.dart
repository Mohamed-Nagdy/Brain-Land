import 'dart:math';

import '../models/memory_card.dart';
import '../models/memory_level.dart';

/// Service for generating memory cards for a level
class CardGenerator {
  final Random _random = Random();

  /// Generate a shuffled list of memory cards for a level
  List<MemoryCard> generateCards(MemoryLevel level) {
    final totalCards = level.totalCards;
    final totalPairs = level.totalPairs;

    // Generate pair IDs
    final pairIds = List.generate(totalPairs, (index) => 'pair_$index');

    // Create cards (2 cards per pair)
    final cards = <MemoryCard>[];
    for (int i = 0; i < totalPairs; i++) {
      final pairId = pairIds[i];
      final imageAsset = _getImageAsset(i);

      // Create first card of the pair
      cards.add(
        MemoryCard(
          id: '${pairId}_1',
          pairId: pairId,
          imageAsset: imageAsset,
          position: 0, // Will be set after shuffling
        ),
      );

      // Create second card of the pair
      cards.add(
        MemoryCard(
          id: '${pairId}_2',
          pairId: pairId,
          imageAsset: imageAsset,
          position: 0, // Will be set after shuffling
        ),
      );
    }

    // Shuffle the cards
    cards.shuffle(_random);

    // Assign positions after shuffling
    final shuffledCards = <MemoryCard>[];
    for (int i = 0; i < cards.length; i++) {
      shuffledCards.add(cards[i].copyWith(position: i));
    }

    return shuffledCards;
  }

  /// Get the image asset path for a card
  /// In a full implementation, this would return actual asset paths
  String _getImageAsset(int index) {
    // For now, return placeholder paths
    // These would be actual image assets in the final implementation
    final images = [
      'assets/images/memory/apple.png',
      'assets/images/memory/banana.png',
      'assets/images/memory/cherry.png',
      'assets/images/memory/grape.png',
      'assets/images/memory/orange.png',
      'assets/images/memory/pear.png',
      'assets/images/memory/strawberry.png',
      'assets/images/memory/watermelon.png',
      'assets/images/memory/pineapple.png',
      'assets/images/memory/kiwi.png',
      'assets/images/memory/mango.png',
      'assets/images/memory/peach.png',
      'assets/images/memory/plum.png',
      'assets/images/memory/lemon.png',
      'assets/images/memory/lime.png',
    ];

    return images[index % images.length];
  }
}
