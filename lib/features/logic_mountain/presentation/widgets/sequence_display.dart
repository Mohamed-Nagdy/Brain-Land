import 'package:flutter/material.dart';

import '../../models/pattern_problem.dart';
import 'pattern_tile.dart';

/// Widget for displaying a sequence of pattern elements
class SequenceDisplay extends StatelessWidget {
  final List<PatternElement> sequence;
  final int? highlightIndex;

  const SequenceDisplay({
    super.key,
    required this.sequence,
    this.highlightIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Complete the Pattern',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.purple[800],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: List.generate(
              sequence.length,
              (index) => _buildTileWithHighlight(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTileWithHighlight(int index) {
    final element = sequence[index];
    final isPlaceholder =
        element.color == null &&
        element.shape == null &&
        element.number == null &&
        element.size == null;
    final isHighlighted = highlightIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(isHighlighted ? 4 : 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: isHighlighted
            ? Border.all(color: Colors.yellow, width: 3)
            : Border.all(color: Colors.transparent, width: 3),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: Colors.yellow.withValues(alpha: 0.4),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: PatternTile(
        element: element,
        isPlaceholder: isPlaceholder,
        size: 70,
      ),
    );
  }
}
