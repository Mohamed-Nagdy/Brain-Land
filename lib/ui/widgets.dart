import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/art.dart';
import '../core/audio.dart';
import '../core/motion.dart';
import '../core/theme.dart';

/// A chunky pill button with a custom icon; sinks slightly when pressed.
class GameButton extends ConsumerStatefulWidget {
  const GameButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color = Palette.purple,
    this.foreground = Colors.white,
  });

  final String label;
  final Ico? icon;
  final Color color;
  final Color foreground;
  final VoidCallback? onPressed;

  @override
  ConsumerState<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends ConsumerState<GameButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final depth = _down ? 1.0 : 5.0;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapCancel: () => setState(() => _down = false),
        onTapUp: enabled
            ? (_) {
                setState(() => _down = false);
                ref.read(audioProvider).play(Sfx.tap);
                widget.onPressed!();
              }
            : null,
        child: AnimatedContainer(
          duration: motion(context, ref, 90),
          constraints: const BoxConstraints(minHeight: 64, minWidth: 120),
          margin: EdgeInsets.only(top: 5 - depth),
          padding: const EdgeInsets.symmetric(
            horizontal: Space.l,
            vertical: Space.s,
          ),
          decoration: BoxDecoration(
            color: enabled
                ? widget.color
                : Palette.inkSoft.withValues(alpha: .3),
            borderRadius: Radii.button,
            boxShadow: [
              BoxShadow(
                color: Color.lerp(widget.color, Colors.black, .35)!,
                offset: Offset(0, depth),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                GameIcon(widget.icon!, size: 36),
                const SizedBox(width: Space.s),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: widget.foreground),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Round icon-only button with an accessible label.
class IconBubble extends ConsumerWidget {
  const IconBubble(
    this.icon, {
    super.key,
    required this.label,
    required this.onPressed,
    this.size,
  });

  final Ico icon;
  final String label;
  final VoidCallback onPressed;
  final double? size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final side = (size ?? kTouchTarget);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(
          side: BorderSide(color: Color(0x1A2E2240), width: 2),
        ),
        elevation: 2,
        shadowColor: Colors.black26,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            ref.read(audioProvider).play(Sfx.tap);
            onPressed();
          },
          child: SizedBox.square(
            dimension: side,
            child: Center(child: GameIcon(icon, size: side * .64)),
          ),
        ),
      ),
    );
  }
}

class StarRow extends StatelessWidget {
  const StarRow(this.count, {super.key, this.size = 22, this.label});

  final int count;
  final double size;
  final String? label;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    excludeSemantics: true,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          GameIcon(i < count ? Ico.starFull : Ico.starEmpty, size: size),
      ],
    ),
  );
}

/// The mascot with a speech bubble; the speaker button replays the voice line.
class MascotSays extends StatelessWidget {
  const MascotSays({
    super.key,
    required this.mood,
    required this.text,
    this.onReplay,
    this.replayLabel,
    this.mascotSize = 96,
  });

  final Mood mood;
  final String text;
  final VoidCallback? onReplay;
  final String? replayLabel;
  final double mascotSize;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Mascot(mood, size: mascotSize),
      const SizedBox(width: Space.s),
      Expanded(
        child: Container(
          margin: const EdgeInsets.only(bottom: Space.m),
          padding: const EdgeInsetsDirectional.fromSTEB(
            Space.m,
            Space.s,
            Space.s,
            Space.s,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: Radii.card,
            boxShadow: [
              BoxShadow(
                color: Color(0x222E2240),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              if (onReplay != null)
                IconBubble(
                  Ico.speaker,
                  label: replayLabel ?? '',
                  onPressed: onReplay!,
                  size: 48,
                ),
            ],
          ),
        ),
      ),
    ],
  );
}

/// Screen background: a soft full-bleed scene behind the content.
class SceneBackground extends StatelessWidget {
  const SceneBackground({
    super.key,
    required this.child,
    this.scene = 'assets/svg/worlds/map_bg.svg',
    this.veil = 0,
  });

  final Widget child;
  final String scene;

  /// 0–1 white veil so busy scenes don't compete with the puzzle.
  final double veil;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      Art(scene, fit: BoxFit.cover),
      if (veil > 0) ColoredBox(color: Palette.paper.withValues(alpha: veil)),
      child,
    ],
  );
}
