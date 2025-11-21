import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../progress/providers/progress_provider.dart';
import '../constants/ad_constants.dart';
import '../services/rewarded_ad_service.dart';

/// Button widget for watching rewarded ads to earn coins
class RewardedAdButton extends ConsumerStatefulWidget {
  final String label;
  final VoidCallback? onRewardEarned;

  const RewardedAdButton({
    super.key,
    this.label = 'Watch Ad for +${AdConstants.coinsPerRewardedAd} Coins',
    this.onRewardEarned,
  });

  @override
  ConsumerState<RewardedAdButton> createState() => _RewardedAdButtonState();
}

class _RewardedAdButtonState extends ConsumerState<RewardedAdButton> {
  final RewardedAdService _adService = RewardedAdService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  Future<void> _loadAd() async {
    setState(() => _isLoading = true);
    await _adService.loadAd();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showAd() async {
    final success = await _adService.show(
      onRewarded: (amount) async {
        // Add coins to user's progress
        final notifier = ref.read(progressProvider.notifier);
        await notifier.addCoins(amount);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🎉 You earned $amount coins!'),
              backgroundColor: const Color(0xFF43E97B),
              duration: const Duration(seconds: 2),
            ),
          );

          // Call custom callback if provided
          widget.onRewardEarned?.call();
        }
      },
      onAdDismissed: () {
        // Reload ad for next time
        _loadAd();
      },
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ad not ready yet. Please try again in a moment.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  void dispose() {
    _adService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isLoading ? null : _showAd,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isLoading
                ? [Colors.grey.shade400, Colors.grey.shade500]
                : [const Color(0xFFFFD700), const Color(0xFFFFA500)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: _isLoading
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              const Text('📺', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Text(
              _isLoading ? 'Loading...' : widget.label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 2,
                    offset: Offset(0, 1),
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
