import '../content/token.dart';
import '../l10n/app_localizations.dart';

String shapeName(TokenShape shape, AppLocalizations l) => switch (shape) {
  TokenShape.circle => l.shapeCircle,
  TokenShape.square => l.shapeSquare,
  TokenShape.triangle => l.shapeTriangle,
  TokenShape.star => l.shapeStar,
  TokenShape.heart => l.shapeHeart,
  TokenShape.diamond => l.shapeDiamond,
  TokenShape.hexagon => l.shapeHexagon,
  TokenShape.rectangle => l.shapeRectangle,
};
