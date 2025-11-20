import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/audio_manager.dart';
import '../../../../shared/widgets/fancy_card.dart';
import '../../../../shared/widgets/gradient_background.dart';

/// Settings Screen for audio and app preferences
/// Features:
/// - Music volume slider
/// - Sound effects volume slider
/// - Mute toggle
/// - Child-friendly UI
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late double _musicVolume;
  late double _soundVolume;
  late bool _isMuted;

  @override
  void initState() {
    super.initState();
    final audioManager = AudioManager.instance;
    _musicVolume = audioManager.musicVolume;
    _soundVolume = audioManager.soundVolume;
    _isMuted = audioManager.isMuted;
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
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: GradientBackground(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.secondary.withValues(alpha: 0.1),
          ],
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Audio Settings Section
                Text('🔊 Audio Settings', style: AppTextStyles.heading2),
                const SizedBox(height: 16),

                // Mute Toggle
                FancyCard(
                  child: SwitchListTile(
                    title: Text(
                      'Mute All Sounds',
                      style: AppTextStyles.bodyLarge,
                    ),
                    subtitle: Text(
                      _isMuted ? 'All sounds are off' : 'All sounds are on',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    value: _isMuted,
                    onChanged: (_) => _toggleMute(),
                    activeThumbColor: AppColors.primary,
                    secondary: Icon(
                      _isMuted ? Icons.volume_off : Icons.volume_up,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Music Volume
                FancyCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.music_note,
                            color: AppColors.primary,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Music Volume',
                                  style: AppTextStyles.bodyLarge,
                                ),
                                Text(
                                  '${(_musicVolume * 100).round()}%',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: AppColors.primary.withValues(
                            alpha: 0.2,
                          ),
                          thumbColor: AppColors.primary,
                          overlayColor: AppColors.primary.withValues(
                            alpha: 0.2,
                          ),
                          trackHeight: 8,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 12,
                          ),
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
                ),

                const SizedBox(height: 16),

                // Sound Effects Volume
                FancyCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.notifications_active,
                            color: AppColors.primary,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sound Effects Volume',
                                  style: AppTextStyles.bodyLarge,
                                ),
                                Text(
                                  '${(_soundVolume * 100).round()}%',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: AppColors.successGreen,
                          inactiveTrackColor: AppColors.successGreen.withValues(
                            alpha: 0.2,
                          ),
                          thumbColor: AppColors.successGreen,
                          overlayColor: AppColors.successGreen.withValues(
                            alpha: 0.2,
                          ),
                          trackHeight: 8,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 12,
                          ),
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
                ),

                const SizedBox(height: 24),

                // Test Sound Button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _isMuted
                        ? null
                        : () {
                            AudioManager.instance.playSound(
                              SoundEffect.correctAnswer.path,
                            );
                          },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Test Sound'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Info Section
                FancyCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.primary,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text('About Audio', style: AppTextStyles.heading3),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Music plays in the background while you explore zones. '
                        'Sound effects give you feedback when you tap buttons and answer questions. '
                        'You can adjust the volume or mute all sounds anytime!',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
