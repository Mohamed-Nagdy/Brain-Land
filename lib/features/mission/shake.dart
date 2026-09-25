import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion.dart';

/// A short sideways wobble for wrong answers. Change [trigger] to play it.
/// Under reduced motion nothing moves (the feedback text and sound remain).
class Shake extends ConsumerStatefulWidget {
  const Shake({super.key, required this.trigger, required this.child});

  final int trigger;
  final Widget child;

  @override
  ConsumerState<Shake> createState() => _ShakeState();
}

class _ShakeState extends ConsumerState<Shake>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void didUpdateWidget(Shake old) {
    super.didUpdateWidget(old);
    if (old.trigger != widget.trigger && !reducedMotion(context, ref)) {
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (context, child) => Transform.translate(
      offset: Offset(sin(_c.value * pi * 5) * 10 * (1 - _c.value), 0),
      child: child,
    ),
    child: widget.child,
  );
}
