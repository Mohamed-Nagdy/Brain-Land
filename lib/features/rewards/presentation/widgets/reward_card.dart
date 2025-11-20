import 'package:flutter/material.dart';

import '../../../../core/theme/text_styles.dart';
import '../../../../shared/models/reward.dart';

/// RewardCard displays a reward with icon, name, and rarity indicator
/// Includes appear animation and rarity-based glow effects
class RewardCard extends StatefulWidget {
  final Reward reward;
  final VoidCallback? onTap;
  final Duration delay;

  const RewardCard({
    super.key,
    required this.reward,
    this.onTap,
    this.delay = Duration.zero,
  });

  @override
  State<RewardCard> createState() => _RewardCardState();
}

class _RewardCardState extends State<RewardCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Start animation after delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getRarityColor() {
    switch (widget.reward.rarity) {
      case 1:
        return Colors.grey; // Common
      case 2:
        return Colors.green; // Uncommon
      case 3:
        return Colors.blue; // Rare
      case 4:
        return Colors.purple; // Epic
      case 5:
        return Colors.amber; // Legendary
      default:
        return Colors.grey;
    }
  }

  String _getRarityLabel() {
    switch (widget.reward.rarity) {
      case 1:
        return 'Common';
      case 2:
        return 'Uncommon';
      case 3:
        return 'Rare';
      case 4:
        return 'Epic';
      case 5:
        return 'Legendary';
      default:
        return 'Common';
    }
  }

  List<Widget> _buildRarityStars() {
    return List.generate(
      widget.reward.rarity,
      (index) => Icon(Icons.star, color: _getRarityColor(), size: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                width: 160,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getRarityColor().withValues(alpha: 0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getRarityColor().withValues(
                        alpha: 0.3 * _glowAnimation.value,
                      ),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
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
                    // Reward icon/image
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _getRarityColor().withValues(alpha: 0.2),
                            _getRarityColor().withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(child: _buildRewardIcon()),
                    ),
                    const SizedBox(height: 12),

                    // Reward name
                    Text(
                      widget.reward.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Rarity stars
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _buildRarityStars(),
                    ),
                    const SizedBox(height: 4),

                    // Rarity label
                    Text(
                      _getRarityLabel(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: _getRarityColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRewardIcon() {
    // Use icon based on reward type
    IconData iconData;
    Color iconColor;

    switch (widget.reward.type) {
      case RewardType.coin:
        iconData = Icons.monetization_on;
        iconColor = Colors.amber;
        break;
      case RewardType.sticker:
        iconData = Icons.star;
        iconColor = Colors.pink;
        break;
      case RewardType.avatarItem:
        iconData = Icons.checkroom;
        iconColor = Colors.blue;
        break;
      case RewardType.pet:
        iconData = Icons.pets;
        iconColor = Colors.green;
        break;
      case RewardType.background:
        iconData = Icons.wallpaper;
        iconColor = Colors.purple;
        break;
    }

    return Icon(iconData, size: 48, color: iconColor);
  }
}

/// Compact reward card for lists
class CompactRewardCard extends StatelessWidget {
  final Reward reward;
  final VoidCallback? onTap;

  const CompactRewardCard({super.key, required this.reward, this.onTap});

  Color _getRarityColor() {
    switch (reward.rarity) {
      case 1:
        return Colors.grey;
      case 2:
        return Colors.green;
      case 3:
        return Colors.blue;
      case 4:
        return Colors.purple;
      case 5:
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  IconData _getRewardIcon() {
    switch (reward.type) {
      case RewardType.coin:
        return Icons.monetization_on;
      case RewardType.sticker:
        return Icons.star;
      case RewardType.avatarItem:
        return Icons.checkroom;
      case RewardType.pet:
        return Icons.pets;
      case RewardType.background:
        return Icons.wallpaper;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getRarityColor().withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _getRarityColor().withValues(alpha: 0.2),
                    _getRarityColor().withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_getRewardIcon(), color: _getRarityColor(), size: 28),
            ),
            const SizedBox(width: 12),

            // Name and rarity
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(
                      reward.rarity,
                      (index) =>
                          Icon(Icons.star, color: _getRarityColor(), size: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reward type badge
class RewardTypeBadge extends StatelessWidget {
  final RewardType type;
  final double size;

  const RewardTypeBadge({super.key, required this.type, this.size = 32});

  IconData _getIcon() {
    switch (type) {
      case RewardType.coin:
        return Icons.monetization_on;
      case RewardType.sticker:
        return Icons.star;
      case RewardType.avatarItem:
        return Icons.checkroom;
      case RewardType.pet:
        return Icons.pets;
      case RewardType.background:
        return Icons.wallpaper;
    }
  }

  Color _getColor() {
    switch (type) {
      case RewardType.coin:
        return Colors.amber;
      case RewardType.sticker:
        return Colors.pink;
      case RewardType.avatarItem:
        return Colors.blue;
      case RewardType.pet:
        return Colors.green;
      case RewardType.background:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getColor().withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(_getIcon(), color: _getColor(), size: size * 0.6),
    );
  }
}
