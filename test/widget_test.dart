import 'package:brain_land/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BrainLand app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: BrainLandApp()));

    // Verify that the app title is displayed
    expect(find.text('BrainLand'), findsOneWidget);
    expect(find.text('Welcome to BrainLand!'), findsOneWidget);
    expect(find.text('✅ Project setup complete'), findsOneWidget);
    expect(find.text('🎨 Emoji-based design ready'), findsOneWidget);

    // Verify emojis are displayed
    expect(find.text('🌳'), findsOneWidget);
    expect(find.text('⛰️'), findsOneWidget);
    expect(find.text('🌊'), findsOneWidget);
    expect(find.text('🔷'), findsOneWidget);
    expect(find.text('🐼'), findsOneWidget);
    expect(find.text('🤖'), findsOneWidget);
    expect(find.text('🐱'), findsOneWidget);
  });
}
