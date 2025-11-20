import 'package:flutter/material.dart';

import '../../../../core/theme/text_styles.dart';

class WoodSign extends StatelessWidget {
  final Widget child;

  const WoodSign({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Ropes
        Positioned(
          top: 0,
          left: 40,
          child: Container(
            width: 4,
            height: 60,
            color: const Color(0xFF795548),
          ),
        ),
        Positioned(
          top: 0,
          right: 40,
          child: Container(
            width: 4,
            height: 60,
            color: const Color(0xFF795548),
          ),
        ),

        // Sign Board
        Container(
          margin: const EdgeInsets.only(top: 40),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF8D6E63), // Wood color
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF5D4037), width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFA1887F), // Lighter wood inner
              borderRadius: BorderRadius.circular(8),
            ),
            child: child,
          ),
        ),

        // Nail details
        Positioned(
          top: 50,
          left: 40,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF3E2723),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          top: 50,
          right: 40,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF3E2723),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

class FruitButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final bool? isCorrect;
  final bool isEnabled;

  const FruitButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isCorrect,
    this.isEnabled = true,
  });

  @override
  State<FruitButton> createState() => _FruitButtonState();
}

class _FruitButtonState extends State<FruitButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(FruitButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCorrect == true) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color fruitColor = const Color(0xFFE53935); // Apple Red
    Color stemColor = const Color(0xFF33691E); // Leaf Green

    if (widget.isCorrect == true) {
      fruitColor = const Color(0xFF43A047); // Success Green
    } else if (widget.isCorrect == false) {
      fruitColor = Colors.grey; // Disabled/Wrong
    }

    return GestureDetector(
      onTap: widget.isEnabled
          ? () {
              _controller.forward().then((_) => _controller.reverse());
              widget.onTap();
            }
          : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Stem and Leaf
            Positioned(
              top: 0,
              child: Icon(Icons.eco, color: stemColor, size: 24),
            ),

            // Fruit Body
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: fruitColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                gradient: RadialGradient(
                  colors: [fruitColor.withValues(alpha: 0.8), fruitColor],
                  center: const Alignment(-0.3, -0.3),
                ),
              ),
              child: Center(
                child: Text(
                  widget.text,
                  style: AppTextStyles.heading2.copyWith(
                    color: Colors.white,
                    fontSize: 32,
                    shadows: [
                      const Shadow(
                        color: Colors.black26,
                        blurRadius: 2,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Shine reflection
            Positioned(
              top: 25,
              left: 25,
              child: Container(
                width: 20,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TreasureChest extends StatefulWidget {
  final bool isOpen;
  final VoidCallback? onTap;

  const TreasureChest({super.key, required this.isOpen, this.onTap});

  @override
  State<TreasureChest> createState() => _TreasureChestState();
}

class _TreasureChestState extends State<TreasureChest>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _lidAnimation;
  late Animation<double> _shineAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _lidAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceOut,
    );

    _shineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    if (widget.isOpen) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(TreasureChest oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen && !oldWidget.isOpen) {
      _controller.forward();
    } else if (!widget.isOpen && oldWidget.isOpen) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: 120,
        height: 100,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Chest Body
            Container(
              width: 120,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF5D4037),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
                border: Border.all(color: const Color(0xFFFFD700), width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD700),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),

            // Treasure Glow (behind lid)
            AnimatedBuilder(
              animation: _shineAnimation,
              builder: (context, child) {
                return Positioned(
                  top: 10,
                  child: Opacity(
                    opacity: _shineAnimation.value,
                    child: Container(
                      width: 80,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.yellow.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.yellow.withValues(alpha: 0.8),
                            blurRadius: 20,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Chest Lid
            AnimatedBuilder(
              animation: _lidAnimation,
              builder: (context, child) {
                // Rotate lid open
                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..translate(
                      0.0,
                      -60.0 + (60.0 * _lidAnimation.value),
                    ) // Move up/down
                    ..rotateX(-1.0 * _lidAnimation.value), // Rotate back
                  alignment: Alignment.bottomCenter,
                  child: child,
                );
              },
              child: Container(
                width: 120,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF795548),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(60),
                  ),
                  border: Border.all(color: const Color(0xFFFFD700), width: 4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
