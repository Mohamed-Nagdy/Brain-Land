import 'dart:async';

import 'package:brain_land/features/progress/providers/progress_provider.dart';
import 'package:brain_land/features/world_map/providers/world_map_provider.dart';
import 'package:brain_land/shared/models/zone_progress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/memory_card.dart';
import '../models/memory_game_state.dart';
import '../models/memory_level.dart';
import '../services/card_generator.dart';
import '../services/memory_storage_service.dart';

/// Provider for the card generator
final cardGeneratorProvider = Provider<CardGenerator>((ref) {
  return CardGenerator();
});

/// Provider for the memory storage service
final memoryStorageServiceProvider = Provider<MemoryStorageService>((ref) {
  return MemoryStorageService();
});

/// Provider for fetching all memory levels
final memoryLevelsProvider = FutureProvider<List<MemoryLevel>>((ref) async {
  final storage = ref.watch(memoryStorageServiceProvider);
  return storage.getAllLevels();
});

/// Provider for managing the memory game state
final memoryGameProvider =
    StateNotifierProvider.family<MemoryGameNotifier, MemoryGameState, String>((
      ref,
      levelId,
    ) {
      final generator = ref.watch(cardGeneratorProvider);
      final storage = ref.watch(memoryStorageServiceProvider);

      return MemoryGameNotifier(
        levelId: levelId,
        generator: generator,
        storage: storage,
        ref: ref,
      );
    });

/// Notifier for managing memory game state
class MemoryGameNotifier extends StateNotifier<MemoryGameState> {
  final String levelId;
  final CardGenerator generator;
  final MemoryStorageService storage;
  final Ref ref;

  Timer? _timer;
  Timer? _flipBackTimer;

  MemoryGameNotifier({
    required this.levelId,
    required this.generator,
    required this.storage,
    required this.ref,
  }) : super(MemoryGameState.initial());

  /// Start the game level
  Future<void> startLevel() async {
    state = MemoryGameState.loading();

    try {
      // Load level data
      final level = await storage.getLevel(levelId);

      // Generate cards for the level
      final cards = generator.generateCards(level);

      // Initialize game state with all cards face UP initially
      final initialCards = cards
          .map((c) => c.copyWith(state: CardState.faceUp))
          .toList();

      state = MemoryGameState(
        status: MemoryGameStatus
            .playing, // Or a new status like 'preview' if needed, but playing is fine if we block input
        level: level,
        cards: initialCards,
        timeRemaining: level.timeLimit,
        startTime: DateTime.now(), // We might want to reset this after preview
      );

      // Wait for 2 seconds to let user memorize
      await Future.delayed(const Duration(seconds: 2));

      // Flip cards face down
      if (mounted) {
        // Check if notifier is still active
        final faceDownCards = cards
            .map((c) => c.copyWith(state: CardState.faceDown))
            .toList();

        state = state.copyWith(
          cards: faceDownCards,
          startTime:
              DateTime.now(), // Reset start time so preview doesn't count
        );

        // Start timer if time limit is set
        if (level.timeLimit > 0) {
          _startTimer();
        }
      }
    } catch (e) {
      state = MemoryGameState.error('Failed to start level: $e');
    }
  }

  /// Select a card
  void selectCard(String cardId) {
    if (state.status != MemoryGameStatus.playing) return;
    if (state.hasTwoCardsSelected) return; // Wait for cards to flip back

    // Find the card
    final cardIndex = state.cards.indexWhere((card) => card.id == cardId);
    if (cardIndex == -1) return;

    final card = state.cards[cardIndex];

    // Can't select already matched or face-up cards
    if (card.isMatched || card.isFaceUp) return;

    // Flip the card face up
    final updatedCards = List<MemoryCard>.from(state.cards);
    updatedCards[cardIndex] = card.copyWith(state: CardState.faceUp);

    if (!state.hasOneCardSelected) {
      // This is the first card selected
      state = state.copyWith(
        cards: updatedCards,
        firstSelectedCard: card.copyWith(state: CardState.faceUp),
      );
    } else {
      // This is the second card selected
      state = state.copyWith(
        cards: updatedCards,
        secondSelectedCard: card.copyWith(state: CardState.faceUp),
        moves: state.moves + 1,
      );

      // Check for match after a brief delay
      _checkForMatch();
    }
  }

  /// Check if the two selected cards match
  void _checkForMatch() {
    if (!state.hasTwoCardsSelected) return;

    final first = state.firstSelectedCard!;
    final second = state.secondSelectedCard!;

    if (first.matches(second)) {
      // Cards match! Mark them as matched
      _handleMatch();
    } else {
      // Cards don't match, flip them back after a delay
      _scheduleFlipBack();
    }
  }

  /// Handle a successful match
  void _handleMatch() {
    final updatedCards = state.cards.map((card) {
      if (card.id == state.firstSelectedCard!.id ||
          card.id == state.secondSelectedCard!.id) {
        return card.copyWith(state: CardState.matched);
      }
      return card;
    }).toList();

    state = state.copyWith(
      cards: updatedCards,
      matchedPairs: state.matchedPairs + 1,
      clearFirstSelected: true,
      clearSecondSelected: true,
    );

    // Check if level is complete
    if (state.isComplete) {
      _completeLevel();
    }
  }

  /// Schedule cards to flip back after a delay
  void _scheduleFlipBack() {
    _flipBackTimer?.cancel();
    _flipBackTimer = Timer(const Duration(milliseconds: 1000), () {
      _flipCardsBack();
    });
  }

  /// Flip the two selected cards back to face down
  void _flipCardsBack() {
    if (!state.hasTwoCardsSelected) return;

    final updatedCards = state.cards.map((card) {
      if (card.id == state.firstSelectedCard!.id ||
          card.id == state.secondSelectedCard!.id) {
        return card.copyWith(state: CardState.faceDown);
      }
      return card;
    }).toList();

    state = state.copyWith(
      cards: updatedCards,
      clearFirstSelected: true,
      clearSecondSelected: true,
    );
  }

  /// Start the countdown timer
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeRemaining > 0) {
        state = state.copyWith(timeRemaining: state.timeRemaining - 1);
      } else {
        // Time expired
        timer.cancel();
        _completeLevel();
      }
    });
  }

  /// Pause the game
  void pauseGame() {
    if (state.status == MemoryGameStatus.playing) {
      _timer?.cancel();
      _flipBackTimer?.cancel();
      state = state.copyWith(status: MemoryGameStatus.paused);
    }
  }

  /// Resume the game
  void resumeGame() {
    if (state.status == MemoryGameStatus.paused) {
      state = state.copyWith(status: MemoryGameStatus.playing);
      if (state.level != null && state.level!.timeLimit > 0) {
        _startTimer();
      }
    }
  }

  /// Complete the level and calculate results
  Future<void> _completeLevel() async {
    _timer?.cancel();
    _flipBackTimer?.cancel();

    if (state.level == null) return;

    // Calculate time spent
    final timeSpent = state.timeSpent;

    // Calculate stars earned based on moves and time
    final starsEarned = _calculateStars(state.moves, timeSpent, state.level!);

    // Save progress
    await storage.updateLevelProgress(
      levelId: levelId,
      moves: state.moves,
      timeSpent: timeSpent,
      starsEarned: starsEarned,
    );

    // Sync with global progress provider
    final completedCount = await storage.getCompletedLevelsCount();
    final currentProgress = await ref.read(progressNotifierProvider.future);
    final currentZoneProgress =
        currentProgress.zoneProgress['memory_river'] ??
        ZoneProgress(
          zoneId: 'memory_river',
          levelsCompleted: 0,
          totalStars: 0,
          bestAccuracy: 0,
          lastPlayedAt: DateTime.now(),
        );

    final updatedZoneProgress = currentZoneProgress.copyWith(
      levelsCompleted: completedCount,
      lastPlayedAt: DateTime.now(),
    );

    await ref
        .read(progressNotifierProvider.notifier)
        .updateZoneProgress('memory_river', updatedZoneProgress);

    // Invalidate providers to ensure UI updates
    ref.invalidate(memoryLevelsProvider);
    ref.invalidate(worldMapProvider);

    // Update state to completed with updated level
    final updatedLevel = state.level!.copyWith(
      isCompleted: true,
      starsEarned: starsEarned > state.level!.starsEarned
          ? starsEarned
          : state.level!.starsEarned,
    );

    state = state.copyWith(
      status: MemoryGameStatus.completed,
      level: updatedLevel,
    );
  }

  /// Calculate stars earned based on performance
  int _calculateStars(int moves, int timeSpent, MemoryLevel level) {
    // Calculate optimal moves (minimum possible)
    final optimalMoves = level.totalPairs;

    // Calculate move efficiency
    final moveEfficiency = optimalMoves / moves;

    // Calculate time efficiency (if time limit exists)
    double timeEfficiency = 1.0;
    if (level.timeLimit > 0) {
      timeEfficiency = 1.0 - (timeSpent / level.timeLimit);
      timeEfficiency = timeEfficiency.clamp(0.0, 1.0);
    }

    // Combined score
    final score = (moveEfficiency * 0.7) + (timeEfficiency * 0.3);

    // Award stars based on score
    if (score >= 0.8) {
      return 3;
    } else if (score >= 0.6) {
      return 2;
    } else if (score >= 0.4) {
      return 1;
    } else {
      return 0;
    }
  }

  /// Reset the game
  void resetGame() {
    _timer?.cancel();
    _flipBackTimer?.cancel();
    state = MemoryGameState.initial();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _flipBackTimer?.cancel();
    super.dispose();
  }
}
