// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$progressStorageServiceHash() =>
    r'80dca1559565b5203dfd47d6a002a8f82b02259b';

/// Provider for ProgressStorageService
///
/// Copied from [progressStorageService].
@ProviderFor(progressStorageService)
final progressStorageServiceProvider =
    AutoDisposeProvider<ProgressStorageService>.internal(
  progressStorageService,
  name: r'progressStorageServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$progressStorageServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ProgressStorageServiceRef
    = AutoDisposeProviderRef<ProgressStorageService>;
String _$totalStarsHash() => r'b8a9b84d3ad437db1f86d910aaa029d327a51e54';

/// Provider for total stars
///
/// Copied from [totalStars].
@ProviderFor(totalStars)
final totalStarsProvider = AutoDisposeFutureProvider<int>.internal(
  totalStars,
  name: r'totalStarsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$totalStarsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TotalStarsRef = AutoDisposeFutureProviderRef<int>;
String _$totalCoinsHash() => r'163d6b4e9d0466aa9c6e66bb43f1ec831339331e';

/// Provider for total coins
///
/// Copied from [totalCoins].
@ProviderFor(totalCoins)
final totalCoinsProvider = AutoDisposeFutureProvider<int>.internal(
  totalCoins,
  name: r'totalCoinsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$totalCoinsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TotalCoinsRef = AutoDisposeFutureProviderRef<int>;
String _$currentStreakHash() => r'9cc29439db51020d0c8c33769a9735b0575bae33';

/// Provider for current streak
///
/// Copied from [currentStreak].
@ProviderFor(currentStreak)
final currentStreakProvider = AutoDisposeFutureProvider<int>.internal(
  currentStreak,
  name: r'currentStreakProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentStreakHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentStreakRef = AutoDisposeFutureProviderRef<int>;
String _$zoneProgressHash() => r'a3f933b57a577fc95ed5d6d41f5bda1d3ed016be';

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
class ZoneProgressProvider extends AutoDisposeFutureProvider<ZoneProgress?> {
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
  AutoDisposeFutureProviderElement<ZoneProgress?> createElement() {
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

mixin ZoneProgressRef on AutoDisposeFutureProviderRef<ZoneProgress?> {
  /// The parameter `zoneId` of this provider.
  String get zoneId;
}

class _ZoneProgressProviderElement
    extends AutoDisposeFutureProviderElement<ZoneProgress?>
    with ZoneProgressRef {
  _ZoneProgressProviderElement(super.provider);

  @override
  String get zoneId => (origin as ZoneProgressProvider).zoneId;
}

String _$zoneCompletionPercentageHash() =>
    r'0ac30ad448e17cf7c6bb7c0df2ac0931e6c7834b';

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
class ZoneCompletionPercentageProvider
    extends AutoDisposeFutureProvider<double> {
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
  AutoDisposeFutureProviderElement<double> createElement() {
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

mixin ZoneCompletionPercentageRef on AutoDisposeFutureProviderRef<double> {
  /// The parameter `zoneId` of this provider.
  String get zoneId;

  /// The parameter `totalLevels` of this provider.
  int get totalLevels;
}

class _ZoneCompletionPercentageProviderElement
    extends AutoDisposeFutureProviderElement<double>
    with ZoneCompletionPercentageRef {
  _ZoneCompletionPercentageProviderElement(super.provider);

  @override
  String get zoneId => (origin as ZoneCompletionPercentageProvider).zoneId;
  @override
  int get totalLevels =>
      (origin as ZoneCompletionPercentageProvider).totalLevels;
}

String _$unlockedPetsHash() => r'55ffcd290137f6f814655e67b0c59a052f213511';

/// Provider for unlocked pets
///
/// Copied from [unlockedPets].
@ProviderFor(unlockedPets)
final unlockedPetsProvider = AutoDisposeFutureProvider<List<String>>.internal(
  unlockedPets,
  name: r'unlockedPetsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$unlockedPetsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UnlockedPetsRef = AutoDisposeFutureProviderRef<List<String>>;
String _$unlockedStickersHash() => r'36d00d34ed355f656c91f6435f51e16cef9aed97';

/// Provider for unlocked stickers
///
/// Copied from [unlockedStickers].
@ProviderFor(unlockedStickers)
final unlockedStickersProvider =
    AutoDisposeFutureProvider<List<String>>.internal(
  unlockedStickers,
  name: r'unlockedStickersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unlockedStickersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UnlockedStickersRef = AutoDisposeFutureProviderRef<List<String>>;
String _$unlockedAvatarItemsHash() =>
    r'563d869d51e29ed85ad05dc2f507772b9830f8d9';

/// Provider for unlocked avatar items
///
/// Copied from [unlockedAvatarItems].
@ProviderFor(unlockedAvatarItems)
final unlockedAvatarItemsProvider =
    AutoDisposeFutureProvider<List<String>>.internal(
  unlockedAvatarItems,
  name: r'unlockedAvatarItemsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unlockedAvatarItemsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UnlockedAvatarItemsRef = AutoDisposeFutureProviderRef<List<String>>;
String _$formattedPlayTimeHash() => r'304beec54ec9ad6134f03b7cf7d9548a0ac1dc56';

/// Provider for total play time (formatted)
///
/// Copied from [formattedPlayTime].
@ProviderFor(formattedPlayTime)
final formattedPlayTimeProvider = AutoDisposeFutureProvider<String>.internal(
  formattedPlayTime,
  name: r'formattedPlayTimeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$formattedPlayTimeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FormattedPlayTimeRef = AutoDisposeFutureProviderRef<String>;
String _$progressNotifierHash() => r'9b6975c48610e46cdc4fafec48402e1139700383';

/// Progress state notifier
///
/// Copied from [ProgressNotifier].
@ProviderFor(ProgressNotifier)
final progressNotifierProvider =
    AutoDisposeAsyncNotifierProvider<ProgressNotifier, PlayerProgress>.internal(
  ProgressNotifier.new,
  name: r'progressNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$progressNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ProgressNotifier = AutoDisposeAsyncNotifier<PlayerProgress>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
