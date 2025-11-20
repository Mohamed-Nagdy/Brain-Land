import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/logic_storage_service.dart';

/// Provider for the LogicStorageService
final logicStorageServiceProvider = Provider<LogicStorageService>((ref) {
  return LogicStorageService();
});
