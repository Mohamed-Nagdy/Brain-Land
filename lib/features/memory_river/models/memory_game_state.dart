import 'package:equatable/equatable.dart';

import 'memory_card.dart';
import 'memory_level.dart';

/// Enum representing the status of the memory game
enum MemoryGameStatus { initial, loading, playing, paused, completed, error }

/// State for the Memory River game
class MemoryGameState extends Equatable {
  final MemoryGameStatus status;
  final MemoryLevel? level;
  final List<MemoryCard> cards;
  final MemoryCard? firstSelectedCard;
  final MemoryCard? secondSelectedCard;
  final int moves;
  final int matchedPairs;
  final int timeRemaining;
  final DateTime? startTime;
  final String? errorMessage;

  const MemoryGameState({
    required this.status,
    this.level,
    this.cards = const [],
    this.firstSelectedCard,
    this.secondSelectedCard,
    this.moves = 0,
    this.matchedPairs = 0,
    this.timeRemaining = 0,
    this.startTime,
    this.errorMessage,
  });

  /// Create initial state
  factory MemoryGameState.initial() {
    return const MemoryGameState(status: MemoryGameStatus.initial);
  }

  /// Create loading state
  factory MemoryGameState.loading() {
    return const MemoryGameState(status: MemoryGameStatus.loading);
  }

  /// Create error state
  factory MemoryGameState.error(String message) {
    return MemoryGameState(
      status: MemoryGameStatus.error,
      errorMessage: message,
    );
  }

  /// Check if all pairs are matched
  bool get isComplete => level != null && matchedPairs >= level!.totalPairs;

  /// Check if two cards are currently selected
  bool get hasTwoCardsSelected =>
      firstSelectedCard != null && secondSelectedCard != null;

  /// Check if one card is currently selected
  bool get hasOneCardSelected =>
      firstSelectedCard != null && secondSelectedCard == null;

  /// Get the time spent in seconds
  int get timeSpent {
    if (startTime == null) return 0;
    return DateTime.now().difference(startTime!).inSeconds;
  }

  /// Get all face-down cards
  List<MemoryCard> get faceDownCards =>
      cards.where((card) => card.state == CardState.faceDown).toList();

  /// Get all matched cards
  List<MemoryCard> get matchedCards =>
      cards.where((card) => card.state == CardState.matched).toList();

  /// Create a copy with modified fields
  MemoryGameState copyWith({
    MemoryGameStatus? status,
    MemoryLevel? level,
    List<MemoryCard>? cards,
    MemoryCard? firstSelectedCard,
    MemoryCard? secondSelectedCard,
    bool clearFirstSelected = false,
    bool clearSecondSelected = false,
    int? moves,
    int? matchedPairs,
    int? timeRemaining,
    DateTime? startTime,
    String? errorMessage,
  }) {
    return MemoryGameState(
      status: status ?? this.status,
      level: level ?? this.level,
      cards: cards ?? this.cards,
      firstSelectedCard: clearFirstSelected
          ? null
          : (firstSelectedCard ?? this.firstSelectedCard),
      secondSelectedCard: clearSecondSelected
          ? null
          : (secondSelectedCard ?? this.secondSelectedCard),
      moves: moves ?? this.moves,
      matchedPairs: matchedPairs ?? this.matchedPairs,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      startTime: startTime ?? this.startTime,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    level,
    cards,
    firstSelectedCard,
    secondSelectedCard,
    moves,
    matchedPairs,
    timeRemaining,
    startTime,
    errorMessage,
  ];
}
