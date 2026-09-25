import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/art.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';
import 'shake.dart';

enum ChoiceState { idle, right, tried, hidden }

/// A large answer tile. Wrong tries wobble and fade; the right one turns green.
class ChoiceTile extends ConsumerWidget {
  const ChoiceTile({
    super.key,
    required this.child,
    required this.state,
    required this.onTap,
    required this.semanticLabel,
    this.size = 84,
    this.shakes = 0,
  });

  final Widget child;
  final ChoiceState state;
  final VoidCallback onTap;
  final String semanticLabel;
  final double size;
  final int shakes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state == ChoiceState.hidden) return SizedBox.square(dimension: size);
    final right = state == ChoiceState.right;
    return Semantics(
      button: true,
      label: semanticLabel,
      enabled: state == ChoiceState.idle,
      excludeSemantics: true,
      child: Shake(
        trigger: shakes,
        child: AnimatedOpacity(
          duration: motion(context, ref, 200),
          opacity: state == ChoiceState.tried ? .35 : 1,
          child: GestureDetector(
            onTap: state == ChoiceState.idle ? onTap : null,
            child: AnimatedContainer(
              duration: motion(context, ref, 160),
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: right ? const Color(0xFFE3F6E7) : Colors.white,
                borderRadius: Radii.card,
                border: Border.all(
                  color: right ? Palette.good : const Color(0x332E2240),
                  width: right ? 4 : 2,
                ),
                boxShadow: const [
                  BoxShadow(color: Color(0x332E2240), offset: Offset(0, 4)),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  child,
                  if (right)
                    const PositionedDirectional(
                      top: 2,
                      end: 2,
                      child: GameIcon(Ico.check, size: 26),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A number written large, in the chosen digit style.
class NumberText extends StatelessWidget {
  const NumberText(
    this.text, {
    super.key,
    this.size = 40,
    this.color = Palette.ink,
  });

  final String text;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Text(
    text,
    textDirection: TextDirection.ltr,
    style: Theme.of(context).textTheme.displaySmall?.copyWith(
      fontSize: size,
      color: color,
      height: 1.1,
    ),
  );
}
