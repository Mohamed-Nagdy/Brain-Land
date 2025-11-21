// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'world_map_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for WorldMapLocalService

@ProviderFor(worldMapLocalService)
const worldMapLocalServiceProvider = WorldMapLocalServiceProvider._();

/// Provider for WorldMapLocalService

final class WorldMapLocalServiceProvider
    extends
        $FunctionalProvider<
          WorldMapLocalService,
          WorldMapLocalService,
          WorldMapLocalService
        >
    with $Provider<WorldMapLocalService> {
  /// Provider for WorldMapLocalService
  const WorldMapLocalServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'worldMapLocalServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$worldMapLocalServiceHash();

  @$internal
  @override
  $ProviderElement<WorldMapLocalService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WorldMapLocalService create(Ref ref) {
    return worldMapLocalService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorldMapLocalService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorldMapLocalService>(value),
    );
  }
}

String _$worldMapLocalServiceHash() =>
    r'33f43e5d131f63192a292d48eb6b63c8726458fa';

/// Provider for managing world map state

@ProviderFor(WorldMap)
const worldMapProvider = WorldMapProvider._();

/// Provider for managing world map state
final class WorldMapProvider
    extends $AsyncNotifierProvider<WorldMap, List<Zone>> {
  /// Provider for managing world map state
  const WorldMapProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'worldMapProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$worldMapHash();

  @$internal
  @override
  WorldMap create() => WorldMap();
}

String _$worldMapHash() => r'b4897fa884f91415fc95eb1cdbe2c8475b72b306';

/// Provider for managing world map state

abstract class _$WorldMap extends $AsyncNotifier<List<Zone>> {
  FutureOr<List<Zone>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Zone>>, List<Zone>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Zone>>, List<Zone>>,
              AsyncValue<List<Zone>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
