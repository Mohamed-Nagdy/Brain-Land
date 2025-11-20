import 'package:flutter/material.dart';

import '../../../../shared/models/pet.dart';

/// Widget to display a pet with idle animation
class PetDisplay extends StatefulWidget {
  final Pet pet;
  final double size;
  final bool showAnimation;

  const PetDisplay({
    super.key,
    required this.pet,
    this.size = 80.0,
    this.showAnimation = true,
  });

  @override
  State<PetDisplay> createState() => _PetDisplayState();
}

class _PetDisplayState extends State<PetDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Gentle breathing/pulsing animation
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Subtle bounce animation
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: -5.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.showAnimation) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PetDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showAnimation != oldWidget.showAnimation) {
      if (widget.showAnimation) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.pet.isUnlocked) {
      return _buildLockedPet();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: Transform.scale(scale: _scaleAnimation.value, child: child),
        );
      },
      child: _buildPetContent(),
    );
  }

  Widget _buildPetContent() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: _getPetGradient(),
        boxShadow: [
          BoxShadow(
            color: _getPetColor().withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(child: _buildPetIcon()),
    );
  }

  Widget _buildPetIcon() {
    // For now, use emoji icons until actual pet sprites are added
    final icon = _getPetEmoji();
    return Text(icon, style: TextStyle(fontSize: widget.size * 0.5));
  }

  Widget _buildLockedPet() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade300,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.lock,
          size: widget.size * 0.4,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  String _getPetEmoji() {
    switch (widget.pet.type) {
      case PetType.dragon:
        return '🐉';
      case PetType.unicorn:
        return '🦄';
      case PetType.phoenix:
        return '🔥';
      case PetType.owl:
        return '🦉';
      case PetType.fox:
        return '🦊';
      case PetType.bunny:
        return '🐰';
      case PetType.panda:
        return '🐼';
      case PetType.robot:
        return '🤖';
    }
  }

  Color _getPetColor() {
    switch (widget.pet.type) {
      case PetType.dragon:
        return Colors.red;
      case PetType.unicorn:
        return Colors.purple;
      case PetType.phoenix:
        return Colors.orange;
      case PetType.owl:
        return Colors.brown;
      case PetType.fox:
        return Colors.deepOrange;
      case PetType.bunny:
        return Colors.pink;
      case PetType.panda:
        return Colors.black;
      case PetType.robot:
        return Colors.blue;
    }
  }

  LinearGradient _getPetGradient() {
    final color = _getPetColor();
    return LinearGradient(
      colors: [color.withValues(alpha: 0.7), color],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}

/// Compact pet display for world map companion
class CompactPetDisplay extends StatelessWidget {
  final Pet pet;
  final double size;

  const CompactPetDisplay({super.key, required this.pet, this.size = 40.0});

  @override
  Widget build(BuildContext context) {
    return PetDisplay(pet: pet, size: size, showAnimation: true);
  }
}
