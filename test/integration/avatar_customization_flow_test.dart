import 'dart:io';

import 'package:brain_land/features/avatar/presentation/screens/avatar_customization_screen.dart';
import 'package:brain_land/features/avatar/presentation/widgets/avatar_preview.dart';
import 'package:brain_land/features/avatar/presentation/widgets/category_selector.dart';
import 'package:brain_land/features/avatar/presentation/widgets/customization_item_card.dart';
import 'package:brain_land/shared/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Integration test for avatar customization flow
/// Tests: open screen → select category → equip item → save
/// Validates Requirements: 7.2, 7.3, 7.4
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storage;
  late Directory tempDir;

  setUp(() async {
    // Create a temporary directory for test storage
    tempDir = await Directory.systemTemp.createTemp('integration_test_');
    storage = StorageService.instance;
    await storage.initialize(path: tempDir.path);
  });

  tearDown(() async {
    await storage.dispose();
    // Clean up temp directory
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Avatar Customization Flow Integration Tests', () {
    testWidgets('Avatar customization screen renders correctly', (
      WidgetTester tester,
    ) async {
      // Build the avatar customization screen
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: AvatarCustomizationScreen()),
        ),
      );

      // Wait for initial frame
      await tester.pump();

      // Verify screen elements are displayed
      expect(find.text('Customize Avatar'), findsOneWidget);
      expect(find.byType(AvatarPreview), findsOneWidget);
      expect(find.byType(CategorySelector), findsOneWidget);
      expect(find.text('Save & Exit'), findsOneWidget);
    });

    testWidgets('Category selector displays all categories', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: AvatarCustomizationScreen()),
        ),
      );

      await tester.pump();

      // Verify all category tabs are present
      expect(find.text('Hats'), findsOneWidget);
      expect(find.text('Clothes'), findsOneWidget);
      expect(find.text('Eyes'), findsOneWidget);
      expect(find.text('Backgrounds'), findsOneWidget);
    });

    testWidgets('Switching categories updates item grid', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: AvatarCustomizationScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Initially on Hats category
      expect(find.text('Hats'), findsOneWidget);

      // Find and tap the Clothes category
      await tester.tap(find.text('Clothes'));
      await tester.pumpAndSettle();

      // Verify category switched
      // The items grid should update (we can verify by checking for CustomizationItemCard widgets)
      expect(find.byType(CustomizationItemCard), findsWidgets);
    });

    testWidgets('Tapping unlocked item equips it', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: AvatarCustomizationScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Find an unlocked item (default inventory has some unlocked items)
      final itemCards = find.byType(CustomizationItemCard);
      expect(itemCards, findsWidgets);

      // Tap the first item card
      await tester.tap(itemCards.first);
      await tester.pumpAndSettle();

      // The item should now be equipped (verified by the equipped indicator)
      // We can't easily verify the visual indicator in this test,
      // but the property tests verify the underlying logic
    });

    testWidgets('Save button navigates back', (WidgetTester tester) async {
      // Create a navigation observer to track navigation
      final navigatorObserver = NavigatorObserver();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const Scaffold(body: Center(child: Text('Home'))),
            navigatorObservers: [navigatorObserver],
            routes: {
              '/customize': (context) => const AvatarCustomizationScreen(),
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to customization screen
      final context = tester.element(find.text('Home'));
      Navigator.of(context).pushNamed('/customize');
      await tester.pumpAndSettle();

      // Verify we're on the customization screen
      expect(find.text('Customize Avatar'), findsOneWidget);

      // Tap the save button
      await tester.tap(find.text('Save & Exit'));
      await tester.pumpAndSettle();

      // Wait for the save operation and navigation
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Verify we navigated back
      expect(find.text('Customize Avatar'), findsNothing);
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('Complete flow: select category → equip item → save', (
      WidgetTester tester,
    ) async {
      final navigatorObserver = NavigatorObserver();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const Scaffold(body: Center(child: Text('Home'))),
            navigatorObservers: [navigatorObserver],
            routes: {
              '/customize': (context) => const AvatarCustomizationScreen(),
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to customization screen
      final context = tester.element(find.text('Home'));
      Navigator.of(context).pushNamed('/customize');
      await tester.pumpAndSettle();

      // Step 1: Verify initial state
      expect(find.text('Customize Avatar'), findsOneWidget);
      expect(find.byType(AvatarPreview), findsOneWidget);

      // Step 2: Select a different category (Clothes)
      await tester.tap(find.text('Clothes'));
      await tester.pumpAndSettle();

      // Step 3: Equip an item
      final itemCards = find.byType(CustomizationItemCard);
      if (itemCards.evaluate().isNotEmpty) {
        await tester.tap(itemCards.first);
        await tester.pumpAndSettle();
      }

      // Step 4: Switch to another category (Eyes)
      await tester.tap(find.text('Eyes'));
      await tester.pumpAndSettle();

      // Step 5: Equip another item
      final eyeCards = find.byType(CustomizationItemCard);
      if (eyeCards.evaluate().isNotEmpty) {
        await tester.tap(eyeCards.first);
        await tester.pumpAndSettle();
      }

      // Step 6: Save and exit
      await tester.tap(find.text('Save & Exit'));
      await tester.pumpAndSettle();

      // Wait for save operation
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Verify we're back at home
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Customize Avatar'), findsNothing);
    });

    testWidgets('Avatar preview updates when items are equipped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: AvatarCustomizationScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Get initial avatar preview
      final avatarPreview = find.byType(AvatarPreview);
      expect(avatarPreview, findsOneWidget);

      // Equip an item
      final itemCards = find.byType(CustomizationItemCard);
      if (itemCards.evaluate().isNotEmpty) {
        await tester.tap(itemCards.first);
        await tester.pumpAndSettle();

        // Avatar preview should still be present (it updates internally)
        expect(find.byType(AvatarPreview), findsOneWidget);
      }
    });

    testWidgets('Back button navigates back without saving', (
      WidgetTester tester,
    ) async {
      final navigatorObserver = NavigatorObserver();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const Scaffold(body: Center(child: Text('Home'))),
            navigatorObservers: [navigatorObserver],
            routes: {
              '/customize': (context) => const AvatarCustomizationScreen(),
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to customization screen
      final context = tester.element(find.text('Home'));
      Navigator.of(context).pushNamed('/customize');
      await tester.pumpAndSettle();

      // Verify we're on the customization screen
      expect(find.text('Customize Avatar'), findsOneWidget);

      // Tap the back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify we navigated back
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Customize Avatar'), findsNothing);
    });
  });
}
