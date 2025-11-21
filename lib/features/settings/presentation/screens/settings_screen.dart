import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/audio_manager.dart';
import '../../../ads/widgets/banner_ad_widget.dart';
import '../../../progress/providers/progress_provider.dart';

/// Settings Screen for audio and app preferences
/// Features:
/// - Music volume slider
/// - Sound effects volume slider
/// - Mute toggle
/// - Child-friendly fancy UI with animations
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with TickerProviderStateMixin {
  late double _musicVolume;
  late double _soundVolume;
  late bool _isMuted;
  late AnimationController _floatingController;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    final audioManager = AudioManager.instance;
    _musicVolume = audioManager.musicVolume;
    _soundVolume = audioManager.soundVolume;
    _isMuted = audioManager.isMuted;

    // Floating animation for emoji
    _floatingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Rotation animation for settings icon
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _updateMusicVolume(double value) {
    setState(() {
      _musicVolume = value;
    });
    AudioManager.instance.setMusicVolume(value);
  }

  void _updateSoundVolume(double value) {
    setState(() {
      _soundVolume = value;
    });
    AudioManager.instance.setSoundVolume(value);
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    AudioManager.instance.toggleMute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667EEA), // Purple-blue
              Color(0xFF764BA2), // Purple
              Color(0xFFF093FB), // Pink
              Color(0xFF4FACFE), // Light blue
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom header
              _buildHeader(context),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Animated emoji
                      _buildAnimatedEmoji(),
                      const SizedBox(height: 24),

                      // Mute toggle card
                      _buildMuteCard(),
                      const SizedBox(height: 20),

                      // Music volume card
                      _buildMusicVolumeCard(),
                      const SizedBox(height: 20),

                      // Sound effects volume card
                      _buildSoundVolumeCard(),
                      const SizedBox(height: 20),

                      // Info card
                      _buildInfoCard(),

                      // Debug section (only in debug mode)
                      if (kDebugMode) ...[
                        const SizedBox(height: 20),
                        _buildDebugSection(),
                      ],

                      // Banner ad at bottom
                      const SizedBox(height: 20),
                      const BannerAdWidget(),
                      const SizedBox(height: 20),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Title with rotating icon
          Expanded(
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _rotationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationController.value * 2 * math.pi,
                      child: const Text('⚙️', style: TextStyle(fontSize: 32)),
                    );
                  },
                ),
                const SizedBox(width: 12),
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedEmoji() {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        final float = math.sin(_floatingController.value * math.pi) * 15;
        return Transform.translate(
          offset: Offset(0, float),
          child: const Text('🎵', style: TextStyle(fontSize: 80)),
        );
      },
    );
  }

  Widget _buildMuteCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isMuted
                    ? [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)]
                    : [const Color(0xFF4FACFE), const Color(0xFF00F2FE)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color:
                      (_isMuted
                              ? const Color(0xFFFF6B6B)
                              : const Color(0xFF4FACFE))
                          .withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Text(
              _isMuted ? '🔇' : '🔊',
              style: const TextStyle(fontSize: 32),
            ),
          ),
          const SizedBox(width: 16),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mute All Sounds',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isMuted ? 'All sounds are off 😴' : 'All sounds are on 🎉',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Switch
          Transform.scale(
            scale: 1.2,
            child: Switch(
              value: _isMuted,
              onChanged: (_) => _toggleMute(),
              activeThumbColor: const Color(0xFFFF6B6B),
              activeTrackColor: const Color(0xFFFF8E53).withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMusicVolumeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFA709A), Color(0xFFFEE140)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFA709A).withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Text('🎵', style: TextStyle(fontSize: 32)),
              ),
              const SizedBox(width: 16),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Music Volume',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(_musicVolume * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFA709A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Slider
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFFFA709A),
              inactiveTrackColor: const Color(
                0xFFFA709A,
              ).withValues(alpha: 0.2),
              thumbColor: const Color(0xFFFEE140),
              overlayColor: const Color(0xFFFEE140).withValues(alpha: 0.3),
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
            ),
            child: Slider(
              value: _musicVolume,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              onChanged: _isMuted ? null : _updateMusicVolume,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundVolumeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF43E97B).withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Text('🔔', style: TextStyle(fontSize: 32)),
              ),
              const SizedBox(width: 16),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sound Effects',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(_soundVolume * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF43E97B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Slider
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFF43E97B),
              inactiveTrackColor: const Color(
                0xFF43E97B,
              ).withValues(alpha: 0.2),
              thumbColor: const Color(0xFF38F9D7),
              overlayColor: const Color(0xFF38F9D7).withValues(alpha: 0.3),
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
            ),
            child: Slider(
              value: _soundVolume,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              onChanged: _isMuted ? null : _updateSoundVolume,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Text('💡', style: TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 12),
              const Text(
                'Did You Know?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Music helps you focus while exploring zones! 🎵\n\n'
            'Sound effects make learning more fun! 🎉\n\n'
            'You can change these settings anytime! ⚙️',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebugSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.withValues(alpha: 0.3),
            Colors.orange.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.red.withValues(alpha: 0.6), width: 2),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🛠️', style: TextStyle(fontSize: 28)),
              SizedBox(width: 12),
              Text(
                'Debug Tools',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Development tools for testing',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 20),

          // Populate Sample Data button
          _buildDebugButton(
            icon: '📊',
            label: 'Populate Sample Data',
            color: const Color(0xFF43E97B),
            onPressed: () async {
              final helper = ref.read(debugProgressHelperProvider);
              if (helper != null) {
                await helper.populateSampleData();
                ref.invalidate(progressNotifierProvider);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Sample data populated!'),
                      backgroundColor: Color(0xFF43E97B),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 12),

          // Add Test Rewards button
          _buildDebugButton(
            icon: '🎁',
            label: 'Add Test Rewards',
            color: const Color(0xFFFFD700),
            onPressed: () async {
              final helper = ref.read(debugProgressHelperProvider);
              if (helper != null) {
                await helper.addTestRewards();
                ref.invalidate(progressNotifierProvider);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Added 100 stars & 200 coins!'),
                      backgroundColor: Color(0xFFFFD700),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 12),

          // Reset Progress button
          _buildDebugButton(
            icon: '🔄',
            label: 'Reset Progress',
            color: const Color(0xFFFF6B6B),
            onPressed: () async {
              final helper = ref.read(debugProgressHelperProvider);
              if (helper != null) {
                await helper.resetToEmpty();
                ref.invalidate(progressNotifierProvider);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Progress reset!'),
                      backgroundColor: Color(0xFFFF6B6B),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDebugButton({
    required String icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Text(
              label,
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
