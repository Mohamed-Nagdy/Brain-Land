import 'dart:io';

import 'package:brain_land/main.dart';
import 'package:brain_land/shared/services/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late StorageService storage;
  late Directory tempDir;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
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

  testWidgets('BrainLand app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: BrainLandApp()));
    await tester.pump();

    // Verify that the app builds without errors
    expect(find.byType(BrainLandApp), findsOneWidget);
  });
}
