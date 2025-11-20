import 'package:brain_land/features/rewards/presentation/widgets/chest_animation.dart';
import 'package:brain_land/features/rewards/presentation/widgets/reward_card.dart';
import 'package:brain_land/shared/models/reward.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChestAnimation Widget Tests', () {
    testWidgets('renders chest with correct color for bronze', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ChestAnimation(chestType: ChestType.bronze)),
        ),
      );

      // Verify chest widget is rendered
      expect(find.byType(ChestAnimation), findsOneWidget);

      // Verify lock icon is displayed when not opened
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('calls onTap when chest is tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChestAnimation(
              chestType: ChestType.bronze,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      // Tap the chest
      await tester.tap(find.byType(ChestAnimation));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('does not call onTap when chest is opened', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChestAnimation(
              chestType: ChestType.bronze,
              isOpened: true,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      // Try to tap the opened chest
      await tester.tap(find.byType(ChestAnimation));
      await tester.pump();

      expect(tapped, isFalse);
    });

    testWidgets('hides lock icon when chest is opened', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ChestAnimation(chestType: ChestType.gold, isOpened: true),
          ),
        ),
      );

      // Lock icon should not be visible when opened
      expect(find.byIcon(Icons.lock), findsNothing);
    });
  });

  group('ChestIcon Widget Tests', () {
    testWidgets('renders chest icon for bronze', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ChestIcon(chestType: ChestType.bronze)),
        ),
      );

      expect(find.byType(ChestIcon), findsOneWidget);
      expect(find.byIcon(Icons.card_giftcard), findsOneWidget);
    });
  });

  group('RewardCard Widget Tests', () {
    testWidgets('renders reward card with correct information', (tester) async {
      const reward = Reward(
        id: 'test_coin',
        type: RewardType.coin,
        name: 'Gold Coins',
        description: '100 coins',
        iconPath: 'assets/icons/coin.png',
        rarity: 3,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: RewardCard(reward: reward)),
        ),
      );

      // Wait for animation to complete
      await tester.pumpAndSettle();

      // Verify reward name is displayed
      expect(find.text('Gold Coins'), findsOneWidget);

      // Verify rarity label is displayed
      expect(find.text('Rare'), findsOneWidget);
    });

    testWidgets('displays correct rarity for common reward', (tester) async {
      const reward = Reward(
        id: 'test_coin',
        type: RewardType.coin,
        name: 'Small Coins',
        description: 'A few coins',
        iconPath: 'assets/icons/coin.png',
        rarity: 1,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: RewardCard(reward: reward)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Common'), findsOneWidget);
      expect(find.text('Small Coins'), findsOneWidget);
    });

    testWidgets('displays correct rarity for legendary reward', (tester) async {
      const reward = Reward(
        id: 'test_pet',
        type: RewardType.pet,
        name: 'Phoenix',
        description: 'A legendary bird',
        iconPath: 'assets/pets/phoenix.png',
        rarity: 5,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: RewardCard(reward: reward)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Legendary'), findsOneWidget);
    });

    testWidgets('calls onTap when reward card is tapped', (tester) async {
      bool tapped = false;

      const reward = Reward(
        id: 'test_reward',
        type: RewardType.coin,
        name: 'Test Reward',
        description: 'Test',
        iconPath: 'test.png',
        rarity: 2,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RewardCard(reward: reward, onTap: () => tapped = true),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byType(RewardCard));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('displays correct icon for coin reward', (tester) async {
      const reward = Reward(
        id: 'coin',
        type: RewardType.coin,
        name: 'Coins',
        description: 'Test',
        iconPath: 'test.png',
        rarity: 1,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: RewardCard(reward: reward)),
        ),
      );

      await tester.pumpAndSettle();

      // Verify coin icon is displayed
      expect(find.byIcon(Icons.monetization_on), findsOneWidget);
    });
  });

  group('CompactRewardCard Widget Tests', () {
    testWidgets('renders compact reward card', (tester) async {
      const reward = Reward(
        id: 'test',
        type: RewardType.coin,
        name: 'Gold Coins',
        description: 'Test',
        iconPath: 'test.png',
        rarity: 2,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CompactRewardCard(reward: reward)),
        ),
      );

      expect(find.text('Gold Coins'), findsOneWidget);
    });

    testWidgets('calls onTap when compact card is tapped', (tester) async {
      bool tapped = false;

      const reward = Reward(
        id: 'test',
        type: RewardType.coin,
        name: 'Coins',
        description: 'Test',
        iconPath: 'test.png',
        rarity: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactRewardCard(reward: reward, onTap: () => tapped = true),
          ),
        ),
      );

      await tester.tap(find.byType(CompactRewardCard));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });

  group('RewardTypeBadge Widget Tests', () {
    testWidgets('renders badge for coin type', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: RewardTypeBadge(type: RewardType.coin)),
        ),
      );

      expect(find.byIcon(Icons.monetization_on), findsOneWidget);
    });

    testWidgets('renders badge for pet type', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: RewardTypeBadge(type: RewardType.pet)),
        ),
      );

      expect(find.byIcon(Icons.pets), findsOneWidget);
    });
  });
}
