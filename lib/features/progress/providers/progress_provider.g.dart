// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$progressStorageServiceHash() =>
    r'ad5614c6e4edfa1e3ad8758dfdece20ea78eef18';

/// Provider for ProgressStorageService
///
/// Copied from [progressStorageService].
@ProviderFor(progressStorageService)
final progressStorageServiceProvider =
    Provider<ProgressStorageService>.internal(
  progressStorageService,
  name: r'progressStorageServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$progressStorageServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ProgressStorageServiceRef = ProviderRef<ProgressStorageService>;
String _$debugProgressHelperHash() =>
    r'89150b9c9e02b1bf688dd3ae8f9ed9afcf7c4f5a';

/// Provider for DebugProgressHelper (only in debug mode)
///
/// Copied from [debugProgressHelper].
@ProviderFor(debugProgressHelper)
final debugProgressHelperProvider = Provider<DebugProgressHelper?>.internal(
  debugProgressHelper,
  name: r'debugProgressHelperProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$debugProgressHelperHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DebugProgressHelperRef = ProviderRef<DebugProgressHelper?>;
String _$totalStarsHash() => r'10467fe0f45319698ae1bd6e12da2472e6937e22';

/// Provider for total stars
///
/// Copied from [totalStars].
@ProviderFor(totalStars)
final totalStarsProvider = FutureProvider<int>.internal(
  totalStars,
  name: r'totalStarsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$totalStarsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TotalStarsRef = FutureProviderRef<int>;
String _$totalCoinsHash() => r'9ce207026ea3605eede9887c7ca6ed5b788e7535';

/// Provider for total coins
///
/// Copied from [totalCoins].
@ProviderFor(totalCoins)
final totalCoinsProvider = FutureProvider<int>.internal(
  totalCoins,
  name: r'totalCoinsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$totalCoinsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TotalCoinsRef = FutureProviderRef<int>;
String _$currentStreakHash() => r'1045b295a850d907d1022a4b7a5d8e246110ab2a';

/// Provider for current streak
///
/// Copied from [currentStreak].
@ProviderFor(currentStreak)
final currentStreakProvider = FutureProvider<int>.internal(
  currentStreak,
  name: r'currentStreakProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentStreakHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentStreakRef = FutureProviderRef<int>;
String _$zoneProgressHash() => r'109923e2bdef8e7fb773f2215b69c2670e1908ba';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider for zone progress
///
/// Copied from [zoneProgress].
@ProviderFor(zoneProgress)
const zoneProgressProvider = ZoneProgressFamily();

/// Provider for zone progress
///
/// Copied from [zoneProgress].
class ZoneProgressFamily extends Family<AsyncValue<ZoneProgress?>> {
  /// Provider for zone progress
  ///
  /// Copied from [zoneProgress].
  const ZoneProgressFamily();

  /// Provider for zone progress
  ///
  /// Copied from [zoneProgress].
  ZoneProgressProvider call(
    String zoneId,
  ) {
    return ZoneProgressProvider(
      zoneId,
    );
  }

  @override
  ZoneProgressProvider getProviderOverride(
    covariant ZoneProgressProvider provider,
  ) {
    return call(
      provider.zoneId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'zoneProgressProvider';
}

/// Provider for zone progress
///
/// Copied from [zoneProgress].
class ZoneProgressProvider extends FutureProvider<ZoneProgress?> {
  /// Provider for zone progress
  ///
  /// Copied from [zoneProgress].
  ZoneProgressProvider(
    String zoneId,
  ) : this._internal(
          (ref) => zoneProgress(
            ref as ZoneProgressRef,
            zoneId,
          ),
          from: zoneProgressProvider,
          name: r'zoneProgressProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$zoneProgressHash,
          dependencies: ZoneProgressFamily._dependencies,
          allTransitiveDependencies:
              ZoneProgressFamily._allTransitiveDependencies,
          zoneId: zoneId,
        );

  ZoneProgressProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.zoneId,
  }) : super.internal();

  final String zoneId;

  @override
  Override overrideWith(
    FutureOr<ZoneProgress?> Function(ZoneProgressRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ZoneProgressProvider._internal(
        (ref) => create(ref as ZoneProgressRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        zoneId: zoneId,
      ),
    );
  }

  @override
  FutureProviderElement<ZoneProgress?> createElement() {
    return _ZoneProgressProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ZoneProgressProvider && other.zoneId == zoneId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, zoneId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ZoneProgressRef on FutureProviderRef<ZoneProgress?> {
  /// The parameter `zoneId` of this provider.
  String get zoneId;
}

class _ZoneProgressProviderElement extends FutureProviderElement<ZoneProgress?>
    with ZoneProgressRef {
  _ZoneProgressProviderElement(super.provider);

  @override
  String get zoneId => (origin as ZoneProgressProvider).zoneId;
}

String _$zoneCompletionPercentageHash() =>
    r'147e3781de8e194b705559a7073c2ef8a5ab9c5f';

/// Provider for zone completion percentage
///
/// Copied from [zoneCompletionPercentage].
@ProviderFor(zoneCompletionPercentage)
const zoneCompletionPercentageProvider = ZoneCompletionPercentageFamily();

/// Provider for zone completion percentage
///
/// Copied from [zoneCompletionPercentage].
class ZoneCompletionPercentageFamily extends Family<AsyncValue<double>> {
  /// Provider for zone completion percentage
  ///
  /// Copied from [zoneCompletionPercentage].
  const ZoneCompletionPercentageFamily();

  /// Provider for zone completion percentage
  ///
  /// Copied from [zoneCompletionPercentage].
  ZoneCompletionPercentageProvider call(
    String zoneId,
    int totalLevels,
  ) {
    return ZoneCompletionPercentageProvider(
      zoneId,
      totalLevels,
    );
  }

  @override
  ZoneCompletionPercentageProvider getProviderOverride(
    covariant ZoneCompletionPercentageProvider provider,
  ) {
    return call(
      provider.zoneId,
      provider.totalLevels,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'zoneCompletionPercentageProvider';
}

/// Provider for zone completion percentage
///
/// Copied from [zoneCompletionPercentage].
class ZoneCompletionPercentageProvider extends FutureProvider<double> {
  /// Provider for zone completion percentage
  ///
  /// Copied from [zoneCompletionPercentage].
  ZoneCompletionPercentageProvider(
    String zoneId,
    int totalLevels,
  ) : this._internal(
          (ref) => zoneCompletionPercentage(
            ref as ZoneCompletionPercentageRef,
            zoneId,
            totalLevels,
          ),
          from: zoneCompletionPercentageProvider,
          name: r'zoneCompletionPercentageProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$zoneCompletionPercentageHash,
          dependencies: ZoneCompletionPercentageFamily._dependencies,
          allTransitiveDependencies:
              ZoneCompletionPercentageFamily._allTransitiveDependencies,
          zoneId: zoneId,
          totalLevels: totalLevels,
        );

  ZoneCompletionPercentageProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.zoneId,
    required this.totalLevels,
  }) : super.internal();

  final String zoneId;
  final int totalLevels;

  @override
  Override overrideWith(
    FutureOr<double> Function(ZoneCompletionPercentageRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ZoneCompletionPercentageProvider._internal(
        (ref) => create(ref as ZoneCompletionPercentageRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        zoneId: zoneId,
        totalLevels: totalLevels,
      ),
    );
  }

  @override
  FutureProviderElement<double> createElement() {
    return _ZoneCompletionPercentageProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ZoneCompletionPercentageProvider &&
        other.zoneId == zoneId &&
        other.totalLevels == totalLevels;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, zoneId.hashCode);
    hash = _SystemHash.combine(hash, totalLevels.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ZoneCompletionPercentageRef on FutureProviderRef<double> {
  /// The parameter `zoneId` of this provider.
  String get zoneId;

  /// The parameter `totalLevels` of this provider.
  int get totalLevels;
}

class _ZoneCompletionPercentageProviderElement
    extends FutureProviderElement<double> with ZoneCompletionPercentageRef {
  _ZoneCompletionPercentageProviderElement(super.provider);

  @override
  String get zoneId => (origin as ZoneCompletionPercentageProvider).zoneId;
  @override
  int get totalLevels =>
      (origin as ZoneCompletionPercentageProvider).totalLevels;
}

String _$unlockedPetsHash() => r'05836f8d7c45c77b41d7e0c37d6b1a9871cb3375';

/// Provider for unlocked pets
///
/// Copied from [unlockedPets].
@ProviderFor(unlockedPets)
final unlockedPetsProvider = FutureProvider<List<String>>.internal(
  unlockedPets,
  name: r'unlockedPetsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$unlockedPetsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UnlockedPetsRef = FutureProviderRef<List<String>>;
String _$unlockedStickersHash() => r'190717bc8563c7f12f81ae8fdd7cb51518a0a765';

/// Provider for unlocked stickers
///
/// Copied from [unlockedStickers].
@ProviderFor(unlockedStickers)
final unlockedStickersProvider = FutureProvider<List<String>>.internal(
  unlockedStickers,
  name: r'unlockedStickersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unlockedStickersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UnlockedStickersRef = FutureProviderRef<List<String>>;
String _$unlockedAvatarItemsHash() =>
    r'fa81487654b8806b9a4727bd29329155b178578b';

/// Provider for unlocked avatar items
///
/// Copied from [unlockedAvatarItems].
@ProviderFor(unlockedAvatarItems)
final unlockedAvatarItemsProvider = FutureProvider<List<String>>.internal(
  unlockedAvatarItems,
  name: r'unlockedAvatarItemsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unlockedAvatarItemsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UnlockedAvatarItemsRef = FutureProviderRef<List<String>>;
String _$formattedPlayTimeHash() => r'4223c476d39a5a56894fc4a46b99295165a627ae';

/// Provider for total play time (formatted)
///
/// Copied from [formattedPlayTime].
@ProviderFor(formattedPlayTime)
final formattedPlayTimeProvider = FutureProvider<String>.internal(
  formattedPlayTime,
  name: r'formattedPlayTimeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$formattedPlayTimeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FormattedPlayTimeRef = FutureProviderRef<String>;
String _$progressNotifierHash() => r'f18541778bdd30d7d2747d6773e9368a68e4605c';

/// Progress state notifier
///
/// Copied from [ProgressNotifier].
@ProviderFor(ProgressNotifier)
final progressNotifierProvider =
    AsyncNotifierProvider<ProgressNotifier, PlayerProgress>.internal(
  ProgressNotifier.new,
  name: r'progressNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$progressNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ProgressNotifier = AsyncNotifier<PlayerProgress>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
