import 'dart:math';

import 'package:brain_land/core/constants/app_constants.dart';
import 'package:brain_land/features/memory_river/models/memory_card.dart';
import 'package:brain_land/features/memory_river/models/memory_game_state.dart';
import 'package:brain_land/features/memory_river/models/memory_level.dart';
import 'package:brain_land/features/memory_river/services/card_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Memory Game Properties', () {
    late CardGenerator generator;

    setUp(() {
      generator = CardGenerator();
    });

    // **Feature: brainland-game, Property 11: Memory game starts with all cards face-down**
    test('memory game starts with all cards face-down', () {
      // Test across 100 iterations with different grid sizes
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        // Generate random grid sizes (2-6 rows, 2-6 columns, must be even total)
        final rows = Random().nextInt(5) + 2;
        final cols = Random().nextInt(5) + 2;
        final totalCards = rows * cols;

        // Skip if odd number of cards
        if (totalCards % 2 != 0) continue;

        final level = MemoryLevel(
          id: 'test_$i',
          levelNumber: i + 1,
          gridRows: rows,
          gridColumns: cols,
          difficulty: Random().nextInt(5) + 1,
          timeLimit: 0,
        );

        // Generate cards
        final cards = generator.generateCards(level);

        // Create initial game state
        final state = MemoryGameState(
          status: MemoryGameStatus.playing,
          level: level,
          cards: cards,
        );

        // Verify all cards start face-down
        for (final card in state.cards) {
          expect(
            card.state,
            equals(CardState.faceDown),
            reason: 'All cards should start face-down at game initialization',
          );
        }

        // Verify no cards are face-up
        final faceUpCards = state.cards.where((card) => card.isFaceUp).toList();
        expect(
          faceUpCards.length,
          equals(0),
          reason: 'No cards should be face-up at game start',
        );

        // Verify all face-down cards
        expect(
          state.faceDownCards.length,
          equals(totalCards),
          reason: 'All cards should be in face-down list',
        );
      }
    });

    // **Feature: brainland-game, Property 12: Card pair reveal is simultaneous**
    test('card pair reveal is simultaneous', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final level = const MemoryLevel(
          id: 'test',
          levelNumber: 1,
          gridRows: 2,
          gridColumns: 4,
          difficulty: 1,
          timeLimit: 0,
        );

        final cards = generator.generateCards(level);

        // Create game state with first card selected
        final firstCard = cards[0];
        final firstCardFlipped = firstCard.copyWith(state: CardState.faceUp);
        final cardsWithFirstFlipped = cards.map((card) {
          return card.id == firstCard.id ? firstCardFlipped : card;
        }).toList();

        var state = MemoryGameState(
          status: MemoryGameStatus.playing,
          level: level,
          cards: cardsWithFirstFlipped,
          firstSelectedCard: firstCardFlipped,
        );

        // Select second card
        final secondCard = cards[1];
        final secondCardFlipped = secondCard.copyWith(state: CardState.faceUp);
        final cardsWithBothFlipped = state.cards.map((card) {
          return card.id == secondCard.id ? secondCardFlipped : card;
        }).toList();

        state = state.copyWith(
          cards: cardsWithBothFlipped,
          secondSelectedCard: secondCardFlipped,
        );

        // Verify both cards are face-up simultaneously
        final firstInState = state.cards.firstWhere(
          (card) => card.id == firstCard.id,
        );
        final secondInState = state.cards.firstWhere(
          (card) => card.id == secondCard.id,
        );

        expect(
          firstInState.state,
          equals(CardState.faceUp),
          reason: 'First selected card should be face-up',
        );
        expect(
          secondInState.state,
          equals(CardState.faceUp),
          reason: 'Second selected card should be face-up',
        );
        expect(
          state.hasTwoCardsSelected,
          isTrue,
          reason: 'State should indicate two cards are selected',
        );
      }
    });

    // **Feature: brainland-game, Property 13: Matching cards stay revealed**
    test('matching cards stay revealed', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final level = const MemoryLevel(
          id: 'test',
          levelNumber: 1,
          gridRows: 2,
          gridColumns: 4,
          difficulty: 1,
          timeLimit: 0,
        );

        final cards = generator.generateCards(level);

        // Find a matching pair
        final pairId = cards[0].pairId;
        final matchingCards = cards
            .where((card) => card.pairId == pairId)
            .toList();
        expect(
          matchingCards.length,
          equals(2),
          reason: 'Should have exactly 2 matching cards',
        );

        final firstCard = matchingCards[0];
        final secondCard = matchingCards[1];

        // Simulate matching: both cards should be marked as matched
        final updatedCards = cards.map((card) {
          if (card.id == firstCard.id || card.id == secondCard.id) {
            return card.copyWith(state: CardState.matched);
          }
          return card;
        }).toList();

        final state = MemoryGameState(
          status: MemoryGameStatus.playing,
          level: level,
          cards: updatedCards,
          matchedPairs: 1,
        );

        // Verify matching cards are in matched state
        final firstInState = state.cards.firstWhere(
          (card) => card.id == firstCard.id,
        );
        final secondInState = state.cards.firstWhere(
          (card) => card.id == secondCard.id,
        );

        expect(
          firstInState.state,
          equals(CardState.matched),
          reason: 'First matching card should be in matched state',
        );
        expect(
          secondInState.state,
          equals(CardState.matched),
          reason: 'Second matching card should be in matched state',
        );
        expect(
          firstInState.isMatched,
          isTrue,
          reason: 'First card should be marked as matched',
        );
        expect(
          secondInState.isMatched,
          isTrue,
          reason: 'Second card should be marked as matched',
        );

        // Verify matched cards stay revealed
        expect(
          firstInState.isFaceUp,
          isTrue,
          reason: 'Matched cards should be considered face-up',
        );
        expect(
          secondInState.isFaceUp,
          isTrue,
          reason: 'Matched cards should be considered face-up',
        );
      }
    });

    // **Feature: brainland-game, Property 14: Non-matching cards flip back**
    test('non-matching cards flip back', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final level = const MemoryLevel(
          id: 'test',
          levelNumber: 1,
          gridRows: 2,
          gridColumns: 4,
          difficulty: 1,
          timeLimit: 0,
        );

        final cards = generator.generateCards(level);

        // Find two non-matching cards
        final firstCard = cards[0];
        final secondCard = cards.firstWhere(
          (card) => card.pairId != firstCard.pairId,
        );

        // Verify they don't match
        expect(
          firstCard.matches(secondCard),
          isFalse,
          reason: 'Selected cards should not match',
        );

        // Simulate flipping them face-up
        var updatedCards = cards.map((card) {
          if (card.id == firstCard.id || card.id == secondCard.id) {
            return card.copyWith(state: CardState.faceUp);
          }
          return card;
        }).toList();

        var state = MemoryGameState(
          status: MemoryGameStatus.playing,
          level: level,
          cards: updatedCards,
          firstSelectedCard: firstCard.copyWith(state: CardState.faceUp),
          secondSelectedCard: secondCard.copyWith(state: CardState.faceUp),
        );

        // Verify both are face-up
        expect(state.hasTwoCardsSelected, isTrue);

        // Simulate flipping them back
        updatedCards = state.cards.map((card) {
          if (card.id == firstCard.id || card.id == secondCard.id) {
            return card.copyWith(state: CardState.faceDown);
          }
          return card;
        }).toList();

        state = state.copyWith(
          cards: updatedCards,
          clearFirstSelected: true,
          clearSecondSelected: true,
        );

        // Verify they are back to face-down
        final firstInState = state.cards.firstWhere(
          (card) => card.id == firstCard.id,
        );
        final secondInState = state.cards.firstWhere(
          (card) => card.id == secondCard.id,
        );

        expect(
          firstInState.state,
          equals(CardState.faceDown),
          reason: 'Non-matching card should flip back to face-down',
        );
        expect(
          secondInState.state,
          equals(CardState.faceDown),
          reason: 'Non-matching card should flip back to face-down',
        );
        expect(
          state.firstSelectedCard,
          isNull,
          reason: 'First selected card should be cleared',
        );
        expect(
          state.secondSelectedCard,
          isNull,
          reason: 'Second selected card should be cleared',
        );
      }
    });

    // **Feature: brainland-game, Property 15: All matches complete the level**
    test('all matches complete the level', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        // Test with different grid sizes
        final rows = Random().nextInt(3) + 2; // 2-4 rows
        final cols = Random().nextInt(3) + 2; // 2-4 columns
        final totalCards = rows * cols;

        // Skip if odd number of cards
        if (totalCards % 2 != 0) continue;

        final level = MemoryLevel(
          id: 'test_$i',
          levelNumber: i + 1,
          gridRows: rows,
          gridColumns: cols,
          difficulty: Random().nextInt(5) + 1,
          timeLimit: 0,
        );

        final totalPairs = level.totalPairs;
        final cards = generator.generateCards(level);

        // Simulate all cards being matched
        final allMatchedCards = cards.map((card) {
          return card.copyWith(state: CardState.matched);
        }).toList();

        final state = MemoryGameState(
          status: MemoryGameStatus.playing,
          level: level,
          cards: allMatchedCards,
          matchedPairs: totalPairs,
        );

        // Verify level is complete
        expect(
          state.isComplete,
          isTrue,
          reason:
              'Level should be complete when all pairs are matched ($totalPairs pairs)',
        );
        expect(
          state.matchedPairs,
          equals(totalPairs),
          reason: 'Matched pairs should equal total pairs',
        );
        expect(
          state.matchedCards.length,
          equals(totalCards),
          reason: 'All cards should be in matched state',
        );

        // Test incomplete state
        final incompleteState = state.copyWith(matchedPairs: totalPairs - 1);
        expect(
          incompleteState.isComplete,
          isFalse,
          reason: 'Level should not be complete with one pair remaining',
        );
      }
    });

    test('card generation creates correct number of pairs', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final rows = Random().nextInt(4) + 2;
        final cols = Random().nextInt(4) + 2;
        final totalCards = rows * cols;

        if (totalCards % 2 != 0) continue;

        final level = MemoryLevel(
          id: 'test_$i',
          levelNumber: i + 1,
          gridRows: rows,
          gridColumns: cols,
          difficulty: 1,
          timeLimit: 0,
        );

        final cards = generator.generateCards(level);

        // Verify correct number of cards
        expect(
          cards.length,
          equals(totalCards),
          reason: 'Should generate correct number of cards',
        );

        // Verify each card has exactly one match
        for (final card in cards) {
          final matches = cards.where((c) => c.pairId == card.pairId).toList();
          expect(
            matches.length,
            equals(2),
            reason: 'Each card should have exactly one matching pair',
          );
        }

        // Verify total pairs
        final uniquePairIds = cards.map((c) => c.pairId).toSet();
        expect(
          uniquePairIds.length,
          equals(level.totalPairs),
          reason: 'Should have correct number of unique pairs',
        );
      }
    });

    test('card positions are unique and sequential', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final level = MemoryLevel(
          id: 'test_$i',
          levelNumber: i + 1,
          gridRows: 3,
          gridColumns: 4,
          difficulty: 1,
          timeLimit: 0,
        );

        final cards = generator.generateCards(level);

        // Verify all positions are unique
        final positions = cards.map((c) => c.position).toList();
        final uniquePositions = positions.toSet();
        expect(
          uniquePositions.length,
          equals(cards.length),
          reason: 'All card positions should be unique',
        );

        // Verify positions are sequential from 0 to n-1
        positions.sort();
        for (int j = 0; j < positions.length; j++) {
          expect(
            positions[j],
            equals(j),
            reason: 'Positions should be sequential starting from 0',
          );
        }
      }
    });

    test('moves counter increments correctly', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final level = const MemoryLevel(
          id: 'test',
          levelNumber: 1,
          gridRows: 2,
          gridColumns: 4,
          difficulty: 1,
          timeLimit: 0,
        );

        var state = MemoryGameState(
          status: MemoryGameStatus.playing,
          level: level,
          cards: generator.generateCards(level),
          moves: 0,
        );

        // Simulate multiple moves
        final moveCount = Random().nextInt(20) + 1;
        for (int j = 0; j < moveCount; j++) {
          state = state.copyWith(moves: state.moves + 1);
        }

        expect(
          state.moves,
          equals(moveCount),
          reason: 'Moves should increment correctly',
        );
      }
    });

    test('matched pairs counter increments correctly', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final level = const MemoryLevel(
          id: 'test',
          levelNumber: 1,
          gridRows: 3,
          gridColumns: 4,
          difficulty: 1,
          timeLimit: 0,
        );

        var state = MemoryGameState(
          status: MemoryGameStatus.playing,
          level: level,
          cards: generator.generateCards(level),
          matchedPairs: 0,
        );

        // Simulate matching pairs
        final pairsToMatch = Random().nextInt(level.totalPairs) + 1;
        for (int j = 0; j < pairsToMatch; j++) {
          state = state.copyWith(matchedPairs: state.matchedPairs + 1);
        }

        expect(
          state.matchedPairs,
          equals(pairsToMatch),
          reason: 'Matched pairs should increment correctly',
        );
      }
    });

    test('card matching logic is correct', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final level = const MemoryLevel(
          id: 'test',
          levelNumber: 1,
          gridRows: 2,
          gridColumns: 4,
          difficulty: 1,
          timeLimit: 0,
        );

        final cards = generator.generateCards(level);

        // Test matching cards
        for (final card in cards) {
          final matchingCard = cards.firstWhere(
            (c) => c.pairId == card.pairId && c.id != card.id,
          );

          expect(
            card.matches(matchingCard),
            isTrue,
            reason: 'Cards with same pairId should match',
          );
          expect(
            matchingCard.matches(card),
            isTrue,
            reason: 'Matching should be symmetric',
          );
        }

        // Test non-matching cards
        if (cards.length >= 4) {
          final card1 = cards[0];
          final card2 = cards.firstWhere((c) => c.pairId != card1.pairId);

          expect(
            card1.matches(card2),
            isFalse,
            reason: 'Cards with different pairIds should not match',
          );
        }
      }
    });

    test('card cannot match with itself', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final level = const MemoryLevel(
          id: 'test',
          levelNumber: 1,
          gridRows: 2,
          gridColumns: 4,
          difficulty: 1,
          timeLimit: 0,
        );

        final cards = generator.generateCards(level);

        for (final card in cards) {
          expect(
            card.matches(card),
            isFalse,
            reason: 'Card should not match with itself',
          );
        }
      }
    });

    test('game state transitions are valid', () {
      final validTransitions = {
        MemoryGameStatus.initial: [MemoryGameStatus.loading],
        MemoryGameStatus.loading: [
          MemoryGameStatus.playing,
          MemoryGameStatus.error,
        ],
        MemoryGameStatus.playing: [
          MemoryGameStatus.paused,
          MemoryGameStatus.completed,
          MemoryGameStatus.error,
        ],
        MemoryGameStatus.paused: [MemoryGameStatus.playing],
        MemoryGameStatus.completed: [],
        MemoryGameStatus.error: [],
      };

      for (final entry in validTransitions.entries) {
        final fromStatus = entry.key;
        final validNextStatuses = entry.value;

        final state = MemoryGameState(status: fromStatus, cards: []);

        for (final nextStatus in validNextStatuses) {
          final newState = state.copyWith(status: nextStatus);
          expect(newState.status, equals(nextStatus));
        }
      }
    });

    test('time spent calculation is accurate', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final startTime = DateTime.now().subtract(
          Duration(seconds: Random().nextInt(300)),
        );

        final state = MemoryGameState(
          status: MemoryGameStatus.playing,
          cards: [],
          startTime: startTime,
        );

        final expectedTimeSpent = DateTime.now()
            .difference(startTime)
            .inSeconds;
        final actualTimeSpent = state.timeSpent;

        // Allow 1 second tolerance for test execution time
        expect(
          actualTimeSpent,
          inInclusiveRange(expectedTimeSpent - 1, expectedTimeSpent + 1),
          reason: 'Time spent should be calculated correctly',
        );
      }
    });

    test('grid size calculations are correct', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final rows = Random().nextInt(5) + 2;
        final cols = Random().nextInt(5) + 2;

        final level = MemoryLevel(
          id: 'test_$i',
          levelNumber: i + 1,
          gridRows: rows,
          gridColumns: cols,
          difficulty: 1,
          timeLimit: 0,
        );

        expect(
          level.totalCards,
          equals(rows * cols),
          reason: 'Total cards should equal rows * columns',
        );
        expect(
          level.totalPairs,
          equals((rows * cols) ~/ 2),
          reason: 'Total pairs should be half of total cards',
        );
        expect(
          level.gridSize,
          equals('${rows}x$cols'),
          reason: 'Grid size string should be formatted correctly',
        );
      }
    });

    test('state equality works correctly', () {
      final level = const MemoryLevel(
        id: 'test',
        levelNumber: 1,
        gridRows: 2,
        gridColumns: 4,
        difficulty: 1,
        timeLimit: 0,
      );
      final cards = generator.generateCards(level);

      final state1 = MemoryGameState(
        status: MemoryGameStatus.playing,
        level: level,
        cards: cards,
        moves: 5,
        matchedPairs: 2,
      );

      final state2 = MemoryGameState(
        status: MemoryGameStatus.playing,
        level: level,
        cards: cards,
        moves: 5,
        matchedPairs: 2,
      );

      expect(state1, equals(state2));
    });

    test('copyWith creates proper copies', () {
      final level = const MemoryLevel(
        id: 'test',
        levelNumber: 1,
        gridRows: 2,
        gridColumns: 4,
        difficulty: 1,
        timeLimit: 0,
      );
      final cards = generator.generateCards(level);

      final original = MemoryGameState(
        status: MemoryGameStatus.playing,
        level: level,
        cards: cards,
        moves: 5,
        matchedPairs: 2,
      );

      final modified = original.copyWith(moves: 10);

      expect(modified.moves, equals(10));
      expect(modified.matchedPairs, equals(original.matchedPairs));
      expect(modified.status, equals(original.status));
      expect(modified.cards, equals(original.cards));
    });
  });
}
