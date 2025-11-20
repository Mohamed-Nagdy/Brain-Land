import 'package:flutter/material.dart';

import '../../../../shared/models/reward.dart';

/// ChestAnimation widget displays an animated treasure chest
/// with shake, bounce, and opening animations
class ChestAnimation extends StatefulWidget {
  final ChestType chestType;
  final bool isOpening;
  final bool isOpened;
  final VoidCallback? onTap;
  final VoidCallback? onOpeningComplete;

  const ChestAnimation({
    super.key,
    required this.chestType,
    this.isOpening = false,
    this.isOpened = false,
    this.onTap,
    this.onOpeningComplete,
  });

  @override
  State<ChestAnimation> createState() => _ChestAnimationState();
}

class _ChestAnimationState extends State<ChestAnimation>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late AnimationController _bounceController;
  late AnimationController _openController;
  late AnimationController _glowController;

  late Animation<double> _shakeAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _openAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Shake animation (idle state)
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _shakeAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.02), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 0.02, end: -0.02), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -0.02, end: 0.02), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 0.02, end: 0.0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
        );

    // Bounce animation (on tap)
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _bounceAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.9), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.1), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
        );

    // Open animation (lid opening)
    _openController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _openAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _openController, curve: Curves.easeOutBack),
    );

    // Glow animation (pulsing glow)
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Start idle animations
    if (!widget.isOpened) {
      _shakeController.repeat();
      _glowController.repeat(reverse: true);
    }

    // Listen for opening complete
    _openController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onOpeningComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(ChestAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle opening state change
    if (widget.isOpening && !oldWidget.isOpening) {
      _startOpening();
    }

    // Handle opened state change
    if (widget.isOpened && !oldWidget.isOpened) {
      _shakeController.stop();
      _glowController.stop();
    }
  }

  void _startOpening() {
    _shakeController.stop();
    _bounceController.forward(from: 0).then((_) {
      _openController.forward();
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _bounceController.dispose();
    _openController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Color _getChestColor() {
    switch (widget.chestType) {
      case ChestType.bronze:
        return const Color(0xFFCD7F32);
      case ChestType.silver:
        return const Color(0xFFC0C0C0);
      case ChestType.gold:
        return const Color(0xFFFFD700);
      case ChestType.special:
        return const Color(0xFFFF1493); // Deep pink for special
    }
  }

  Gradient _getChestGradient() {
    final baseColor = _getChestColor();
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        baseColor.withValues(alpha: 0.8),
        baseColor,
        baseColor.withValues(alpha: 0.6),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isOpened
          ? null
          : () {
              if (!widget.isOpening) {
                _bounceController.forward(from: 0);
                widget.onTap?.call();
              }
            },
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _shakeController,
          _bounceController,
          _openController,
          _glowController,
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale: _bounceAnimation.value,
            child: Transform.rotate(
              angle: _shakeAnimation.value,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Glow effect
                  if (!widget.isOpened)
                    Container(
                      width: 200 + (20 * _glowAnimation.value),
                      height: 200 + (20 * _glowAnimation.value),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _getChestColor().withValues(
                              alpha: 0.3 * _glowAnimation.value,
                            ),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),

                  // Chest body
                  Container(
                    width: 180,
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: _getChestGradient(),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getChestColor().withValues(alpha: 0.5),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Lock decoration
                        if (!widget.isOpened)
                          Center(
                            child: Container(
                              width: 40,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.amber.shade700,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.lock,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Chest lid (opens upward)
                  Transform.translate(
                    offset: Offset(0, -70 - (_openAnimation.value * 50)),
                    child: Transform.rotate(
                      angle: -_openAnimation.value * 0.5,
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: 180,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: _getChestGradient(),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          border: Border.all(
                            color: _getChestColor().withValues(alpha: 0.5),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Sparkles when opening
                  if (widget.isOpening || widget.isOpened)
                    ...List.generate(8, (index) {
                      final angle = (index * 45) * (3.14159 / 180);
                      final distance = 80 + (_openAnimation.value * 40);
                      return Transform.translate(
                        offset: Offset(
                          distance *
                              (index % 2 == 0 ? 1 : -1) *
                              _openAnimation.value,
                          -distance * _openAnimation.value,
                        ),
                        child: Opacity(
                          opacity: 1.0 - _openAnimation.value,
                          child: Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 20 + (_openAnimation.value * 10),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Simple chest icon for display in lists
class ChestIcon extends StatelessWidget {
  final ChestType chestType;
  final double size;

  const ChestIcon({super.key, required this.chestType, this.size = 60});

  Color _getChestColor() {
    switch (chestType) {
      case ChestType.bronze:
        return const Color(0xFFCD7F32);
      case ChestType.silver:
        return const Color(0xFFC0C0C0);
      case ChestType.gold:
        return const Color(0xFFFFD700);
      case ChestType.special:
        return const Color(0xFFFF1493);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_getChestColor().withValues(alpha: 0.8), _getChestColor()],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getChestColor().withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.card_giftcard, color: Colors.white, size: 30),
    );
  }
}
