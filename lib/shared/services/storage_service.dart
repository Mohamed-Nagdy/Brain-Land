import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';

/// Service for managing local storage using Hive
class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();

  StorageService._();

  bool _isInitialized = false;

  /// Initialize Hive and open all required boxes
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Hive.initFlutter();

      // Open all required boxes
      await Future.wait([
        Hive.openBox(AppConstants.progressBoxName),
        Hive.openBox(AppConstants.avatarBoxName),
        Hive.openBox(AppConstants.rewardsBoxName),
        Hive.openBox(AppConstants.settingsBoxName),
      ]);

      _isInitialized = true;
    } catch (e, stackTrace) {
      throw StorageException(
        message: 'Failed to initialize storage: $e',
        severity: ErrorSeverity.critical,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get a box by name
  Box getBox(String boxName) {
    if (!_isInitialized) {
      throw StorageException(
        message: 'Storage not initialized. Call initialize() first.',
        severity: ErrorSeverity.high,
      );
    }
    return Hive.box(boxName);
  }

  /// Save data to a box with retry mechanism
  Future<void> save({
    required String boxName,
    required String key,
    required dynamic value,
    int maxRetries = 3,
  }) async {
    int attempts = 0;
    Duration delay = const Duration(milliseconds: 100);

    while (attempts < maxRetries) {
      try {
        final box = getBox(boxName);
        await box.put(key, value);
        return;
      } catch (e, stackTrace) {
        attempts++;
        if (attempts >= maxRetries) {
          throw StorageException(
            message: 'Failed to save data after $maxRetries attempts: $e',
            severity: ErrorSeverity.high,
            stackTrace: stackTrace,
          );
        }
        await Future.delayed(delay);
        delay *= 2; // Exponential backoff
      }
    }
  }

  /// Load data from a box
  T? load<T>({required String boxName, required String key}) {
    try {
      final box = getBox(boxName);
      return box.get(key) as T?;
    } catch (e, stackTrace) {
      throw StorageException(
        message: 'Failed to load data: $e',
        severity: ErrorSeverity.medium,
        stackTrace: stackTrace,
      );
    }
  }

  /// Delete data from a box
  Future<void> delete({required String boxName, required String key}) async {
    try {
      final box = getBox(boxName);
      await box.delete(key);
    } catch (e, stackTrace) {
      throw StorageException(
        message: 'Failed to delete data: $e',
        severity: ErrorSeverity.medium,
        stackTrace: stackTrace,
      );
    }
  }

  /// Clear all data from a box
  Future<void> clearBox(String boxName) async {
    try {
      final box = getBox(boxName);
      await box.clear();
    } catch (e, stackTrace) {
      throw StorageException(
        message: 'Failed to clear box: $e',
        severity: ErrorSeverity.medium,
        stackTrace: stackTrace,
      );
    }
  }

  /// Close all boxes and cleanup
  Future<void> dispose() async {
    try {
      await Hive.close();
      _isInitialized = false;
    } catch (e, stackTrace) {
      throw StorageException(
        message: 'Failed to dispose storage: $e',
        severity: ErrorSeverity.low,
        stackTrace: stackTrace,
      );
    }
  }
}
