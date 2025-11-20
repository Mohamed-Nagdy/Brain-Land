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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Complete the Pattern',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: isHighlighted ? Border.all(color: Colors.blue, width: 3) : null,
      ),
      child: PatternTile(
        element: element,
        isPlaceholder: isPlaceholder,
        size: 80,
      ),
    );
  }
}
