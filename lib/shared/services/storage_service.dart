import 'package:adventure_world/features/memory_river/models/memory_level.dart';
import 'package:adventure_world/features/shape_valley/models/shape.dart';
import 'package:adventure_world/features/shape_valley/models/shape_level.dart';
import 'package:adventure_world/shared/models/pet.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../features/logic_mountain/models/logic_level.dart';
import '../../features/math_forest/models/math_level.dart';
import '../models/avatar.dart';
import '../models/level.dart';
import '../models/player_progress.dart';
import '../models/reward.dart';
import '../models/zone.dart';
import '../models/zone_progress.dart';

/// Service for managing local storage using Hive
class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();

  StorageService._();

  bool _isInitialized = false;

  /// Initialize Hive and open all required boxes
  ///
  /// For testing, pass a custom [path] to avoid using Flutter plugins
  Future<void> initialize({String? path}) async {
    if (_isInitialized) return;

    try {
      if (path != null) {
        // For testing: use plain Hive.init with custom path
        Hive.init(path);
      } else {
        // For production: use Hive.initFlutter
        await Hive.initFlutter();
      }

      // Register all type adapters
      _registerAdapters();

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

  /// Register all Hive type adapters
  void _registerAdapters() {
    // Only register if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ZoneTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ZoneAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(LevelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(ZoneProgressAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(PlayerProgressAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(AvatarTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(AvatarAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(ItemCategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(CustomizationItemAdapter());
    }
    if (!Hive.isAdapterRegistered(9)) {
      Hive.registerAdapter(RewardTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(RewardAdapter());
    }
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(ChestTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(12)) {
      Hive.registerAdapter(RewardChestAdapter());
    }
    if (!Hive.isAdapterRegistered(13)) {
      Hive.registerAdapter(PetTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(14)) {
      Hive.registerAdapter(PetAnimationAdapter());
    }
    if (!Hive.isAdapterRegistered(15)) {
      Hive.registerAdapter(PetAdapter());
    }
    if (!Hive.isAdapterRegistered(16)) {
      Hive.registerAdapter(LogicLevelAdapter());
    }
    if (!Hive.isAdapterRegistered(17)) {
      Hive.registerAdapter(MathLevelAdapter());
    }
    if (!Hive.isAdapterRegistered(18)) {
      Hive.registerAdapter(MemoryLevelAdapter());
    }

    if (!Hive.isAdapterRegistered(19)) {
      Hive.registerAdapter(ShapeTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(20)) {
      Hive.registerAdapter(ShapeLevelAdapter());
    }
    if (!Hive.isAdapterRegistered(21)) {
      Hive.registerAdapter(ShapeColorAdapter());
    }
    if (!Hive.isAdapterRegistered(22)) {
      Hive.registerAdapter(SortingRuleAdapter());
    }
    if (!Hive.isAdapterRegistered(23)) {
      Hive.registerAdapter(ShapeTargetAdapter());
    }
    if (!Hive.isAdapterRegistered(24)) {
      Hive.registerAdapter(ShapeAdapter());
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

  /// Save data to a box with retry mechanism and exponential backoff
  ///
  /// Implements retry logic with exponential backoff:
  /// - Attempt 1: immediate
  /// - Attempt 2: 100ms delay
  /// - Attempt 3: 200ms delay
  /// - Attempt 4: 400ms delay (if maxRetries > 3)
  ///
  /// Throws [StorageException] if all retry attempts fail
  Future<void> save({
    required String boxName,
    required String key,
    required dynamic value,
    int maxRetries = 3,
    void Function(int attempt, int maxRetries)? onRetry,
  }) async {
    if (maxRetries < 1) {
      throw ArgumentError('maxRetries must be at least 1');
    }

    int attempts = 0;
    Duration delay = const Duration(milliseconds: 100);
    Exception? lastException;

    while (attempts < maxRetries) {
      try {
        final box = getBox(boxName);
        await box.put(key, value);
        return; // Success!
      } catch (e, stackTrace) {
        attempts++;
        lastException = StorageException(
          message: 'Save attempt $attempts failed: $e',
          severity: attempts >= maxRetries
              ? ErrorSeverity.high
              : ErrorSeverity.medium,
          stackTrace: stackTrace,
        );

        if (attempts >= maxRetries) {
          // All retries exhausted
          throw StorageException(
            message: 'Failed to save data after $maxRetries attempts: $e',
            severity: ErrorSeverity.high,
            stackTrace: stackTrace,
          );
        }

        // Notify about retry attempt
        onRetry?.call(attempts, maxRetries);

        // Wait before retrying with exponential backoff
        await Future.delayed(delay);
        delay *= 2; // Exponential backoff: 100ms, 200ms, 400ms, etc.
      }
    }

    // This should never be reached, but just in case
    throw lastException ??
        StorageException(
          message: 'Unexpected error during save operation',
          severity: ErrorSeverity.high,
        );
  }

  /// Load data from a box
  ///
  /// Returns null if the key doesn't exist or if data cannot be loaded.
  /// Throws [StorageException] for critical errors.
  T? load<T>({required String boxName, required String key, T? defaultValue}) {
    try {
      final box = getBox(boxName);
      final value = box.get(key);

      if (value == null) {
        return defaultValue;
      }

      // Attempt to cast to the expected type
      if (value is T) {
        return value;
      } else {
        throw StorageException(
          message: 'Type mismatch: expected $T but got ${value.runtimeType}',
          severity: ErrorSeverity.medium,
        );
      }
    } catch (e, stackTrace) {
      if (e is StorageException) {
        rethrow;
      }
      throw StorageException(
        message: 'Failed to load data for key "$key": $e',
        severity: ErrorSeverity.medium,
        stackTrace: stackTrace,
      );
    }
  }

  /// Delete data from a box with retry mechanism
  ///
  /// Implements retry logic for delete operations.
  /// Throws [StorageException] if all retry attempts fail.
  Future<void> delete({
    required String boxName,
    required String key,
    int maxRetries = 3,
  }) async {
    int attempts = 0;
    Duration delay = const Duration(milliseconds: 100);

    while (attempts < maxRetries) {
      try {
        final box = getBox(boxName);
        await box.delete(key);
        return; // Success!
      } catch (e, stackTrace) {
        attempts++;
        if (attempts >= maxRetries) {
          throw StorageException(
            message: 'Failed to delete data after $maxRetries attempts: $e',
            severity: ErrorSeverity.medium,
            stackTrace: stackTrace,
          );
        }
        await Future.delayed(delay);
        delay *= 2; // Exponential backoff
      }
    }
  }

  /// Clear all data from a box with retry mechanism
  ///
  /// Implements retry logic for clear operations.
  /// Throws [StorageException] if all retry attempts fail.
  Future<void> clearBox(String boxName, {int maxRetries = 3}) async {
    int attempts = 0;
    Duration delay = const Duration(milliseconds: 100);

    while (attempts < maxRetries) {
      try {
        final box = getBox(boxName);
        await box.clear();
        return; // Success!
      } catch (e, stackTrace) {
        attempts++;
        if (attempts >= maxRetries) {
          throw StorageException(
            message: 'Failed to clear box after $maxRetries attempts: $e',
            severity: ErrorSeverity.medium,
            stackTrace: stackTrace,
          );
        }
        await Future.delayed(delay);
        delay *= 2; // Exponential backoff
      }
    }
  }

  /// Save multiple key-value pairs in a batch with retry mechanism
  ///
  /// More efficient than multiple individual save calls.
  /// Throws [StorageException] if the batch operation fails after all retries.
  Future<void> saveBatch({
    required String boxName,
    required Map<String, dynamic> entries,
    int maxRetries = 3,
    void Function(int attempt, int maxRetries)? onRetry,
  }) async {
    if (entries.isEmpty) return;

    int attempts = 0;
    Duration delay = const Duration(milliseconds: 100);

    while (attempts < maxRetries) {
      try {
        final box = getBox(boxName);
        await box.putAll(entries);
        return; // Success!
      } catch (e, stackTrace) {
        attempts++;
        if (attempts >= maxRetries) {
          throw StorageException(
            message: 'Failed to save batch after $maxRetries attempts: $e',
            severity: ErrorSeverity.high,
            stackTrace: stackTrace,
          );
        }

        // Notify about retry attempt
        onRetry?.call(attempts, maxRetries);

        await Future.delayed(delay);
        delay *= 2; // Exponential backoff
      }
    }
  }

  /// Check if storage is initialized
  bool get isInitialized => _isInitialized;

  /// Get all keys in a box
  List<String> getKeys(String boxName) {
    try {
      final box = getBox(boxName);
      return box.keys.cast<String>().toList();
    } catch (e, stackTrace) {
      throw StorageException(
        message: 'Failed to get keys from box: $e',
        severity: ErrorSeverity.low,
        stackTrace: stackTrace,
      );
    }
  }

  /// Check if a key exists in a box
  bool containsKey({required String boxName, required String key}) {
    try {
      final box = getBox(boxName);
      return box.containsKey(key);
    } catch (e, stackTrace) {
      throw StorageException(
        message: 'Failed to check key existence: $e',
        severity: ErrorSeverity.low,
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
