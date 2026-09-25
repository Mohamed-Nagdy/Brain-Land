import 'token.dart';

/// One "what comes next / what is missing" pattern. `?` marks the gap.
class PatternTask {
  /// [options] lists the answer first; the display order is rotated
  /// deterministically so the answer is not always in the same place.
  factory PatternTask(String sequence, String options, {required int unit}) {
    final cells = [
      for (final c in sequence.split(' ')) c == '?' ? null : Token.parse(c),
    ];
    final listed = [for (final c in options.split(' ')) Token.parse(c)];
    return PatternTask.of(cells, listed, unit: unit);
  }

  PatternTask.of(this.cells, List<Token> listed, {required this.unit})
    : answer = listed.first,
      choices = _rotate(listed, cells.length + cells.indexOf(null));

  /// The sequence; `null` is the gap.
  final List<Token?> cells;
  final Token answer;

  /// Choices in display order.
  final List<Token> choices;

  /// Length of the repeating unit (for number patterns: the step).
  final int unit;

  int get gap => cells.indexOf(null);
  bool get isNumbers => answer.isNumber;

  static List<Token> _rotate(List<Token> list, int by) {
    final r = by % list.length;
    return [...list.sublist(r), ...list.sublist(0, r)];
  }
}

/// Logic Mountain, chapter 1: AB colour and shape patterns, AAB/ABB/ABC,
/// growing sizes, gaps in the middle and simple number steps.
final logicChapter = <List<PatternTask>>[
  // 1 · Two colours
  [
    PatternTask('rC bC rC bC rC ?', 'bC rC yC', unit: 2),
    PatternTask('yC gC yC gC yC ?', 'gC yC pC', unit: 2),
    PatternTask('pC oC pC oC ?', 'pC oC bC', unit: 2),
    PatternTask('bC yC bC yC bC ?', 'yC bC rC', unit: 2),
    PatternTask('gC rC gC rC ?', 'gC rC oC', unit: 2),
  ],
  // 2 · Two shapes
  [
    PatternTask('gT gS gT gS gT ?', 'gS gT gC', unit: 2),
    PatternTask('bC bR bC bR ?', 'bC bR bH', unit: 2),
    PatternTask('oH oS oH oS oH ?', 'oS oH oD', unit: 2),
    PatternTask('pD pC pD pC ?', 'pD pC pT', unit: 2),
    PatternTask('rS rT rS rT rS ?', 'rT rS rR', unit: 2),
  ],
  // 3 · Colour and shape together
  [
    PatternTask('yR pH yR pH ?', 'yR pR yH', unit: 2),
    PatternTask('bS oC bS oC bS ?', 'oC bC oS', unit: 2),
    PatternTask('gT rD gT rD ?', 'gT rT gD', unit: 2),
    PatternTask('pC yS pC yS pC ?', 'yS pS yC', unit: 2),
    PatternTask('rH bR rH bR ?', 'rH bH rR', unit: 2),
  ],
  // 4 · AAB
  [
    PatternTask('rC rC bS rC rC bS rC ?', 'rC bS bC', unit: 3),
    PatternTask('yT yT gC yT yT gC ?', 'yT gC gT', unit: 3),
    PatternTask('pS pS oR pS pS ?', 'oR pS oS', unit: 3),
    PatternTask('bH bH yD bH bH yD bH ?', 'bH yD yH', unit: 3),
    PatternTask('gC gC rT gC gC ?', 'rT gC rC', unit: 3),
  ],
  // 5 · ABB
  [
    PatternTask('oC bS bS oC bS bS oC ?', 'bS oC oS', unit: 3),
    PatternTask('rT yC yC rT yC ?', 'yC rT rC', unit: 3),
    PatternTask('gR pH pH gR pH pH ?', 'gR pH pR', unit: 3),
    PatternTask('bD oS oS bD ?', 'oS bD bS', unit: 3),
    PatternTask('yH gT gT yH gT ?', 'gT yH yT', unit: 3),
  ],
  // 6 · ABC
  [
    PatternTask('rC yC bC rC yC ?', 'bC rC gC', unit: 3),
    PatternTask('gS gT gC gS gT ?', 'gC gS gR', unit: 3),
    PatternTask('pR oH bD pR oH ?', 'bD pR oD', unit: 3),
    PatternTask('yT rT gT yT ?', 'rT gT yT', unit: 3),
    PatternTask('bC oS pT bC oS pT ?', 'bC pT oC', unit: 3),
  ],
  // 7 · Growing sizes
  [
    PatternTask('bC- bC bC+ bC- bC ?', 'bC+ bC- bC', unit: 3),
    PatternTask('rS- rS+ rS- rS+ rS- ?', 'rS+ rS- rS', unit: 2),
    PatternTask('gT+ gT gT- gT+ gT ?', 'gT- gT+ gT', unit: 3),
    PatternTask('yR- yR yR+ yR- ?', 'yR yR+ yR-', unit: 3),
    PatternTask('pH+ pH- pH+ pH- ?', 'pH+ pH- pH', unit: 2),
  ],
  // 8 · The gap is in the middle
  [
    PatternTask('rT gT ? gT rT gT', 'rT gT bT', unit: 2),
    PatternTask('bS bS yC ? bS yC', 'bS yC yS', unit: 3),
    PatternTask('oC ? oC pR oC pR', 'pR oR pC', unit: 2),
    PatternTask('gH yD rC gH ? rC', 'yD gD yH', unit: 3),
    PatternTask('pS- pS+ pS- ? pS-', 'pS+ pS- pS', unit: 2),
  ],
  // 9 · Number steps
  [
    PatternTask('n1 n2 n3 n4 ?', 'n5 n6 n4', unit: 1),
    PatternTask('n2 n4 n6 ?', 'n8 n7 n10', unit: 2),
    PatternTask('n5 n4 n3 ?', 'n2 n1 n6', unit: -1),
    PatternTask('n3 n5 n7 ?', 'n9 n8 n10', unit: 2),
    PatternTask('n10 n9 n8 n7 ?', 'n6 n5 n8', unit: -1),
  ],
  // 10 · Mountain top challenge
  [
    PatternTask('rC rC bS bS rC rC bS ?', 'bS rC bC', unit: 4),
    PatternTask('yT gS pC yT gS ?', 'pC yC pS', unit: 3),
    PatternTask('n2 n4 ? n8 n10', 'n6 n5 n7', unit: 2),
    PatternTask('oR- oR oR+ ? oR oR+', 'oR- oR+ oR', unit: 3),
    PatternTask('bH rH bD rD bH rH ? rD', 'bD rD bH', unit: 4),
  ],
];
