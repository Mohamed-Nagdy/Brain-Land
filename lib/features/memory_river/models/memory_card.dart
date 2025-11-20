import 'package:equatable/equatable.dart';

/// Enum representing the state of a memory card
enum CardState { faceDown, faceUp, matched }

/// Model representing a memory card in the Memory River game
class MemoryCard extends Equatable {
  final String id;
  final String pairId; // Cards with same pairId are matches
  final String imageAsset; // Path to the card image
  final CardState state;
  final int position; // Position in the grid

  const MemoryCard({
    required this.id,
    required this.pairId,
    required this.imageAsset,
    this.state = CardState.faceDown,
    required this.position,
  });

  /// Check if this card matches another card
  bool matches(MemoryCard other) {
    return pairId == other.pairId && id != other.id;
  }

  /// Check if the card is face up
  bool get isFaceUp => state == CardState.faceUp || state == CardState.matched;

  /// Check if the card is matched
  bool get isMatched => state == CardState.matched;

  /// Create a copy with modified fields
  MemoryCard copyWith({
    String? id,
    String? pairId,
    String? imageAsset,
    CardState? state,
    int? position,
  }) {
    return MemoryCard(
      id: id ?? this.id,
      pairId: pairId ?? this.pairId,
      imageAsset: imageAsset ?? this.imageAsset,
      state: state ?? this.state,
      position: position ?? this.position,
    );
  }

  @override
  List<Object?> get props => [id, pairId, imageAsset, state, position];
}
