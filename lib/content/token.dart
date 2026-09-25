import 'package:flutter/widgets.dart';

enum TokenShape {
  circle,
  square,
  triangle,
  star,
  heart,
  diamond,
  hexagon,
  rectangle,
}

enum TokenColor {
  red(Color(0xFFF2545B)),
  blue(Color(0xFF3B8BEB)),
  yellow(Color(0xFFFFC83D)),
  green(Color(0xFF3FAE5A)),
  purple(Color(0xFF9B6CE8)),
  orange(Color(0xFFFF8A4C));

  const TokenColor(this.value);
  final Color value;
}

enum TokenSize {
  small(.62),
  medium(.82),
  large(1.0);

  const TokenSize(this.scale);
  final double scale;
}

/// A coloured shape (or a number bubble) used by Logic Mountain and Shape Valley.
///
/// Written compactly in content files as a code:
/// colour letter `r b y g p o`, shape letter `C S T R(star) H D X(hexagon) W(wide rectangle)`,
/// optional size `-` (small) / `+` (large), optional rotation `@90`.
/// Number bubbles are `n` followed by the value, e.g. `n7`.
@immutable
class Token {
  const Token({
    this.shape = TokenShape.circle,
    this.color = TokenColor.blue,
    this.size = TokenSize.medium,
    this.turns = 0,
    this.number,
  });

  final TokenShape shape;
  final TokenColor color;
  final TokenSize size;

  /// Rotation in degrees.
  final int turns;
  final int? number;

  bool get isNumber => number != null;

  factory Token.parse(String code) {
    if (code.startsWith('n')) {
      return Token(number: int.parse(code.substring(1)));
    }
    final at = code.indexOf('@');
    final body = at < 0 ? code : code.substring(0, at);
    final turns = at < 0 ? 0 : int.parse(code.substring(at + 1));
    final size = body.endsWith('-')
        ? TokenSize.small
        : body.endsWith('+')
        ? TokenSize.large
        : TokenSize.medium;
    return Token(
      color: _colors[body[0]]!,
      shape: _shapes[body[1]]!,
      size: size,
      turns: turns,
    );
  }

  /// Whether this piece fits a slot: same outline, size and rotation (colour is free).
  bool fits(Token slot) =>
      shape == slot.shape && size == slot.size && turns == slot.turns;

  static const _colors = {
    'r': TokenColor.red,
    'b': TokenColor.blue,
    'y': TokenColor.yellow,
    'g': TokenColor.green,
    'p': TokenColor.purple,
    'o': TokenColor.orange,
  };
  static const _shapes = {
    'C': TokenShape.circle,
    'S': TokenShape.square,
    'T': TokenShape.triangle,
    'R': TokenShape.star,
    'H': TokenShape.heart,
    'D': TokenShape.diamond,
    'X': TokenShape.hexagon,
    'W': TokenShape.rectangle,
  };

  @override
  bool operator ==(Object other) =>
      other is Token &&
      other.shape == shape &&
      other.color == color &&
      other.size == size &&
      other.turns == turns &&
      other.number == number;

  @override
  int get hashCode => Object.hash(shape, color, size, turns, number);

  @override
  String toString() =>
      isNumber ? 'n$number' : '${color.name}-${shape.name}-${size.name}@$turns';
}
