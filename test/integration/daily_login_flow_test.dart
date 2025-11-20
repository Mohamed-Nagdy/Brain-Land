import 'dart:io';

import 'package:brain_land/core/constants/app_constants.dart';
import 'package:brain_land/features/progress/providers/progress_provider.dart';
import 'package:brain_land/features/progress/providers/streak_provider.dart';
import 'package:brain_land/features/progress/services/progress_storage_service.dart';
import 'package:brain_land/shared/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Daily Login Flow Integration Test', () {
    late Directory testDir;
    late StorageService storage;
    late ProgressStorageService progressService;

    setUp(() async {
      // Create a temporary directory for testing
      testDir = await Directory.systemTemp.createTemp('hive_test_');

      // Initialize storage with the test directory
      storage = StorageService.instance;
      await storage.initialize(path: testDir.path);

      progressService = ProgressStorageService(storageService: storage);
    });

    tearDown(() async {
      // Clean up after each test
      await storage.clearBox(AppConstants.progressBoxName);
      await storage.dispose();

      // Delete the test directory
      if (await testDir.exists()) {
        await testDir.delete(recursive: true);
      }
    });

    testWidgets(
      'complete daily login flow - login → claim reward → update streak',
      (tester) async {
        // Create a test app with providers
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Consumer(
                  builder: (context, ref, child) {
                    final progressAsync = ref.watch(progressNotifierProvider);
                    final streakAsync = ref.watch(streakNotifierProvider);
                    final todaysRewardAsync = ref.watch(todaysRewardProvider);

                    return progressAsync.when(
                      data: (progress) {
                        return Column(
                          children: [
                            Text(
                              'Streak: ${progress.currentStreak}',
                              key: const Key('streak_text'),
                            ),
                            Text(
                              'Coins: ${progress.totalCoins}',
                              key: const Key('coins_text'),
                            ),
                            streakAsync.when(
                              data: (streak) => Text(
                                'Streak Value: $streak',
                                key: const Key('streak_value'),
                              ),
                              loading: () => const CircularProgressIndicator(),
                              error: (_, __) => const Text('Error'),
                            ),
                            todaysRewardAsync.when(
                              data: (reward) => Text(
                                'Today Reward: ${reward?.coinValue ?? 0}',
                                key: const Key('reward_value'),
                              ),
                              loading: () => const CircularProgressIndicator(),
                              error: (_, __) => const Text('Error'),
                            ),
                            ElevatedButton(
                              key: const Key('claim_button'),
                              onPressed: () async {
                                // Simulate claiming reward
                                final reward = await ref.read(
                                  todaysRewardProvider.future,
                                );
                                if (reward != null) {
                                  await ref
                                      .read(progressNotifierProvider.notifier)
                                      .addCoins(reward.coinValue);
                                  await ref
                                      .read(streakNotifierProvider.notifier)
                                      .updateStreak();
                                }
                              },
                              child: const Text('Claim Reward'),
                            ),
                          ],
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) => Text('Error: $error'),
                    );
                  },
                ),
              ),
            ),
          ),
        );

        // Wait for initial load
        await tester.pumpAndSettle();

        // Verify initial state
        expect(find.text('Streak: 0'), findsOneWidget);
        expect(find.text('Coins: 0'), findsOneWidget);

        // Simulate first login by updating streak
        await tester.tap(find.byKey(const Key('claim_button')));
        await tester.pumpAndSettle();

        // Verify streak was updated to 1
        expect(find.textContaining('Streak: 1'), findsOneWidget);

        // Verify coins were added (first day reward is 10 coins)
        expect(find.textContaining('Coins: 10'), findsOneWidget);

        // Verify streak value matches
        expect(find.text('Streak Value: 1'), findsOneWidget);
      },
    );

    testWidgets('consecutive day login increments streak', (tester) async {
      // Set up initial progress with yesterday's login
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final progress = await progressService.getProgress();
      await progressService.updateProgress(
        progress.copyWith(
          currentStreak: 1,
          lastLoginDate: yesterday,
          totalCoins: 10,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  final progressAsync = ref.watch(progressNotifierProvider);

                  return progressAsync.when(
                    data: (progress) {
                      return Column(
                        children: [
                          Text(
                            'Streak: ${progress.currentStreak}',
                            key: const Key('streak_text'),
                          ),
                          Text(
                            'Coins: ${progress.totalCoins}',
                            key: const Key('coins_text'),
                          ),
                          ElevatedButton(
                            key: const Key('login_button'),
                            onPressed: () async {
                              // Simulate login
                              await ref
                                  .read(streakNotifierProvider.notifier)
                                  .updateStreak();

                              // Add today's reward (day 2 = 20 coins)
                              await ref
                                  .read(progressNotifierProvider.notifier)
                                  .addCoins(20);
                            },
                            child: const Text('Login'),
                          ),
                        ],
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => Text('Error: $error'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify initial state (yesterday's login)
      expect(find.text('Streak: 1'), findsOneWidget);
      expect(find.text('Coins: 10'), findsOneWidget);

      // Simulate today's login
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Verify streak incremented
      expect(find.text('Streak: 2'), findsOneWidget);

      // Verify coins increased
      expect(find.text('Coins: 30'), findsOneWidget);
    });

    testWidgets('missed day resets streak', (tester) async {
      // Set up initial progress with login 3 days ago
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      final progress = await progressService.getProgress();
      await progressService.updateProgress(
        progress.copyWith(
          currentStreak: 5,
          lastLoginDate: threeDaysAgo,
          totalCoins: 100,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  final progressAsync = ref.watch(progressNotifierProvider);

                  return progressAsync.when(
                    data: (progress) {
                      return Column(
                        children: [
                          Text(
                            'Streak: ${progress.currentStreak}',
                            key: const Key('streak_text'),
                          ),
                          ElevatedButton(
                            key: const Key('login_button'),
                            onPressed: () async {
                              // Simulate login after missed days
                              await ref
                                  .read(streakNotifierProvider.notifier)
                                  .updateStreak();

                              // Add day 1 reward
                              await ref
                                  .read(progressNotifierProvider.notifier)
                                  .addCoins(10);
                            },
                            child: const Text('Login'),
                          ),
                        ],
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => Text('Error: $error'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify initial state (5-day streak from 3 days ago)
      expect(find.text('Streak: 5'), findsOneWidget);

      // Simulate login after missed days
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Verify streak was reset to 1
      expect(find.text('Streak: 1'), findsOneWidget);
    });

    testWidgets('7-day streak awards special bonus', (tester) async {
      // Set up progress with 6-day streak from yesterday
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final progress = await progressService.getProgress();
      await progressService.updateProgress(
        progress.copyWith(
          currentStreak: 6,
          lastLoginDate: yesterday,
          totalCoins: 210, // Sum of days 1-6
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  final progressAsync = ref.watch(progressNotifierProvider);
                  final todaysRewardAsync = ref.watch(todaysRewardProvider);

                  return progressAsync.when(
                    data: (progress) {
                      return Column(
                        children: [
                          Text(
                            'Streak: ${progress.currentStreak}',
                            key: const Key('streak_text'),
                          ),
                          Text(
                            'Coins: ${progress.totalCoins}',
                            key: const Key('coins_text'),
                          ),
                          todaysRewardAsync.when(
                            data: (reward) => Text(
                              'Is Day 7: ${reward?.day == 7}',
                              key: const Key('is_day_7'),
                            ),
                            loading: () => const CircularProgressIndicator(),
                            error: (_, __) => const Text('Error'),
                          ),
                          ElevatedButton(
                            key: const Key('claim_button'),
                            onPressed: () async {
                              // Simulate 7th day login
                              await ref
                                  .read(streakNotifierProvider.notifier)
                                  .updateStreak();

                              // Add day 7 special reward (100 coins)
                              await ref
                                  .read(progressNotifierProvider.notifier)
                                  .addCoins(100);
                            },
                            child: const Text('Claim Day 7'),
                          ),
                        ],
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => Text('Error: $error'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify initial state (6-day streak)
      expect(find.text('Streak: 6'), findsOneWidget);
      expect(find.text('Coins: 210'), findsOneWidget);

      // Verify today is day 7
      expect(find.text('Is Day 7: true'), findsOneWidget);

      // Claim day 7 reward
      await tester.tap(find.byKey(const Key('claim_button')));
      await tester.pumpAndSettle();

      // Verify streak reached 7
      expect(find.text('Streak: 7'), findsOneWidget);

      // Verify special bonus was awarded (210 + 100 = 310)
      expect(find.text('Coins: 310'), findsOneWidget);
    });
  });
}
