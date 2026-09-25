import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../content/token.dart';

/// Every picture in the game comes from the custom SVG library in
/// `assets/svg/` — no emoji and no stock icon sets.
enum Ico {
  play,
  back,
  next,
  home,
  pause,
  parents,
  soundOn('sound_on'),
  soundOff('sound_off'),
  voiceOn('voice_on'),
  voiceOff('voice_off'),
  hint,
  retry,
  starFull('star_full'),
  starEmpty('star_empty'),
  lock,
  check,
  close,
  motion,
  language,
  speaker,
  digits,
  trash,
  info;

  const Ico([this._file]);
  final String? _file;

  String get path => 'assets/svg/ui/${_file ?? name}.svg';
}

/// Arrows follow reading direction: "back" points right in Arabic.
bool _flipsInRtl(Ico icon) => icon == Ico.back || icon == Ico.next;

class GameIcon extends StatelessWidget {
  const GameIcon(this.icon, {super.key, this.size = 40});

  final Ico icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final picture = SvgPicture.asset(icon.path, width: size, height: size);
    if (_flipsInRtl(icon) && Directionality.of(context) == TextDirection.rtl) {
      return Transform.flip(flipX: true, child: picture);
    }
    return picture;
  }
}

enum Mood { idle, happy, oops, cheer, sleep, point, wave }

class Mascot extends StatelessWidget {
  const Mascot(this.mood, {super.key, this.size = 120});

  final Mood mood;
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SvgPicture.asset(
      'assets/svg/mascot/mascot_${mood.name}.svg',
      width: size,
      height: size,
    ),
  );
}

/// Any other artwork file by path (world scenes, trophies, counters, cards).
class Art extends StatelessWidget {
  const Art(
    this.path, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) =>
      SvgPicture.asset(path, width: width, height: height, fit: fit);
}

/// A coloured shape piece, or the empty "home" slot it belongs in.
class TokenArt extends StatelessWidget {
  const TokenArt(this.token, {super.key, this.size = 64, this.slot = false});

  final Token token;
  final double size;
  final bool slot;

  @override
  Widget build(BuildContext context) {
    final file =
        'assets/svg/${slot ? 'slots' : 'tokens'}/${token.shape.name}.svg';
    final picture = SvgPicture(
      SvgAssetLoader(file, colorMapper: _TokenColor(token.color.value)),
    );
    return SizedBox.square(
      dimension: size,
      child: Center(
        child: SizedBox.square(
          dimension: size * token.size.scale,
          child: Transform.rotate(
            angle: token.turns * 3.1415926535 / 180,
            child: picture,
          ),
        ),
      ),
    );
  }
}

/// Token SVGs are drawn with the placeholder fill #C0FFEE.
class _TokenColor extends ColorMapper {
  const _TokenColor(this.color);

  final Color color;
  static const _placeholder = Color(0xFFC0FFEE);

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) => color.withValues(alpha: 1) == _placeholder
      ? this.color.withValues(alpha: color.a)
      : color;

  @override
  bool operator ==(Object other) =>
      other is _TokenColor && other.color == color;

  @override
  int get hashCode => color.hashCode;
}
