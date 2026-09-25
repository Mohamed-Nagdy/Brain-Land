import 'dart:io';

import 'package:brain_land/data/store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

/// A fresh on-disk Hive store in a temp folder, like the app's own.
Future<Box<dynamic>> openTestStore() async {
  final dir = await Directory.systemTemp.createTemp('brainland_test');
  Hive.init(dir.path);
  return Hive.openBox<dynamic>(kStoreBox);
}

ProviderContainer containerWith(Box<dynamic> store) =>
    ProviderContainer(overrides: [storeProvider.overrideWithValue(store)]);
