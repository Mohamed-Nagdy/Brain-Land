import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/theme/text_styles.dart';

/// A countdown timer widget for math game levels
/// Features:
/// - Countdown display with clear typography
/// - Visual warning when time is low (< 10 seconds)
/// - Unlimited time mode (displays infinity symbol)
/// - Pulsing animation when time is running out
/// - Color changes based on time remaining
class TimerWidget extends StatefulWidget {
  final int timeRemaining; // in seconds, 0 = unlimited
  final int? totalTime; // optional, for progress indicator
  final VoidCallback? onTimeExpired;

  const TimerWidget({
    super.key,
    required this.timeRemaining,
    this.totalTime,
    this.onTimeExpired,
  });

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start pulsing if time is low
    if (_isTimeLow()) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(TimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if time expired
    if (oldWidget.timeRemaining > 0 && widget.timeRemaining == 0) {
      widget.onTimeExpired?.call();
    }

    // Start/stop pulsing based on time
    if (_isTimeLow() && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!_isTimeLow() && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  bool _isTimeLow() {
    return widget.timeRemaining > 0 && widget.timeRemaining <= 10;
  }

  bool _isUnlimitedTime() {
    return widget.timeRemaining == 0;
  }

  Color _getTimerColor() {
    if (_isUnlimitedTime()) {
      return AppColors.infoBlue;
    } else if (widget.timeRemaining <= 5) {
      return AppColors.errorRed;
    } else if (widget.timeRemaining <= 10) {
      return AppColors.warningYellow;
    } else {
      return AppColors.successGreen;
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final scale = _isTimeLow() ? _pulseAnimation.value : 1.0;

        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: _getTimerColor().withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _getTimerColor(), width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isUnlimitedTime() ? Icons.all_inclusive : Icons.timer,
                  color: _getTimerColor(),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  _isUnlimitedTime()
                      ? 'No Limit'
                      : _formatTime(widget.timeRemaining),
                  style: AppTextStyles.heading3.copyWith(
                    color: _getTimerColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A circular progress timer widget with visual countdown
class CircularTimerWidget extends StatelessWidget {
  final int timeRemaining;
  final int totalTime;
  final double size;

  const CircularTimerWidget({
    super.key,
    required this.timeRemaining,
    required this.totalTime,
    this.size = 80,
  });

  Color _getTimerColor() {
    final percentage = timeRemaining / totalTime;
    if (percentage <= 0.2) {
      return AppColors.errorRed;
    } else if (percentage <= 0.4) {
      return AppColors.warningYellow;
    } else {
      return AppColors.successGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = totalTime > 0 ? timeRemaining / totalTime : 0.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 6,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.textSecondary.withValues(alpha: 0.2),
              ),
            ),
          ),
          // Progress circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 6,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(_getTimerColor()),
            ),
          ),
          // Time text
          Text(
            timeRemaining.toString(),
            style: AppTextStyles.heading2.copyWith(
              color: _getTimerColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
