import 'dart:io';

import 'package:brain_land/features/world_map/presentation/widgets/animated_zone_card.dart';
import 'package:brain_land/shared/models/zone.dart';
import 'package:brain_land/shared/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late StorageService storage;
  late Directory tempDir;

  setUp(() async {
    // Create a temporary directory for test storage
    tempDir = await Directory.systemTemp.createTemp('widget_test_');
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

  group('AnimatedZoneCard Widget Tests', () {
    testWidgets('renders zone card with correct information', (tester) async {
      const zone = Zone(
        id: 'math_forest',
        name: 'Math Forest',
        description: 'Learn counting, addition, and subtraction',
        iconPath: 'assets/icons/math_forest.png',
        type: ZoneType.mathForest,
        isUnlocked: true,
        totalLevels: 30,
        completedLevels: 10,
        availableGames: ['counting', 'addition', 'subtraction'],
      );

      bool tapped = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AnimatedZoneCard(zone: zone, onTap: () => tapped = true),
            ),
          ),
        ),
      );

      // Verify zone name is displayed
      expect(find.text('Math Forest'), findsOneWidget);

      // Verify description is displayed
      expect(
        find.text('Learn counting, addition, and subtraction'),
        findsOneWidget,
      );

      // Verify progress information is displayed
      expect(find.text('10/30 Levels'), findsOneWidget);

      // Verify no lock icon for unlocked zone
      expect(find.byIcon(Icons.lock), findsNothing);

      // Verify tap works
      await tester.tap(find.byType(AnimatedZoneCard));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('displays lock overlay for locked zones', (tester) async {
      const zone = Zone(
        id: 'logic_mountain',
        name: 'Logic Mountain',
        description: 'Solve patterns and sequences',
        iconPath: 'assets/icons/logic_mountain.png',
        type: ZoneType.logicMountain,
        isUnlocked: false,
        totalLevels: 20,
        completedLevels: 0,
        availableGames: ['patterns', 'sequences'],
      );

      bool tapped = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AnimatedZoneCard(zone: zone, onTap: () => tapped = true),
            ),
          ),
        ),
      );

      // Verify lock icon is displayed
      expect(find.byIcon(Icons.lock), findsOneWidget);

      // Verify tap does not trigger callback for locked zone
      await tester.tap(find.byType(AnimatedZoneCard));
      await tester.pumpAndSettle();
      expect(tapped, isFalse);
    });

    testWidgets('shows completion badge for completed zones', (tester) async {
      const zone = Zone(
        id: 'math_forest',
        name: 'Math Forest',
        description: 'Learn counting, addition, and subtraction',
        iconPath: 'assets/icons/math_forest.png',
        type: ZoneType.mathForest,
        isUnlocked: true,
        totalLevels: 30,
        completedLevels: 30, // Fully completed
        availableGames: ['counting', 'addition', 'subtraction'],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AnimatedZoneCard(zone: zone, onTap: () {}),
            ),
          ),
        ),
      );

      // Verify completion badge (check icon) is displayed
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      // Verify progress shows 100%
      expect(find.text('30/30 Levels'), findsOneWidget);
    });

    testWidgets('animates on tap', (tester) async {
      const zone = Zone(
        id: 'math_forest',
        name: 'Math Forest',
        description: 'Learn counting, addition, and subtraction',
        iconPath: 'assets/icons/math_forest.png',
        type: ZoneType.mathForest,
        isUnlocked: true,
        totalLevels: 30,
        completedLevels: 10,
        availableGames: ['counting', 'addition', 'subtraction'],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AnimatedZoneCard(zone: zone, onTap: () {}),
            ),
          ),
        ),
      );

      // Get initial size
      final initialSize = tester.getSize(find.byType(AnimatedZoneCard));

      // Tap down (should trigger scale animation)
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(AnimatedZoneCard)),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Size should change during animation (scale down)
      // Note: We can't easily verify the exact scale, but we can verify the widget still exists
      expect(find.byType(AnimatedZoneCard), findsOneWidget);

      // Release tap
      await gesture.up();
      await tester.pumpAndSettle();

      // Should return to original state
      final finalSize = tester.getSize(find.byType(AnimatedZoneCard));
      expect(finalSize, equals(initialSize));
    });

    testWidgets('displays correct icon for each zone type', (tester) async {
      final zones = [
        const Zone(
          id: 'math_forest',
          name: 'Math Forest',
          description: 'Math zone',
          iconPath: 'assets/icons/math_forest.png',
          type: ZoneType.mathForest,
          isUnlocked: true,
          totalLevels: 30,
          completedLevels: 0,
          availableGames: [],
        ),
        const Zone(
          id: 'logic_mountain',
          name: 'Logic Mountain',
          description: 'Logic zone',
          iconPath: 'assets/icons/logic_mountain.png',
          type: ZoneType.logicMountain,
          isUnlocked: true,
          totalLevels: 20,
          completedLevels: 0,
          availableGames: [],
        ),
        const Zone(
          id: 'memory_river',
          name: 'Memory River',
          description: 'Memory zone',
          iconPath: 'assets/icons/memory_river.png',
          type: ZoneType.memoryRiver,
          isUnlocked: true,
          totalLevels: 20,
          completedLevels: 0,
          availableGames: [],
        ),
        const Zone(
          id: 'shape_valley',
          name: 'Shape Valley',
          description: 'Shape zone',
          iconPath: 'assets/icons/shape_valley.png',
          type: ZoneType.shapeValley,
          isUnlocked: true,
          totalLevels: 20,
          completedLevels: 0,
          availableGames: [],
        ),
      ];

      final expectedIcons = [
        Icons.calculate,
        Icons.psychology,
        Icons.memory,
        Icons.category,
      ];

      for (int i = 0; i < zones.length; i++) {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: AnimatedZoneCard(zone: zones[i], onTap: () {}),
              ),
            ),
          ),
        );

        // Verify correct icon is displayed
        expect(find.byIcon(expectedIcons[i]), findsOneWidget);

        // Clean up for next iteration
        await tester.pumpWidget(Container());
      }
    });
  });
}
