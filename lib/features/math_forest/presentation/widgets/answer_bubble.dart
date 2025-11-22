import 'package:brain_land/core/utils/audio_manager.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/animations.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/text_styles.dart';

/// A circular bubble widget that displays an answer option for math problems
/// Features:
/// - Gradient background with shadow
/// - Tap animation (scale down)
/// - Correct/incorrect feedback animations
/// - Accessible for children with large touch targets
class AnswerBubble extends StatefulWidget {
  final String answer;
  final VoidCallback onTap;
  final bool?
  isCorrect; // null = not answered, true = correct, false = incorrect
  final bool isEnabled;

  const AnswerBubble({
    super.key,
    required this.answer,
    required this.onTap,
    this.isCorrect,
    this.isEnabled = true,
  });

  @override
  State<AnswerBubble> createState() => _AnswerBubbleState();
}

class _AnswerBubbleState extends State<AnswerBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _feedbackAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AnimationConstants.fast,
      vsync: this,
    );

    _scaleAnimation =
        Tween<double>(
          begin: AnimationConstants.scaleNormal,
          end: AnimationConstants.scaleDown,
        ).animate(
          CurvedAnimation(parent: _controller, curve: AnimationConstants.quick),
        );

    _feedbackAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: AnimationConstants.bounceIn),
    );
  }

  @override
  void didUpdateWidget(AnswerBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger feedback animation when isCorrect changes from null to a value
    if (oldWidget.isCorrect == null && widget.isCorrect != null) {
      _playFeedbackAnimation();
      _playFeedbackSound();
    }
  }

  void _playFeedbackSound() {
    // Play appropriate sound based on correctness
    if (widget.isCorrect == true) {
      AudioManager.instance.playSound(SoundEffect.correctAnswer.path);
    } else if (widget.isCorrect == false) {
      AudioManager.instance.playSound(SoundEffect.incorrectAnswer.path);
    }
  }

  void _playFeedbackAnimation() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  LinearGradient _getGradient() {
    if (widget.isCorrect == true) {
      return AppColors.correctAnswerGradient;
    } else if (widget.isCorrect == false) {
      return AppColors.incorrectAnswerGradient;
    } else {
      return AppColors.answerBubbleGradient;
    }
  }

  Color _getShadowColor() {
    if (widget.isCorrect == true) {
      return AppColors.successGreen.withValues(alpha: 0.4);
    } else if (widget.isCorrect == false) {
      return AppColors.errorRed.withValues(alpha: 0.4);
    } else {
      return const Color(0xFF6B4CE6).withValues(alpha: 0.4);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isEnabled
          ? (_) {
              _controller.forward();
            }
          : null,
      onTapUp: widget.isEnabled
          ? (_) {
              _controller.reverse();
              widget.onTap();
            }
          : null,
      onTapCancel: widget.isEnabled
          ? () {
              _controller.reverse();
            }
          : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = widget.isCorrect != null
              ? _feedbackAnimation.value
              : _scaleAnimation.value;

          return LayoutBuilder(
            builder: (context, constraints) {
              // Use the smaller dimension to ensure the bubble fits
              final size = constraints.maxWidth < constraints.maxHeight
                  ? constraints.maxWidth
                  : constraints.maxHeight;

              // Calculate font size based on bubble size
              final fontSize = size * 0.4;

              return Transform.scale(
                scale: scale,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _getGradient(),
                    boxShadow: [
                      BoxShadow(
                        color: _getShadowColor(),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      widget.answer,
                      style: AppTextStyles.gameNumber.copyWith(
                        color: AppColors.textLight,
                        fontSize: fontSize,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
