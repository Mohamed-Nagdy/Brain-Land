import 'token.dart';

/// One sorting board: drag every piece to the slot it fits.
class ShapeTask {
  ShapeTask(String pieces, String slots)
    : pieces = [for (final c in pieces.split(' ')) Token.parse(c)],
      slots = [for (final c in slots.split(' ')) Token.parse(c)];

  ShapeTask.of(this.pieces, this.slots);

  final List<Token> pieces;

  /// Slot outlines (their colour is ignored).
  final List<Token> slots;
}

/// Shape Valley, chapter 1: basic shapes, then more shapes, turned shapes,
/// big and small, and look-alikes (square vs diamond vs rectangle).
final shapeChapter = <List<ShapeTask>>[
  // 1 · Circle, square, triangle
  [ShapeTask('rC bS yT', 'bT bC bS'), ShapeTask('gS oT pC', 'bC bS bT')],
  // 2 · Add the star
  [
    ShapeTask('yR rC gT bS', 'bS bR bC bT'),
    ShapeTask('pT oR bC rS', 'bR bT bS bC'),
  ],
  // 3 · Hearts and diamonds
  [
    ShapeTask('rH bD gC yS', 'bD bS bH bC'),
    ShapeTask('pD oH yT gR', 'bH bR bD bT'),
  ],
  // 4 · Hexagons and long rectangles
  [
    ShapeTask('bX oW rT gS', 'bS bX bT bW'),
    ShapeTask('yW pX gC rR', 'bC bW bR bX'),
  ],
  // 5 · Five at once
  [
    ShapeTask('rC bS yT gR pH', 'bH bT bC bR bS'),
    ShapeTask('oD gX bW rT yC', 'bW bC bD bX bT'),
  ],
  // 6 · Turned shapes
  [
    ShapeTask('rT@180 bR@36 gH yX@30', 'bX@30 bT@180 bH bR@36'),
    ShapeTask('oT@90 pH@180 bW@90 gC', 'bC bW@90 bT@90 bH@180'),
  ],
  // 7 · Big and small
  [
    ShapeTask('rC+ bC- yS+ gS-', 'bS- bC+ bS+ bC-'),
    ShapeTask('pT- oT+ gR+ bR-', 'bR- bT+ bR+ bT-'),
  ],
  // 8 · Look-alikes
  [
    ShapeTask('rS bD yW gX', 'bW bS bX bD'),
    ShapeTask('oC pX bS gD', 'bD bC bS bX'),
  ],
  // 9 · Six pieces
  [
    ShapeTask('rC bS yT gR pH oD', 'bD bR bC bH bT bS'),
    ShapeTask('bX gW rT+ yT- pC oS', 'bT- bS bX bC bT+ bW'),
  ],
  // 10 · Valley challenge
  [
    ShapeTask('rT@90 bS- yD gW@90 pR+ oH@180', 'bR+ bW@90 bH@180 bT@90 bD bS-'),
    ShapeTask('gC- yX@30 bT+ rS pH- oR@36', 'bS bH- bR@36 bC- bT+ bX@30'),
  ],
];
