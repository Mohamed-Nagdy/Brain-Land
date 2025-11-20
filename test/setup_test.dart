import 'package:brain_land/core/constants/app_constants.dart';
import 'package:brain_land/core/constants/colors.dart';
import 'package:brain_land/shared/providers/app_state_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Project Setup Tests', () {
    test('AppConstants are properly defined', () {
      expect(AppConstants.appName, 'BrainLand');
      expect(AppConstants.totalZones, 4);
      expect(AppConstants.levelsPerZone, 30);
      expect(AppConstants.chestAccuracyThreshold, 0.90);
      expect(AppConstants.consecutiveLevelsForPet, 5);
      expect(AppConstants.streakForSpecialBox, 7);
    });

    test('AppColors are properly defined', () {
      expect(AppColors.primary.toARGB32(), isNonZero);
      expect(AppColors.secondary.toARGB32(), isNonZero);
      expect(AppColors.mathForest.toARGB32(), isNonZero);
      expect(AppColors.logicMountain.toARGB32(), isNonZero);
      expect(AppColors.memoryRiver.toARGB32(), isNonZero);
      expect(AppColors.shapeValley.toARGB32(), isNonZero);
    });

    test('AppState initializes with correct defaults', () {
      final container = ProviderContainer();
      final appState = container.read(appStateProvider);

      expect(appState.isAudioEnabled, true);
      expect(appState.musicVolume, 0.7);
      expect(appState.sfxVolume, 0.8);
      expect(appState.isFirstLaunch, true);

      container.dispose();
    });

    test('AppState can toggle audio', () {
      final container = ProviderContainer();
      final notifier = container.read(appStateProvider.notifier);

      expect(container.read(appStateProvider).isAudioEnabled, true);

      notifier.toggleAudio();
      expect(container.read(appStateProvider).isAudioEnabled, false);

      notifier.toggleAudio();
      expect(container.read(appStateProvider).isAudioEnabled, true);

      container.dispose();
    });

    test('AppState can set music volume', () {
      final container = ProviderContainer();
      final notifier = container.read(appStateProvider.notifier);

      notifier.setMusicVolume(0.5);
      expect(container.read(appStateProvider).musicVolume, 0.5);

      // Test clamping
      notifier.setMusicVolume(1.5);
      expect(container.read(appStateProvider).musicVolume, 1.0);

      notifier.setMusicVolume(-0.5);
      expect(container.read(appStateProvider).musicVolume, 0.0);

      container.dispose();
    });

    test('AppState can set SFX volume', () {
      final container = ProviderContainer();
      final notifier = container.read(appStateProvider.notifier);

      notifier.setSfxVolume(0.6);
      expect(container.read(appStateProvider).sfxVolume, 0.6);

      // Test clamping
      notifier.setSfxVolume(2.0);
      expect(container.read(appStateProvider).sfxVolume, 1.0);

      notifier.setSfxVolume(-1.0);
      expect(container.read(appStateProvider).sfxVolume, 0.0);

      container.dispose();
    });

    test('AppState can mark first launch complete', () {
      final container = ProviderContainer();
      final notifier = container.read(appStateProvider.notifier);

      expect(container.read(appStateProvider).isFirstLaunch, true);

      notifier.setFirstLaunchComplete();
      expect(container.read(appStateProvider).isFirstLaunch, false);

      container.dispose();
    });
  });
}
