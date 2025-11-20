import 'package:flutter/material.dart';

import '../../models/pattern_problem.dart';

/// Widget for displaying a single pattern element (color, shape, number, or size)
class PatternTile extends StatelessWidget {
  final PatternElement element;
  final bool isPlaceholder;
  final double size;

  const PatternTile({
    super.key,
    required this.element,
    this.isPlaceholder = false,
    this.size = 80.0,
  });

  @override
  Widget build(BuildContext context) {
    if (isPlaceholder) {
      return _buildPlaceholder();
    }

    // Determine what to display based on element properties
    if (element.color != null && element.shape == null) {
      return _buildColorTile();
    } else if (element.shape != null) {
      return _buildShapeTile();
    } else if (element.number != null) {
      return _buildNumberTile();
    } else if (element.size != null) {
      return _buildSizeTile();
    }

    return _buildPlaceholder();
  }

  /// Build a placeholder tile (question mark)
  Widget _buildPlaceholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text('❓', style: TextStyle(fontSize: size * 0.5)),
      ),
    );
  }

  /// Build a color tile using emojis
  Widget _buildColorTile() {
    String emoji;
    switch (element.color!) {
      case PatternColor.red:
        emoji = '🔴';
        break;
      case PatternColor.blue:
        emoji = '🔵';
        break;
      case PatternColor.green:
        emoji = '🟢';
        break;
      case PatternColor.yellow:
        emoji = '🟡';
        break;
      case PatternColor.purple:
        emoji = '🟣';
        break;
      case PatternColor.orange:
        emoji = '🟠';
        break;
    }

    return _buildEmojiContainer(emoji);
  }

  /// Build a shape tile using emojis
  Widget _buildShapeTile() {
    String emoji;
    switch (element.shape!) {
      case PatternShape.circle:
        emoji = '🟣'; // Purple circle as default shape
        break;
      case PatternShape.square:
        emoji = '🟩'; // Green square
        break;
      case PatternShape.triangle:
        emoji = '🔺'; // Red triangle
        break;
      case PatternShape.star:
        emoji = '⭐'; // Star
        break;
      case PatternShape.heart:
        emoji = '❤️'; // Heart
        break;
      case PatternShape.diamond:
        emoji = '🔷'; // Diamond
        break;
    }

    return _buildEmojiContainer(emoji);
  }

  /// Build a number tile
  Widget _buildNumberTile() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange[300]!, Colors.orange[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '${element.number}',
          style: TextStyle(
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.2),
                offset: const Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build a size tile (circle with varying size)
  Widget _buildSizeTile() {
    final scale = 0.4 + (element.size! * 0.15); // Scale from 0.55 to 1.15

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      child: Transform.scale(
        scale: scale,
        child: const Text(
          '🟣',
          style: TextStyle(fontSize: 40), // Base size
        ),
      ),
    );
  }

  /// Helper to build a container for the emoji
  Widget _buildEmojiContainer(String emoji) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(
            fontSize: size * 0.7,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.2),
                offset: const Offset(0, 4),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
