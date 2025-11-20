// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'world_map_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$worldMapLocalServiceHash() =>
    r'33f43e5d131f63192a292d48eb6b63c8726458fa';

/// Provider for WorldMapLocalService
///
/// Copied from [worldMapLocalService].
@ProviderFor(worldMapLocalService)
final worldMapLocalServiceProvider =
    AutoDisposeProvider<WorldMapLocalService>.internal(
  worldMapLocalService,
  name: r'worldMapLocalServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$worldMapLocalServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef WorldMapLocalServiceRef = AutoDisposeProviderRef<WorldMapLocalService>;
String _$worldMapHash() => r'b4897fa884f91415fc95eb1cdbe2c8475b72b306';

/// Provider for managing world map state
///
/// Copied from [WorldMap].
@ProviderFor(WorldMap)
final worldMapProvider =
    AutoDisposeAsyncNotifierProvider<WorldMap, List<Zone>>.internal(
  WorldMap.new,
  name: r'worldMapProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$worldMapHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$WorldMap = AutoDisposeAsyncNotifier<List<Zone>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
