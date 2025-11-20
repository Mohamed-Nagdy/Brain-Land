import 'package:brain_land/shared/models/pet.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
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
