import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/fancy_button.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../providers/progress_provider.dart';
import '../../providers/streak_provider.dart';

/// Screen that displays daily rewards and allows claiming
class DailyRewardScreen extends ConsumerStatefulWidget {
  const DailyRewardScreen({super.key});

  @override
  ConsumerState<DailyRewardScreen> createState() => _DailyRewardScreenState();
}

class _DailyRewardScreenState extends ConsumerState<DailyRewardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _claimController;
  late Animation<double> _scaleAnimation;
  bool _isClaimed = false;

  @override
  void initState() {
    super.initState();
    _claimController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.2,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.2,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_claimController);
  }

  @override
  void dispose() {
    _claimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasLoggedInTodayAsync = ref.watch(hasLoggedInTodayProvider);
    final todaysRewardAsync = ref.watch(todaysRewardProvider);
    final streakAsync = ref.watch(streakNotifierProvider);
    final dailyRewards = ref.watch(dailyRewardsProvider);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Expanded(
                      child: Text(
                        'Daily Rewards',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Current streak display
                      streakAsync.when(
                        data: (streak) => _buildStreakHeader(streak),
                        loading: () => const CircularProgressIndicator(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 24),
                      // Daily calendar
                      _buildDailyCalendar(dailyRewards, streakAsync),
                      const SizedBox(height: 24),
                      // Today's reward
                      todaysRewardAsync.when(
                        data: (reward) {
                          if (reward == null) {
                            return const SizedBox.shrink();
                          }
                          return hasLoggedInTodayAsync.when(
                            data: (hasLoggedIn) => _buildTodaysReward(
                              reward,
                              hasLoggedIn || _isClaimed,
                            ),
                            loading: () => const CircularProgressIndicator(),
                            error: (_, __) => const SizedBox.shrink(),
                          );
                        },
                        loading: () => const CircularProgressIndicator(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakHeader(int streak) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_fire_department,
            size: 40,
            color: Colors.orange[600],
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$streak ${streak == 1 ? 'Day' : 'Days'}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Current Streak',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyCalendar(
    List<DailyReward> rewards,
    AsyncValue<int> streakAsync,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '7-Day Reward Calendar',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...rewards.map((reward) {
            return streakAsync.when(
              data: (streak) {
                final isCompleted = streak >= reward.day;
                final isToday =
                    streak == reward.day - 1 ||
                    (streak == 0 && reward.day == 1);
                return _buildRewardDay(reward, isCompleted, isToday);
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRewardDay(DailyReward reward, bool isCompleted, bool isToday) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isToday
            ? Colors.orange[50]
            : isCompleted
            ? Colors.green[50]
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isToday
              ? Colors.orange
              : isCompleted
              ? Colors.green
              : Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Day number
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : Text(
                      '${reward.day}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Reward info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  reward.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          // Coin value
          Row(
            children: [
              Icon(Icons.monetization_on, color: Colors.amber[700], size: 20),
              const SizedBox(width: 4),
              Text(
                '${reward.coinValue}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysReward(DailyReward reward, bool isClaimed) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isClaimed ? _scaleAnimation.value : 1.0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber[300]!, Colors.orange[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Today\'s Reward',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                // Reward icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.monetization_on,
                    size: 50,
                    color: Colors.yellow[700],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  reward.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${reward.coinValue} Coins',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow[700],
                  ),
                ),
                const SizedBox(height: 24),
                // Claim button
                if (!isClaimed)
                  FancyButton(
                    text: 'Claim Reward',
                    onPressed: _claimReward,
                    gradient: const LinearGradient(
                      colors: [Colors.white, Colors.white],
                    ),
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700]!,
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'Claimed!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Streak bonus indicator
                if (reward.day == 7)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: Colors.yellow[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Weekly Streak Bonus!',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _claimReward() async {
    final todaysReward = await ref.read(todaysRewardProvider.future);
    if (todaysReward == null) return;

    // Add coins
    await ref
        .read(progressNotifierProvider.notifier)
        .addCoins(todaysReward.coinValue);

    // Update streak
    await ref.read(streakNotifierProvider.notifier).updateStreak();

    // Trigger animation
    setState(() {
      _isClaimed = true;
    });
    _claimController.forward();

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Claimed ${todaysReward.coinValue} coins!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
