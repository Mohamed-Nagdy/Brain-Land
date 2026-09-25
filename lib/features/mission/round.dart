import '../../core/lines.dart';

enum RoundEventKind {
  /// A step went right but the board is not finished (a pair, a placed shape).
  progress,

  /// A wrong try; [RoundEvent.line] names the likely mistake.
  mistake,

  /// The item is finished.
  solved,
}

class RoundEvent {
  const RoundEvent.progress() : kind = RoundEventKind.progress, line = null;
  const RoundEvent.mistake(Line this.line) : kind = RoundEventKind.mistake;
  const RoundEvent.solved() : kind = RoundEventKind.solved, line = null;

  final RoundEventKind kind;
  final Line? line;
}

typedef RoundListener = void Function(RoundEvent event);

/// Stars from mistakes: within the allowance → 3, a few more → 2, otherwise 1.
/// Finishing always earns at least one star; nobody fails a mission.
int starsFor(int mistakes, int allowance) {
  if (mistakes <= allowance) return 3;
  if (mistakes <= allowance * 2 + 1) return 2;
  return 1;
}
