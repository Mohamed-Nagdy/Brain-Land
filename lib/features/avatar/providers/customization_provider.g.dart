// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customization_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$equippedItemsHash() => r'06d1ca09f1927e76dac3d601b63f4bccf1db1764';

/// Provider for equipped items (derived from avatar)
///
/// Copied from [equippedItems].
@ProviderFor(equippedItems)
final equippedItemsProvider =
    AutoDisposeProvider<Map<ItemCategory, String?>>.internal(
  equippedItems,
  name: r'equippedItemsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$equippedItemsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef EquippedItemsRef = AutoDisposeProviderRef<Map<ItemCategory, String?>>;
String _$isItemEquippedHash() => r'e9ca1bd8e5301a36966010d81fb6408c5248f45c';

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

/// Provider to check if an item is currently equipped
///
/// Copied from [isItemEquipped].
@ProviderFor(isItemEquipped)
const isItemEquippedProvider = IsItemEquippedFamily();

/// Provider to check if an item is currently equipped
///
/// Copied from [isItemEquipped].
class IsItemEquippedFamily extends Family<bool> {
  /// Provider to check if an item is currently equipped
  ///
  /// Copied from [isItemEquipped].
  const IsItemEquippedFamily();

  /// Provider to check if an item is currently equipped
  ///
  /// Copied from [isItemEquipped].
  IsItemEquippedProvider call(
    String itemId,
  ) {
    return IsItemEquippedProvider(
      itemId,
    );
  }

  @override
  IsItemEquippedProvider getProviderOverride(
    covariant IsItemEquippedProvider provider,
  ) {
    return call(
      provider.itemId,
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
  String? get name => r'isItemEquippedProvider';
}

/// Provider to check if an item is currently equipped
///
/// Copied from [isItemEquipped].
class IsItemEquippedProvider extends AutoDisposeProvider<bool> {
  /// Provider to check if an item is currently equipped
  ///
  /// Copied from [isItemEquipped].
  IsItemEquippedProvider(
    String itemId,
  ) : this._internal(
          (ref) => isItemEquipped(
            ref as IsItemEquippedRef,
            itemId,
          ),
          from: isItemEquippedProvider,
          name: r'isItemEquippedProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$isItemEquippedHash,
          dependencies: IsItemEquippedFamily._dependencies,
          allTransitiveDependencies:
              IsItemEquippedFamily._allTransitiveDependencies,
          itemId: itemId,
        );

  IsItemEquippedProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.itemId,
  }) : super.internal();

  final String itemId;

  @override
  Override overrideWith(
    bool Function(IsItemEquippedRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IsItemEquippedProvider._internal(
        (ref) => create(ref as IsItemEquippedRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        itemId: itemId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _IsItemEquippedProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsItemEquippedProvider && other.itemId == itemId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, itemId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin IsItemEquippedRef on AutoDisposeProviderRef<bool> {
  /// The parameter `itemId` of this provider.
  String get itemId;
}

class _IsItemEquippedProviderElement extends AutoDisposeProviderElement<bool>
    with IsItemEquippedRef {
  _IsItemEquippedProviderElement(super.provider);

  @override
  String get itemId => (origin as IsItemEquippedProvider).itemId;
}

String _$customizationInventoryHash() =>
    r'9a1af0b527d7fcdfd13b0f54b3e24f8c468490cb';

/// Customization inventory state notifier
///
/// Copied from [CustomizationInventory].
@ProviderFor(CustomizationInventory)
final customizationInventoryProvider = AutoDisposeNotifierProvider<
    CustomizationInventory, List<CustomizationItem>>.internal(
  CustomizationInventory.new,
  name: r'customizationInventoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$customizationInventoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CustomizationInventory = AutoDisposeNotifier<List<CustomizationItem>>;
String _$selectedCategoryHash() => r'366607d680a9395a7169e3cc84c5e996699e91e8';

/// Provider for currently selected category
///
/// Copied from [SelectedCategory].
@ProviderFor(SelectedCategory)
final selectedCategoryProvider =
    AutoDisposeNotifierProvider<SelectedCategory, ItemCategory>.internal(
  SelectedCategory.new,
  name: r'selectedCategoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedCategoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedCategory = AutoDisposeNotifier<ItemCategory>;
String _$selectedItemHash() => r'201eadd0a7c157dc7f60790fcbeccf3a20bdbc1d';

/// Provider for currently selected item in customization screen
///
/// Copied from [SelectedItem].
@ProviderFor(SelectedItem)
final selectedItemProvider =
    AutoDisposeNotifierProvider<SelectedItem, String?>.internal(
  SelectedItem.new,
  name: r'selectedItemProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$selectedItemHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedItem = AutoDisposeNotifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
