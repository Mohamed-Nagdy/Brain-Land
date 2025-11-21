// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zone_unlock_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider to check if a zone is unlocked

@ProviderFor(ZoneUnlock)
const zoneUnlockProvider = ZoneUnlockProvider._();

/// Provider to check if a zone is unlocked
final class ZoneUnlockProvider
    extends $AsyncNotifierProvider<ZoneUnlock, List<String>> {
  /// Provider to check if a zone is unlocked
  const ZoneUnlockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'zoneUnlockProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$zoneUnlockHash();

  @$internal
  @override
  ZoneUnlock create() => ZoneUnlock();
}

String _$zoneUnlockHash() => r'8edef6eaf21be5412b3ae822a8dd3b8841322ff5';

/// Provider to check if a zone is unlocked

abstract class _$ZoneUnlock extends $AsyncNotifier<List<String>> {
  FutureOr<List<String>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<String>>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<String>>, List<String>>,
              AsyncValue<List<String>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
