import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Saves screenshots from integration_test/app_test.dart to build/shots/.
Future<void> main() => integrationDriver(
  onScreenshot: (name, bytes, [args]) async {
    File('build/shots/$name.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes);
    return true;
  },
);
