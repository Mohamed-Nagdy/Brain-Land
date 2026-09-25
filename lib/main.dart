import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/audio.dart';
import 'data/legacy_import.dart';
import 'data/store.dart';

/// No permission prompts, tracking or network calls at launch: open local
/// storage, load the sound list and show the map. Ads (Android only) start
/// after the first screen is up.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final store = await Hive.openBox<dynamic>(kStoreBox);
  await importLegacyProgress(store);

  final container = ProviderContainer(
    overrides: [storeProvider.overrideWithValue(store)],
  );
  await container.read(audioProvider).load();
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const BrainLandApp(),
    ),
  );
}
