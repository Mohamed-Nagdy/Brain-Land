// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for ProgressStorageService

@ProviderFor(progressStorageService)
const progressStorageServiceProvider = ProgressStorageServiceProvider._();

/// Provider for ProgressStorageService

final class ProgressStorageServiceProvider
    extends
        $FunctionalProvider<
          ProgressStorageService,
          ProgressStorageService,
          ProgressStorageService
        >
    with $Provider<ProgressStorageService> {
  /// Provider for ProgressStorageService
  const ProgressStorageServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'progressStorageServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$progressStorageServiceHash();

  @$internal
  @override
  $ProviderElement<ProgressStorageService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProgressStorageService create(Ref ref) {
    return progressStorageService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProgressStorageService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProgressStorageService>(value),
    );
  }
}

String _$progressStorageServiceHash() =>
    r'ad5614c6e4edfa1e3ad8758dfdece20ea78eef18';

/// Provider for DebugProgressHelper (only in debug mode)

@ProviderFor(debugProgressHelper)
const debugProgressHelperProvider = DebugProgressHelperProvider._();

/// Provider for DebugProgressHelper (only in debug mode)

final class DebugProgressHelperProvider
    extends
        $FunctionalProvider<
          DebugProgressHelper?,
          DebugProgressHelper?,
          DebugProgressHelper?
        >
    with $Provider<DebugProgressHelper?> {
  /// Provider for DebugProgressHelper (only in debug mode)
  const DebugProgressHelperProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'debugProgressHelperProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$debugProgressHelperHash();

  @$internal
  @override
  $ProviderElement<DebugProgressHelper?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DebugProgressHelper? create(Ref ref) {
    return debugProgressHelper(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DebugProgressHelper? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DebugProgressHelper?>(value),
    );
  }
}

String _$debugProgressHelperHash() =>
    r'89150b9c9e02b1bf688dd3ae8f9ed9afcf7c4f5a';

/// Progress state notifier

@ProviderFor(ProgressNotifier)
const progressProvider = ProgressNotifierProvider._();

/// Progress state notifier
final class ProgressNotifierProvider
    extends $AsyncNotifierProvider<ProgressNotifier, PlayerProgress> {
  /// Progress state notifier
  const ProgressNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'progressProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$progressNotifierHash();

  @$internal
  @override
  ProgressNotifier create() => ProgressNotifier();
}

String _$progressNotifierHash() => r'f18541778bdd30d7d2747d6773e9368a68e4605c';

/// Progress state notifier

abstract class _$ProgressNotifier extends $AsyncNotifier<PlayerProgress> {
  FutureOr<PlayerProgress> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<PlayerProgress>, PlayerProgress>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PlayerProgress>, PlayerProgress>,
              AsyncValue<PlayerProgress>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider for total stars

@ProviderFor(totalStars)
const totalStarsProvider = TotalStarsProvider._();

/// Provider for total stars

final class TotalStarsProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Provider for total stars
  const TotalStarsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'totalStarsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$totalStarsHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return totalStars(ref);
  }
}

String _$totalStarsHash() => r'10467fe0f45319698ae1bd6e12da2472e6937e22';

/// Provider for total coins

@ProviderFor(totalCoins)
const totalCoinsProvider = TotalCoinsProvider._();

/// Provider for total coins

final class TotalCoinsProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Provider for total coins
  const TotalCoinsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'totalCoinsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$totalCoinsHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return totalCoins(ref);
  }
}

String _$totalCoinsHash() => r'9ce207026ea3605eede9887c7ca6ed5b788e7535';

/// Provider for current streak

@ProviderFor(currentStreak)
const currentStreakProvider = CurrentStreakProvider._();

/// Provider for current streak

final class CurrentStreakProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Provider for current streak
  const CurrentStreakProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentStreakProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentStreakHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return currentStreak(ref);
  }
}

String _$currentStreakHash() => r'1045b295a850d907d1022a4b7a5d8e246110ab2a';

/// Provider for zone progress

@ProviderFor(zoneProgress)
const zoneProgressProvider = ZoneProgressFamily._();

/// Provider for zone progress

final class ZoneProgressProvider
    extends
        $FunctionalProvider<
          AsyncValue<ZoneProgress?>,
          ZoneProgress?,
          FutureOr<ZoneProgress?>
        >
    with $FutureModifier<ZoneProgress?>, $FutureProvider<ZoneProgress?> {
  /// Provider for zone progress
  const ZoneProgressProvider._({
    required ZoneProgressFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'zoneProgressProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$zoneProgressHash();

  @override
  String toString() {
    return r'zoneProgressProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ZoneProgress?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ZoneProgress?> create(Ref ref) {
    final argument = this.argument as String;
    return zoneProgress(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ZoneProgressProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$zoneProgressHash() => r'109923e2bdef8e7fb773f2215b69c2670e1908ba';

/// Provider for zone progress

final class ZoneProgressFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ZoneProgress?>, String> {
  const ZoneProgressFamily._()
    : super(
        retry: null,
        name: r'zoneProgressProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Provider for zone progress

  ZoneProgressProvider call(String zoneId) =>
      ZoneProgressProvider._(argument: zoneId, from: this);

  @override
  String toString() => r'zoneProgressProvider';
}

/// Provider for zone completion percentage

@ProviderFor(zoneCompletionPercentage)
const zoneCompletionPercentageProvider = ZoneCompletionPercentageFamily._();

/// Provider for zone completion percentage

final class ZoneCompletionPercentageProvider
    extends $FunctionalProvider<AsyncValue<double>, double, FutureOr<double>>
    with $FutureModifier<double>, $FutureProvider<double> {
  /// Provider for zone completion percentage
  const ZoneCompletionPercentageProvider._({
    required ZoneCompletionPercentageFamily super.from,
    required (String, int) super.argument,
  }) : super(
         retry: null,
         name: r'zoneCompletionPercentageProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$zoneCompletionPercentageHash();

  @override
  String toString() {
    return r'zoneCompletionPercentageProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<double> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<double> create(Ref ref) {
    final argument = this.argument as (String, int);
    return zoneCompletionPercentage(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ZoneCompletionPercentageProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$zoneCompletionPercentageHash() =>
    r'147e3781de8e194b705559a7073c2ef8a5ab9c5f';

/// Provider for zone completion percentage

final class ZoneCompletionPercentageFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<double>, (String, int)> {
  const ZoneCompletionPercentageFamily._()
    : super(
        retry: null,
        name: r'zoneCompletionPercentageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Provider for zone completion percentage

  ZoneCompletionPercentageProvider call(String zoneId, int totalLevels) =>
      ZoneCompletionPercentageProvider._(
        argument: (zoneId, totalLevels),
        from: this,
      );

  @override
  String toString() => r'zoneCompletionPercentageProvider';
}

/// Provider for unlocked pets

@ProviderFor(unlockedPets)
const unlockedPetsProvider = UnlockedPetsProvider._();

/// Provider for unlocked pets

final class UnlockedPetsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// Provider for unlocked pets
  const UnlockedPetsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unlockedPetsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unlockedPetsHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return unlockedPets(ref);
  }
}

String _$unlockedPetsHash() => r'05836f8d7c45c77b41d7e0c37d6b1a9871cb3375';

/// Provider for unlocked stickers

@ProviderFor(unlockedStickers)
const unlockedStickersProvider = UnlockedStickersProvider._();

/// Provider for unlocked stickers

final class UnlockedStickersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// Provider for unlocked stickers
  const UnlockedStickersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unlockedStickersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unlockedStickersHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return unlockedStickers(ref);
  }
}

String _$unlockedStickersHash() => r'190717bc8563c7f12f81ae8fdd7cb51518a0a765';

/// Provider for unlocked avatar items

@ProviderFor(unlockedAvatarItems)
const unlockedAvatarItemsProvider = UnlockedAvatarItemsProvider._();

/// Provider for unlocked avatar items

final class UnlockedAvatarItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// Provider for unlocked avatar items
  const UnlockedAvatarItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unlockedAvatarItemsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unlockedAvatarItemsHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return unlockedAvatarItems(ref);
  }
}

String _$unlockedAvatarItemsHash() =>
    r'fa81487654b8806b9a4727bd29329155b178578b';

/// Provider for total play time (formatted)

@ProviderFor(formattedPlayTime)
const formattedPlayTimeProvider = FormattedPlayTimeProvider._();

/// Provider for total play time (formatted)

final class FormattedPlayTimeProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// Provider for total play time (formatted)
  const FormattedPlayTimeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'formattedPlayTimeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$formattedPlayTimeHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return formattedPlayTime(ref);
  }
}

String _$formattedPlayTimeHash() => r'4223c476d39a5a56894fc4a46b99295165a627ae';
