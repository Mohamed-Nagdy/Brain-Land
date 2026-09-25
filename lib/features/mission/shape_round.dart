import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/shape_chapter.dart';
import '../../core/art.dart';
import '../../core/audio.dart';
import '../../core/lines.dart';
import '../../core/names.dart';
import '../../core/theme.dart';
import '../../l10n/app_localizations.dart';
import 'round.dart';

/// Drag each piece to its home — or tap a piece, then tap a home.
class ShapeRound extends ConsumerStatefulWidget {
  const ShapeRound({
    super.key,
    required this.task,
    required this.hintLevel,
    required this.onEvent,
  });

  final ShapeTask task;

  /// Each hint picks up the next piece and lights up its home.
  final int hintLevel;
  final RoundListener onEvent;

  static const maxHints = 3;

  @override
  ConsumerState<ShapeRound> createState() => _ShapeRoundState();
}

class _ShapeRoundState extends ConsumerState<ShapeRound> {
  /// slot index → piece index placed there.
  final _placed = <int, int>{};
  int? _selected;
  int? _glowSlot;

  ShapeTask get t => widget.task;

  bool _isPlaced(int piece) => _placed.containsValue(piece);

  @override
  void didUpdateWidget(ShapeRound old) {
    super.didUpdateWidget(old);
    if (widget.hintLevel > old.hintLevel) {
      final piece = List.generate(
        t.pieces.length,
        (i) => i,
      ).firstWhere((i) => !_isPlaced(i), orElse: () => -1);
      if (piece < 0) return;
      final slot = List.generate(t.slots.length, (i) => i).firstWhere(
        (s) => !_placed.containsKey(s) && t.pieces[piece].fits(t.slots[s]),
      );
      setState(() {
        _selected = piece;
        _glowSlot = slot;
      });
    }
  }

  void _drop(int piece, int slot) {
    if (_placed.containsKey(slot) || _isPlaced(piece)) return;
    final audio = ref.read(audioProvider);
    if (!t.pieces[piece].fits(t.slots[slot])) {
      audio.play(Sfx.oops);
      setState(() => _selected = null);
      widget.onEvent(const RoundEvent.mistake(Line.mistakeShape));
      return;
    }
    setState(() {
      _placed[slot] = piece;
      _selected = null;
      _glowSlot = null;
    });
    if (_placed.length == t.pieces.length) {
      widget.onEvent(const RoundEvent.solved());
    } else {
      audio.play(Sfx.place);
      widget.onEvent(const RoundEvent.progress());
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final count = t.slots.length;
      final perRow = count <= 3 ? count : (count / 2).ceil();
      final size = min(
        (box.maxWidth - Space.l * 2) / perRow - Space.s,
        box.maxHeight / 5,
      ).clamp(64.0, 140.0);
      return Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(Space.s),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBEBD2),
                  borderRadius: Radii.card,
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: Space.s,
                  runSpacing: Space.s,
                  children: [for (var s = 0; s < count; s++) _slot(s, size)],
                ),
              ),
            ),
          ),
          const SizedBox(height: Space.m),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: Space.s,
            runSpacing: Space.s,
            children: [
              for (var p = 0; p < t.pieces.length; p++) _piece(p, size),
            ],
          ),
          const SizedBox(height: Space.l),
        ],
      );
    },
  );

  Widget _slot(int s, double size) => DragTarget<int>(
    key: ValueKey('slot-$s'),
    onWillAcceptWithDetails: (d) => !_placed.containsKey(s),
    onAcceptWithDetails: (d) => _drop(d.data, s),
    builder: (context, candidates, _) {
      final placed = _placed[s];
      final glow = _glowSlot == s || candidates.isNotEmpty;
      return GestureDetector(
        onTap: _selected == null ? null : () => _drop(_selected!, s),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            borderRadius: Radii.chip,
            border: Border.all(
              color: glow ? Palette.gold : Colors.transparent,
              width: 4,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              TokenArt(t.slots[s], size: size, slot: true),
              if (placed != null) TokenArt(t.pieces[placed], size: size),
            ],
          ),
        ),
      );
    },
  );

  Widget _piece(int p, double size) {
    if (_isPlaced(p)) return SizedBox.square(dimension: size);
    final art = TokenArt(t.pieces[p], size: size);
    final selected = _selected == p;
    return Draggable<int>(
      key: ValueKey('piece-$p'),
      data: p,
      feedback: TokenArt(t.pieces[p], size: size * 1.1),
      childWhenDragging: Opacity(opacity: .25, child: art),
      onDragStarted: () => ref.read(audioProvider).play(Sfx.tap),
      child: Semantics(
        button: true,
        selected: selected,
        label: shapeName(t.pieces[p].shape, AppLocalizations.of(context)),
        excludeSemantics: true,
        child: GestureDetector(
          onTap: () => setState(() => _selected = selected ? null : p),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFFFF0C2) : Colors.transparent,
              borderRadius: Radii.chip,
              border: Border.all(
                color: selected ? Palette.gold : Colors.transparent,
                width: 4,
              ),
            ),
            child: art,
          ),
        ),
      ),
    );
  }
}
