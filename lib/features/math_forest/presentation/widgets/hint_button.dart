import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../ads/services/rewarded_ad_service.dart';

/// Hint button that shows a rewarded ad to reveal the correct answer
class HintButton extends StatefulWidget {
  final int correctAnswer;
  final VoidCallback? onHintRevealed;

  const HintButton({
    super.key,
    required this.correctAnswer,
    this.onHintRevealed,
  });

  @override
  State<HintButton> createState() => _HintButtonState();
}

class _HintButtonState extends State<HintButton> {
  final RewardedAdService _adService = RewardedAdService();
  bool _isLoading = true;
  bool _hintRevealed = false;

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

  Future<void> _showHint() async {
    if (_hintRevealed) {
      // Already revealed, just show the hint again
      _showHintDialog();
      return;
    }

    final success = await _adService.show(
      onRewarded: (amount) {
        // User watched the ad, reveal the hint
        if (mounted) {
          setState(() => _hintRevealed = true);
          _showHintDialog();
          widget.onHintRevealed?.call();
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
          content: Text(
            'Hint not available yet. Please try again in a moment.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showHintDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text('💡', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Text(
              'Hint!',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.mathForestGreen,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('The correct answer is:', style: AppTextStyles.bodyLarge),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.mathForestGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.mathForestGreen, width: 3),
              ),
              child: Text(
                widget.correctAnswer.toString(),
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.mathForestGreen,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _adService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isLoading ? null : _showHint,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: _isLoading
              ? LinearGradient(
                  colors: [Colors.grey.shade400, Colors.grey.shade500],
                )
              : _hintRevealed
              ? LinearGradient(
                  colors: [
                    AppColors.mathForestGreen,
                    AppColors.mathForestGreen.withValues(alpha: 0.7),
                  ],
                )
              : const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: _isLoading
              ? []
              : [
                  BoxShadow(
                    color:
                        (_hintRevealed
                                ? AppColors.mathForestGreen
                                : const Color(0xFFFFD700))
                            .withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              Text(
                _hintRevealed ? '💡' : '📺',
                style: const TextStyle(fontSize: 20),
              ),
            const SizedBox(width: 8),
            Text(
              _isLoading
                  ? 'Loading...'
                  : _hintRevealed
                  ? 'Show Hint'
                  : 'Watch Ad for Hint',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
