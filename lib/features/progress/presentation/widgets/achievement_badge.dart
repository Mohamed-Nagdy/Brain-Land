import 'package:flutter/material.dart';

/// A badge widget that displays an achievement with unlock animation
class AchievementBadge extends StatefulWidget {
  final String name;
  final String description;
  final IconData icon;
  final bool isUnlocked;
  final Color color;

  const AchievementBadge({
    super.key,
    required this.name,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    this.color = Colors.amber,
  });

  @override
  State<AchievementBadge> createState() => _AchievementBadgeState();
}

class _AchievementBadgeState extends State<AchievementBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _wasUnlocked = false;

  @override
  void initState() {
    super.initState();
    _wasUnlocked = widget.isUnlocked;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.3,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.3,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isUnlocked) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AchievementBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger animation when badge is unlocked
    if (!_wasUnlocked && widget.isUnlocked) {
      _wasUnlocked = true;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isUnlocked ? _scaleAnimation.value : 1.0,
          child: Transform.rotate(
            angle: widget.isUnlocked ? _rotationAnimation.value : 0.0,
            child: Container(
              width: 100,
              height: 120,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.isUnlocked ? Colors.white : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
                boxShadow: widget.isUnlocked
                    ? [
                        BoxShadow(
                          color: widget.color.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Badge icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: widget.isUnlocked
                          ? widget.color.withValues(alpha: 0.2)
                          : Colors.grey[400],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.icon,
                      size: 28,
                      color: widget.isUnlocked
                          ? widget.color
                          : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Badge name
                  Text(
                    widget.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: widget.isUnlocked
                          ? Colors.black87
                          : Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Lock overlay for locked badges
                  if (!widget.isUnlocked)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Icon(
                        Icons.lock,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
