import 'package:flutter/material.dart';

/// A widget that displays the current streak with calendar and flame animation
class StreakDisplay extends StatefulWidget {
  final int currentStreak;
  final List<DateTime> streakDates;

  const StreakDisplay({
    super.key,
    required this.currentStreak,
    required this.streakDates,
  });

  @override
  State<StreakDisplay> createState() => _StreakDisplayState();
}

class _StreakDisplayState extends State<StreakDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _flameController;
  late Animation<double> _flameAnimation;

  @override
  void initState() {
    super.initState();
    _flameController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _flameAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _flameController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange[300]!, Colors.deepOrange[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Streak count with flame icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated flame icon
              if (widget.currentStreak > 0)
                AnimatedBuilder(
                  animation: _flameAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _flameAnimation.value,
                      child: Icon(
                        Icons.local_fire_department,
                        size: 40,
                        color: Colors.yellow[700],
                      ),
                    );
                  },
                ),
              const SizedBox(width: 12),
              // Streak number
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.currentStreak}',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    widget.currentStreak == 1 ? 'Day Streak' : 'Days Streak',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Calendar with marked days
          _buildCalendar(),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Show last 7 days
    final days = List.generate(7, (index) {
      return today.subtract(Duration(days: 6 - index));
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: days.map((date) {
        final isInStreak = widget.streakDates.any(
          (d) =>
              d.year == date.year && d.month == date.month && d.day == date.day,
        );
        final isToday = date == today;

        return Column(
          children: [
            // Day name
            Text(
              _getDayName(date.weekday),
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            // Day circle
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isInStreak
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: isToday
                    ? Border.all(color: Colors.yellow[700]!, width: 2)
                    : null,
              ),
              child: Center(
                child: isInStreak
                    ? Icon(Icons.check, size: 18, color: Colors.orange[600])
                    : Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }
}
